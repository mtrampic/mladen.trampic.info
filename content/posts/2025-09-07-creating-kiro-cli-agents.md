---
title: "Building Opinionated AI Assistants with Kiro CLI Agents"
date: 2025-09-07T09:57:00Z
draft: false
tags: ["AWS", "Kiro", "CLI", "AI", "Development Tools", "MCP"]
categories: ["Development"]
author: "Mladen Trampic & Kiro Developer"
authors: ["mladen-trampic", "kiro"]
description: "Why generic AI assistants waste developer time, and how Kiro CLI's agent system lets you build scoped, secure, context-aware assistants that know your project."
---

> **Updated May 2, 2026** — This post was originally written in September 2025 when the tool was called Amazon Q Developer CLI. It has since been refactored to reflect the rebranding to Kiro CLI and the current configuration as of May 2026.

## The Problem with Generic AI

I believe the next leap in developer tooling isn't smarter models — it's **opinionated context**. A model that knows everything but understands nothing about *your* project is just a faster way to generate wrong answers.

Every time I started a Kiro CLI session for this blog, I re-explained the same things: my Hugo conventions, which posts were drafts, that AWS pricing claims need verification, that I use Congo theme with specific frontmatter fields. The default assistant was capable but amnesiac. It had no opinion about my workflow because it had no context about my workflow.

Kiro's agent system changed that. Instead of a generic chat assistant, I built a **blog co-author** that:
- Knows my content structure before I say a word (via lifecycle hooks)
- Delegates AWS fact-checking to a specialist subagent (not the generalist)
- Can only write to `content/` and `static/` (not my config files)
- Loads my style guide on demand without bloating every conversation

The result isn't just convenience — it's a fundamentally different relationship with the tool. The agent has opinions about my project because I gave it opinions.

> **TL;DR — What you'll learn:**
>
> 1. **Architecture principles** — Least privilege, description-driven delegation, and isolation through composition
> 2. **Agent configuration** — JSON structure, system prompts, and resource loading
> 3. **Hooks** — Injecting project context automatically at lifecycle events
> 4. **Subagents** — Delegating specialized work (fact-checking, research) to focused agents
> 5. **Security** — Shell restrictions, path-scoped writes, and layered permissions

## Architecture Principles

Before diving into configuration, these are the design principles that make agents useful rather than just configured:

1. **Least privilege**: Start restrictive, expand as needed. Subagents should only have the tools they need. A fact-checker doesn't need filesystem write access.
2. **Description-driven delegation**: The `description` field is your primary lever for controlling when subagents trigger. The model reads it to decide whether to delegate — vague descriptions mean unreliable delegation.
3. **Isolation through composition**: Each agent has its own MCP servers, tools, and permissions. The parent stays lean while subagents bring specialized capabilities.
4. **Progressive loading**: Use `skill://` for large reference docs — they load on demand, keeping context lean.
5. **Security layers**: Combine `allowedTools`, `toolsSettings.shell`, and `toolsSettings.write.allowedPaths` for defense in depth.

These aren't abstract ideals — they're lessons from debugging agents that were too permissive, too vague, or too bloated. Every principle below maps back to a real problem I hit.

## Prerequisites

