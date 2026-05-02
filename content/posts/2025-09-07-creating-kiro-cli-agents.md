---
title: "Creating Kiro CLI Agents: A Practical Guide"
date: 2025-09-07T09:57:00Z
draft: false
tags: ["AWS", "Kiro", "CLI", "AI", "Development Tools", "MCP"]
categories: ["Development"]
author: "Mladen Trampic & Kiro Developer"
authors: ["mladen-trampic", "kiro"]
description: "A concise guide to building custom Kiro CLI agents — from basic configuration through subagent delegation, hooks, skills, and shell security."
---

When I started using Kiro CLI for this blog, I quickly hit a wall: the default assistant didn't know my Hugo conventions, couldn't verify AWS claims, and had no sense of which posts were drafts. I needed something more opinionated. Kiro's agent system let me build exactly that — a blog co-author that knows my content structure, delegates fact-checking to a specialist subagent, and gathers project context automatically before every conversation.

This guide walks through everything I learned building that setup: from a basic agent config to multi-agent delegation, lifecycle hooks, and security controls. By the end, you'll have a clear mental model of how Kiro agents work and enough practical knowledge to build your own.

## Prerequisites

- **Kiro CLI 2.2.0+** installed ([installation guide](https://kiro.dev/docs/cli/installation/))
- Basic familiarity with JSON configuration
- A project directory where you want to configure agents
- Optional: MCP servers you want agents to use (Docker, npm/npx, or uvx for running them)

## What Are Kiro CLI Agents?

Kiro CLI agents are JSON-configured AI assistants scoped to specific workflows. Instead of a generic chat assistant, you define exactly which tools an agent can use, what context it receives, and what permissions it has. The result is a focused, secure, context-aware assistant that understands your project.

For the full field reference, see the [official configuration documentation](https://kiro.dev/docs/cli/custom-agents/configuration-reference/).

## Agent Configuration Structure

Agent configs live in `.kiro/agents/` (workspace-local) or `~/.kiro/agents/` (global). Each file is a JSON object:

```json
{
  "name": "my-agent",
  "description": "A custom agent for my workflow",
  "prompt": "You are a helpful coding assistant",
  "tools": ["read", "write", "shell"],
  "allowedTools": ["read"],
  "resources": ["file://README.md", "file://.kiro/steering/**/*.md"],
  "model": "claude-sonnet-4"
}
```

### Key Fields

| Field | Purpose |
|-------|---------|
| `name` | Agent identifier (derived from filename if omitted) |
| `description` | Human-readable purpose — also used by parent agents to decide subagent delegation |
| `prompt` | System prompt (inline text or `file://` URI) |
| `tools` | Tools the agent can see (`read`, `write`, `shell`, `@mcp-server`, `subagent`, `*`) |
| `allowedTools` | Tools auto-approved without user confirmation (supports glob patterns) |
| `resources` | Files, skills, or knowledge bases loaded into context |
| `hooks` | Shell commands triggered at lifecycle events |
| `mcpServers` | MCP server definitions |
| `toolsSettings` | Per-tool restrictions (paths, commands, subagent access) |
| `model` | Model override (falls back to default if unavailable) |
| `keyboardShortcut` | Quick-switch shortcut (e.g., `ctrl+1`) |
| `welcomeMessage` | Message shown when switching to this agent |

For the complete list of built-in tools and their configuration options, see the [built-in tools reference](https://kiro.dev/docs/cli/reference/built-in-tools/).

Use `/agent create` or `kiro-cli agent create` to scaffold a new config interactively.

## System Prompts

For non-trivial prompts, use a `file://` URI. The path resolves **relative to the agent config file's directory**:

```json
{
  "prompt": "file://../prompts/blog-assistant.md"
}
```

This keeps agent JSON clean while letting you version-control prompts as separate markdown files.

### Resources: Loading Context

The `resources` field loads additional context. Unlike `prompt`, resource paths resolve **relative to the workspace root**:

```json
{
  "resources": [
    "file://.kiro/steering/*.md",
    "file://README.md",
    "skill://.kiro/skills/**/SKILL.md"
  ]
}
```

Three resource types are supported:

| Type | Behavior |
|------|----------|
| `file://` | Loaded fully into context at startup |
| `skill://` | Only metadata loaded at startup; full content loaded on demand |
| `knowledgeBase` | Indexed for search across large document sets |

Knowledge base example:

```json
{
  "resources": [
    {
      "type": "knowledgeBase",
      "source": "file://./docs",
      "name": "ProjectDocs",
      "description": "Project documentation and guides",
      "indexType": "best",
      "autoUpdate": true
    }
  ]
}
```

## Hooks: Contextual Intelligence

Hooks run shell commands at specific lifecycle points, injecting their output into the agent's context.

### Hook Triggers

| Trigger | When | Output Behavior |
|---------|------|-----------------|
| `agentSpawn` | Agent starts | STDOUT added to context |
| `userPromptSubmit` | Before each user message | STDOUT added to context |
| `preToolUse` | Before tool execution | Exit 2 blocks the tool; STDERR returned to model |
| `postToolUse` | After tool execution | Informational only |
| `stop` | Assistant finishes responding | Can trigger post-processing |

### Practical Example

```json
{
  "hooks": {
    "agentSpawn": [
      { "command": "git status --porcelain" },
      { "command": "find content/posts -name '*.md' -mtime -7 | head -5" }
    ],
    "userPromptSubmit": [
      {
        "command": "grep -r 'draft: true' content/posts/ | head -5",
        "timeout_ms": 5000,
        "cache_ttl_seconds": 60
      }
    ],
    "preToolUse": [
      {
        "matcher": "execute_bash",
        "command": "{ echo \"$(date) - Command:\"; cat; } >> /tmp/audit.log"
      }
    ],
    "postToolUse": [
      {
        "matcher": "fs_write",
        "command": "prettier --write $(cat | jq -r '.tool_input.path')"
      }
    ]
  }
}
```

The `matcher` field (for `preToolUse`/`postToolUse`) filters which tools trigger the hook. It uses internal tool names (`fs_read`, `fs_write`, `execute_bash`, `use_aws`), MCP patterns (`@git/status`), or `*` for all. See the [built-in tools reference](https://kiro.dev/docs/cli/reference/built-in-tools/) for the full list of tool names and aliases.

### Hook Options

| Option | Default | Purpose |
|--------|---------|---------|
| `timeout_ms` | 30000 | Maximum execution time |
| `max_output_size` | 10240 | Maximum output in bytes |
| `cache_ttl_seconds` | 0 | Cache successful results (0 = no cache) |

## Subagents: Delegating Specialized Work

Agents can spawn other agents as tools using the `subagent` built-in. This enables modular architectures where a parent agent delegates specialized tasks to focused subagents.

### Why the Description Field Matters

From the [official docs](https://kiro.dev/docs/cli/chat/subagents/): "You describe a task, and Kiro determines if a subagent is appropriate." In practice, the `description` field is the **primary signal** the model uses to decide whether to delegate and to which agent. A vague description means the parent agent won't know when delegation is appropriate.

Write descriptions that clearly communicate **when** the subagent should be invoked:

```json
{
  "description": "AWS documentation and pricing fact-checker. Use when blog content makes claims about AWS service features, limits, pricing, or configurations that need verification against official docs."
}
```

Compare with a vague description that won't trigger reliably:

```json
{
  "description": "AWS helper agent"
}
```

### Configuration

```json
{
  "tools": ["read", "write", "shell", "subagent"],
  "toolsSettings": {
    "subagent": {
      "availableAgents": ["aws-fact-checker", "researcher"],
      "trustedAgents": ["aws-fact-checker", "researcher"]
    }
  }
}
```

| Setting | Purpose |
|---------|---------|
| `availableAgents` | Which agents can be spawned as subagents (supports globs like `test-*`) |
| `trustedAgents` | Which agents run without per-invocation user approval |

If `availableAgents` is empty or omitted, ALL workspace agents are available.

### Subagent Example: AWS Fact-Checker

A focused subagent with only MCP tools — no filesystem, no shell:

```json
{
  "name": "aws-fact-checker",
  "description": "AWS documentation and pricing fact-checker. Invoke when content makes claims about AWS service features, limits, pricing, or configurations that need verification.",
  "prompt": "You are an AWS fact-checking specialist. Verify claims using official documentation and pricing data.\n\nReturn a clear verdict: CONFIRMED, INCORRECT, or PARTIALLY CORRECT with source references.",
  "mcpServers": {
    "awslabs.aws-documentation-mcp-server": {
      "command": "uvx",
      "args": ["awslabs.aws-documentation-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR"
      }
    },
    "awslabs.aws-pricing-mcp-server": {
      "command": "uvx",
      "args": ["awslabs.aws-pricing-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "AWS_REGION": "us-east-1"
      }
    }
  },
  "tools": [
    "@awslabs.aws-documentation-mcp-server",
    "@awslabs.aws-pricing-mcp-server"
  ],
  "allowedTools": [
    "@awslabs.aws-documentation-mcp-server",
    "@awslabs.aws-pricing-mcp-server"
  ]
}
```

This pattern keeps each agent isolated: the fact-checker can only query AWS docs, not modify files or run shell commands.

### Task Graphs: Parallel and Sequential Execution

Subagents support DAG-based task execution. The parent agent plans the full task graph upfront, then executes subagents in order — running independent tasks in parallel and waiting for dependencies:

```text
  ┌─────────────┐
  │  1. Research │  (researcher subagent)
  └──────┬───────┘
         │
  ┌──────▼───────┐
  │ 2. Fact-check│  (aws-fact-checker subagent)
  └──────┬───────┘
         │
  ┌──────▼───────┐
  │  3. Write    │  (parent agent)
  └──────────────┘
```

## Skills: Structured Reference Documentation

Skills give agents precise knowledge of command syntax and workflows without bloating the system prompt. They're loaded on-demand based on their metadata.

### Skill Structure

Skills live in `.kiro/skills/<name>/SKILL.md` with YAML frontmatter:

```markdown
---
name: notebooklm
description: Google NotebookLM CLI for deep research and content generation. Load when user asks for multi-source research, podcast generation, or document analysis.
---

# NotebookLM CLI Reference

## Quick Reference

| Task | Command |
|------|---------|
| Create notebook | `notebooklm create "Title" --json` |
| Add source | `notebooklm source add "url" --json` |
| Query sources | `notebooklm ask "question" --json` |
| Generate report | `notebooklm generate report --format blog-post` |

## Error Handling

| Error | Action |
|-------|--------|
| Auth error | Ask user to run `notebooklm login` |
| Rate limit | Wait 5-10 min, retry |
```

The `description` in frontmatter determines when the skill gets fully loaded — write it to match the tasks where the skill is relevant.

### Referencing Skills

```json
{
  "resources": ["skill://.kiro/skills/notebooklm/SKILL.md"]
}
```

Only the skill's name and description are loaded at startup. The full content is loaded on demand when the agent determines it's needed.

## Shell Command Security

The `toolsSettings.shell` configuration provides regex-based control over which commands an agent can execute:

```json
{
  "toolsSettings": {
    "shell": {
      "allowedCommands": [
        "^hugo .*$",
        "^git status.*$",
        "^git log.*$",
        "^notebooklm .*$"
      ],
      "deniedCommands": [
        "^git push.*$",
        "^rm -rf.*$",
        "^notebooklm delete.*$"
      ],
      "autoAllowReadonly": true
    }
  }
}
```

| Setting | Behavior |
|---------|----------|
| `allowedCommands` | Regex patterns auto-approved without user confirmation |
| `deniedCommands` | Regex patterns always blocked (takes precedence) |
| `autoAllowReadonly` | Auto-approve read-only commands (ls, cat, grep, etc.) |

### Design Pattern: Layered Permissions

```json
{
  "toolsSettings": {
    "shell": {
      "allowedCommands": ["^notebooklm .*$"],
      "deniedCommands": ["^notebooklm delete.*$", "^notebooklm login.*$"],
      "autoAllowReadonly": true
    },
    "write": {
      "allowedPaths": ["content/**", "static/**"]
    }
  }
}
```

This gives the agent broad read access, CLI access to one tool (minus destructive operations), and write access only to content directories.

## Complete Example: Blog Assistant with Subagents

Here's the actual orchestrator agent used for this blog (available in the [GitHub repo](https://github.com/mtrampic/mladen.trampic.info)):

```json
{
  "name": "blog-assistant",
  "description": "Technical blog co-author for Hugo-based content. Delegates to 'researcher' for multi-source topic research, source gathering, and fact synthesis. Delegates to 'aws-fact-checker' when content makes claims about AWS service features, limits, pricing, or configurations.",
  "prompt": "file://../prompts/blog-assistant.md",
  "tools": ["read", "write", "shell", "subagent", "@sequential-thinking", "@playwright"],
  "allowedTools": ["read", "write", "subagent", "@sequential-thinking", "@playwright"],
  "mcpServers": {
    "sequential-thinking": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
    },
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  },
  "resources": [
    "file://.kiro/steering/*.md",
    "file://README.md",
    "file://config.yaml"
  ],
  "hooks": {
    "agentSpawn": [
      { "command": "git status --porcelain" },
      { "command": "find content/posts -name '*.md' -mtime -7 | head -5" },
      { "command": "git log --oneline -5 -i --grep='publish'" }
    ],
    "userPromptSubmit": [
      {
        "command": "grep -r 'draft: true' content/posts/ | head -5 || echo 'No drafts found'",
        "timeout_ms": 5000,
        "cache_ttl_seconds": 60
      },
      {
        "command": "git diff --name-only HEAD~1 HEAD -- content/ | grep -E '\\.(md)$' || echo 'No recent content changes'",
        "timeout_ms": 3000,
        "cache_ttl_seconds": 30
      }
    ]
  },
  "toolsSettings": {
    "write": {
      "allowedPaths": ["content/**", "static/**", "archetypes/**", ".kiro/rules/**"]
    },
    "shell": {
      "allowedCommands": ["^hugo serve.*$", "^hugo version$", "^hugo list.*$", "^git .*$", "^bash .kiro/hooks/validate-links.sh.*$"],
      "autoAllowReadonly": true
    },
    "subagent": {
      "trustedAgents": ["aws-fact-checker", "researcher"],
      "availableAgents": ["aws-fact-checker", "researcher"]
    }
  }
}
```

The parent agent uses the subagents' descriptions to decide when to delegate. The subagents run in isolation with their own tools and permissions.

## Validation and Testing

```bash
# Validate configuration syntax
kiro-cli agent validate --path .kiro/agents/blog-assistant.json

# List discovered agents
kiro-cli agent list

# Start a session with your agent
kiro-cli --agent blog-assistant

# Or swap agents mid-session
/agent swap
```

## Common Pitfalls

| Issue | Fix |
|-------|-----|
| `prompt` file not found | `file://` in `prompt` resolves relative to the **agent config directory**, not workspace root |
| Resources not loading | `file://` in `resources` resolves relative to the **workspace root** |
| Subagent never triggered | Write a specific `description` — it's the primary signal the model uses to decide delegation |
| Skills loading too eagerly | Skill `description` in frontmatter controls when content loads; make it specific |
| Allowed commands not working | Patterns are regex — anchor them with `^` and `$` |
| MCP tools not appearing | Reference with `@server-name` in `tools` array |

## Architecture Principles

1. **Least privilege**: Start restrictive, expand as needed. Subagents should only have the tools they need.
2. **Description-driven delegation**: The `description` field is your primary lever for controlling when subagents trigger. Be specific about use cases.
3. **Isolation through composition**: Each agent has its own MCP servers, tools, and permissions. The parent stays lean while subagents bring specialized capabilities.
4. **Progressive loading**: Use `skill://` for large reference docs — they load on demand, keeping context lean.
5. **Security layers**: Combine `allowedTools`, `toolsSettings.shell`, and `toolsSettings.write.allowedPaths` for defense in depth.

## What Changed in My Workflow

Before agents, every Kiro session started with me re-explaining my project structure, Hugo conventions, and which posts were in progress. Now the `agentSpawn` hooks handle that context automatically, and the subagent architecture means I can say "verify the S3 pricing claims in that paragraph" and the blog assistant delegates to the fact-checker without me thinking about which tool to use.

The biggest insight was how much the `description` field matters for delegation. I spent time debugging why my researcher subagent never triggered — turns out "Deep research agent" tells the model nothing about *when* to use it. Changing it to explicitly list trigger conditions ("invoke when the task requires deep multi-source research, synthesizing findings across web sources...") made delegation reliable overnight.

## Next Steps

1. **Start simple** — create a single agent with a prompt and `allowedTools`. Use it for a week.
2. **Add hooks** — once you know what context you keep repeating, automate it with `agentSpawn` hooks.
3. **Extract subagents** — when your agent's MCP server list grows unwieldy, split specialized capabilities into focused subagents.
4. **Add skills** — for CLI tools you use frequently, write a skill file so the agent knows the exact syntax.

For the complete field reference and more examples, see the [Kiro CLI documentation](https://kiro.dev/docs/cli/custom-agents/configuration-reference/).

---

**Source code**: The complete agent configurations used for this blog are at [github.com/mtrampic/mladen.trampic.info](https://github.com/mtrampic/mladen.trampic.info)

---

*This post was co-authored by Mladen Trampic and Kiro, demonstrating the collaborative approach to technical content creation.*