- **Kiro CLI 2.2.0+** installed ([installation guide](https://kiro.dev/docs/cli/installation/))
- Basic familiarity with JSON configuration
- A project directory where you want to configure agents
- Optional: MCP servers you want agents to use (Docker, npm/npx, or uvx for running them)

> **Note on MCP servers**: The AWS MCP servers (`aws-documentation`, `aws-pricing`) require a configured AWS CLI profile, which is out of scope for this post. For the NotebookLM skill used by the researcher subagent, see [notebooklm-py](https://github.com/teng-lin/notebooklm-py) for setup instructions (requires a Google account).

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

Use this table as a reference when building your agent config — each field controls a specific aspect of the agent's behavior:

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

The `resources` field loads additional context into the agent. Unlike `prompt`, resource paths resolve **relative to the workspace root**:

```json
{
  "resources": [
    "file://.kiro/steering/*.md",
    "file://README.md",
    "skill://.kiro/skills/**/SKILL.md"
  ]
}
```

Three resource types are supported — choose based on how much context you want loaded and when:

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

Hooks solve the "re-explain everything" problem. They run shell commands at specific lifecycle points, injecting their output into the agent's context automatically.

### Hook Triggers

Each trigger fires at a different point — use them to give the agent the right context at the right time:

| Trigger | When | Output Behavior |
|---------|------|-----------------|
| `agentSpawn` | Agent starts | STDOUT added to context |
| `userPromptSubmit` | Before each user message | STDOUT added to context |
| `preToolUse` | Before tool execution | Exit 2 blocks the tool; STDERR returned to model |
| `postToolUse` | After tool execution | Informational only |
| `stop` | Assistant finishes responding | Can trigger post-processing |

### Practical Example

This is the hook setup I use for my blog assistant — it gives the agent awareness of git state, recent posts, and current drafts without me saying anything:

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

The `matcher` field (for `preToolUse`/`postToolUse`) filters which tools trigger the hook. It accepts both canonical names (`fs_read`, `fs_write`, `execute_bash`, `use_aws`) and their aliases (`read`, `write`, `shell`, `aws`), MCP patterns (`@git/status`), or `*` for all. See the [built-in tools reference](https://kiro.dev/docs/cli/reference/built-in-tools/) for the full list.

### Hook Options

These control execution limits — useful for preventing runaway commands or caching expensive lookups:

| Option | Default | Purpose |
|--------|---------|---------|
| `timeout_ms` | 30000 | Maximum execution time |
| `cache_ttl_seconds` | 0 | Cache successful results (0 = no cache) |

## Subagents: Delegating Specialized Work

Agents can spawn other agents as tools using the `subagent` built-in. This enables modular architectures where a parent agent delegates specialized tasks to focused subagents — each with their own tools, permissions, and MCP servers.

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
      "availableAgents": ["aws-fact-checker", "kiro-fact-checker", "researcher"],
      "trustedAgents": ["aws-fact-checker", "kiro-fact-checker", "researcher"]
    }
  }
}
```

Use these settings to control which agents can be spawned and which run without per-invocation approval:

| Setting | Purpose |
|---------|---------|
| `availableAgents` | Which agents can be spawned as subagents (supports globs like `test-*`) |
| `trustedAgents` | Which agents run without per-invocation user approval |

If `availableAgents` is empty or omitted, ALL workspace agents are available.

### Subagent Example: AWS Fact-Checker

A focused subagent with only MCP tools — no filesystem, no shell. This is isolation through composition in practice:

```json
{
  "name": "aws-fact-checker",
  "description": "AWS fact-checker subagent. Invoke when blog content makes claims about AWS service features, limits, pricing, quotas, or configurations that need verification against official AWS documentation.",
  "prompt": "You are an AWS fact-checking specialist. Your role is to verify technical claims about AWS services using official documentation and pricing data.\n\nWhen asked to verify a claim:\n1. Search official AWS documentation for the relevant service\n2. Check pricing data if cost claims are involved\n3. Return a clear verdict: CONFIRMED, INCORRECT, or PARTIALLY CORRECT\n4. Include the source documentation reference\n5. If incorrect, provide the correct information",
  "mcpServers": {
    "awslabs.aws-documentation-mcp-server": {
      "command": "uvx",
      "args": ["awslabs.aws-documentation-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "AWS_DOCUMENTATION_PARTITION": "aws",
        "AWS_PROFILE": "${AWS_DEFAULT_PROFILE:-default}"
      }
    },
    "awslabs.aws-pricing-mcp-server": {
      "command": "uvx",
      "args": ["awslabs.aws-pricing-mcp-server@latest"],
      "env": {
        "FASTMCP_LOG_LEVEL": "ERROR",
        "AWS_PROFILE": "${AWS_DEFAULT_PROFILE:-default}",
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

### Subagent Example: Kiro Fact-Checker

A second focused subagent that verifies claims about Kiro CLI itself against the official documentation at kiro.dev. It uses Playwright to browse the docs and a skill file containing the sitemap for efficient page lookup:

```json
{
  "name": "kiro-fact-checker",
  "description": "Kiro CLI documentation fact-checker. Invoke when blog content makes claims about Kiro CLI features, configuration options, agent behavior, hooks, subagents, MCP integration, slash commands, or any Kiro-specific functionality that needs verification against official docs at kiro.dev.",
  "prompt": "You are a Kiro CLI documentation fact-checker. Verify technical claims about Kiro CLI by checking official documentation at kiro.dev using Playwright...",
  "mcpServers": {
    "playwright": {
      "command": "npx",
      "args": ["@playwright/mcp@latest"]
    }
  },
  "resources": ["skill://.kiro/skills/kiro-docs/SKILL.md"],
  "tools": ["read", "@playwright"],
  "allowedTools": ["read", "@playwright"]
}
```

This agent has no filesystem write access and no shell — it can only read local skill files and browse kiro.dev via Playwright.

### Task Graphs: Parallel and Sequential Execution

When a task involves multiple subagents, Kiro plans a directed acyclic graph (DAG) upfront. Independent tasks — like two fact-checkers that both depend on research but not on each other — run in parallel. Tasks with dependencies wait for their prerequisites to complete before starting.

> **How this relates to TODO lists**: The TODO list tracks the parent agent's overall plan (visible to you via `/todo view`). A single TODO step like "fact-check claims" might internally spawn a task graph where multiple subagents run in parallel. The TODO tracks *what*; the DAG optimizes *how*.

```text
  ┌─────────────┐
  │  1. Research │  (researcher subagent)
  └──────┬───────┘
         │
  ┌──────▼───────┐     ┌────────────────┐
  │2. AWS facts  │     │3. Kiro facts   │  (parallel — both depend on research, not each other)
  └──────┬───────┘     └───────┬────────┘
         │                     │
         └──────────┬──────────┘
                    │
            ┌───────▼───────┐
            │   4. Write    │  (parent agent — waits for both)
            └───────────────┘
```

## Skills: Structured Reference Documentation

Skills give agents precise knowledge of command syntax and workflows without bloating the system prompt. Use them when you have reference material that's only relevant some of the time — CLI syntax, API schemas, workflow checklists.

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

The `toolsSettings.shell` configuration provides regex-based control over which commands an agent can execute. Use this to auto-approve safe commands while blocking destructive ones:

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
| `deniedCommands` | Regex patterns always blocked |
| `autoAllowReadonly` | Auto-approve read-only commands (ls, cat, grep, etc.) |

### Design Pattern: Layered Permissions

Combine shell, write, and tool restrictions for defense in depth:

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

## Enabling Experimental Tools: TODO Lists

Some built-in tools require a CLI setting before they're available. The TODO list tool (experimental) gives agents the ability to create task lists, track multi-step progress, and resume work across sessions. Enable it with:

```bash
kiro-cli settings chat.enableTodoList true
```

Once enabled, add `todo_list` to your agent's `tools` and `allowedTools` arrays:

```json
{
  "tools": ["read", "write", "shell", "subagent", "todo_list"],
  "allowedTools": ["read", "write", "subagent", "todo_list"]
}
```

Then instruct the agent to use it via the system prompt. I added a mandatory protocol to my blog assistant's prompt:

```markdown
# MANDATORY TODO LIST PROTOCOL

**ALWAYS create a TODO list before starting any multi-step work.** This includes:
- Writing a new blog post
- Reviewing/editing an existing post
- Fact-checking content
- Publishing workflow

The TODO list ensures sequential task execution and tracks progress.
```

This changed my workflow significantly — the agent now breaks every request into visible, trackable steps before executing. You can view active tasks mid-session with `/todo view`.

## The Result: A Complete Blog Assistant

Here's the actual orchestrator agent used for this blog (available in the [GitHub repo](https://github.com/mtrampic/mladen.trampic.info)):

```json
{
  "name": "blog-assistant",
  "description": "Technical blog co-author for Hugo-based content. Delegates to 'researcher' for multi-source topic research, source gathering, and fact synthesis. Delegates to 'aws-fact-checker' when content makes claims about AWS service features, limits, pricing, or configurations. Delegates to 'kiro-fact-checker' when content makes claims about Kiro CLI features, configuration, hooks, subagents, or behavior.",
  "prompt": "file://../prompts/blog-assistant.md",
  "tools": ["@sequential-thinking", "@playwright", "read", "write", "shell", "subagent", "todo_list"],
  "allowedTools": ["@sequential-thinking", "@playwright", "read", "write", "shell", "subagent", "todo_list"],
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
      "trustedAgents": ["aws-fact-checker", "kiro-fact-checker", "researcher"],
      "availableAgents": ["aws-fact-checker", "kiro-fact-checker", "researcher"]
    }
  }
}
```

### Before and After

**Without agents** — every session starts cold:

```
$ kiro-cli chat
> Write a blog post about Aurora Serverless v2 pricing

Assistant: Sure, I'll help. What's your Hugo setup? What theme? What frontmatter fields?
> Congo theme, author field uses "authors" array, posts go in content/posts/...
Assistant: Got it. And should I verify the pricing claims?
> Yes, check against AWS docs
Assistant: I don't have access to AWS documentation tools. Let me search the web...
```

**With the blog-assistant agent** — context is pre-loaded, delegation is automatic:

```
$ kiro-cli chat --agent blog-assistant
[hooks: git status, recent posts, draft list loaded into context]

> Write a blog post about Aurora Serverless v2 pricing

[TODO list created: 1. Research topic 2. Draft content 3. Fact-check AWS claims 4. Validate links 5. Publish]
[Delegating to researcher subagent...]
[Delegating to aws-fact-checker: "Verify Aurora Serverless v2 ACU pricing per region..."]
Assistant: Here's your draft with verified pricing. The researcher found three
key architectural patterns, and the fact-checker confirmed all ACU rates
against current AWS documentation.
```

No re-explaining. No manual tool selection. The agent knows the workflow.

## What Changed in My Workflow

Before agents, every Kiro session started with me re-explaining my project structure, Hugo conventions, and which posts were in progress. Now the `agentSpawn` hooks handle that context automatically, and the subagent architecture means I can say "verify the S3 pricing claims in that paragraph" and the blog assistant delegates to the fact-checker without me thinking about which tool to use.

The biggest insight was how much the `description` field matters for delegation. I spent time debugging why my researcher subagent never triggered — turns out "Deep research agent" tells the model nothing about *when* to use it. Changing it to explicitly list trigger conditions ("invoke when the task requires deep multi-source research, synthesizing findings across web sources...") made delegation reliable overnight.

## Validation and Testing

```bash
# Validate configuration syntax
kiro-cli agent validate .kiro/agents/blog-assistant.json

# List discovered agents
kiro-cli agent list

# Start a session with your agent
kiro-cli chat --agent blog-assistant

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