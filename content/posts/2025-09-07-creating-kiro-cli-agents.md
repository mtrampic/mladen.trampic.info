---
title: "Creating Kiro CLI Agents: Configuration and Validation"
date: 2025-09-07T09:57:00Z
draft: false
tags: ["AWS", "Kiro", "CLI", "AI", "Development Tools"]
categories: ["Development"]
author: "Mladen Trampic & Kiro Developer"
authors: ["mladen-trampic", "kiro"]
description: "Learn how to create and configure custom Kiro CLI agents with proper JSON structure and validation commands."
---

## Introduction

Kiro CLI's agent system allows you to create specialized AI assistants tailored to specific workflows and domains. Instead of using a generic assistant, you can configure agents with custom prompts, tools, and behaviors that understand your project context and requirements. This guide walks through the complete process of creating, configuring, and validating custom Kiro CLI agents, from basic JSON structure to advanced configuration options.

For the official documentation on creating custom agents, see the [Kiro CLI Documentation](https://kiro.dev/docs/cli/custom-agents/creating/).

Whether you're building a blog writing assistant, a code review agent, or a DevOps helper, understanding agent configuration will help you maximize Kiro's effectiveness in your development workflow.

## Agent Configuration Structure

Kiro CLI agents use JSON configuration files with a specific schema. Here are the key fields:

```json
{
  "name": "my-agent",
  "description": "A custom agent for my workflow",
  "tools": ["fs_read", "fs_write", "execute_bash"],
  "allowedTools": ["fs_read"],
  "resources": ["file://README.md", "file://.kiro/steering/**/*.md"],
  "prompt": "You are a helpful coding assistant",
  "model": "claude-sonnet-4"
}
```

### Required Fields

- **name**: Unique identifier for your agent

### Recommended Fields

- **description**: Human-readable description of the agent's purpose (not passed to the model)
- **prompt**: Instructions that define how the agent should behave (supports inline text or `file://` URI)

### Optional Fields

The schema supports many additional optional fields for advanced configuration. For the complete and up-to-date list of all available fields and their descriptions, use the schema command within a Kiro CLI chat session:

```bash
kiro-cli chat --agent your-agent
# Then in the interactive session:
/agent schema
```

This command provides the authoritative JSON schema reference for all supported configuration options, including:
- `$schema`: JSON schema reference
- `mcpServers`: Model Context Protocol server configurations
- `tools`: Specific tools the agent can use
- `toolAliases`: Custom aliases for tools
- `allowedTools`: Whitelist of permitted tools
- `resources`: Additional resources for the agent
- `hooks`: Event hooks for agent lifecycle
- `toolsSettings`: Tool-specific configuration
- `useLegacyMcpJson`: Legacy MCP JSON support flag
- `model`: Specify the AI model to use (e.g., "claude-sonnet-4")

For detailed documentation and examples, refer to the [official Kiro CLI documentation](https://kiro.dev/docs/cli/custom-agents/creating/).

## Creating an Agent

1. **Create the agent directory structure**:
```bash
mkdir -p .kiro/agents
```

2. **Create your agent configuration** in `.kiro/agents/blog-assistant.json`:
```json
{
  "name": "blog-assistant",
  "description": "Specialized agent for blog content creation and management",
  "prompt": "You are a specialized blog assistant for a Hugo-based technical blog. Focus on technical accuracy and comprehensive coverage.",
  "tools": [
    "fs_read",
    "fs_write", 
    "execute_bash"
  ],
  "allowedTools": [
    "fs_read",
    "fs_write",
    "execute_bash"
  ],
  "toolsSettings": {
    "fs_write": {
      "allowedPaths": [
        "content/**",
        "static/**",
        "archetypes/**"
      ]
    }
  }
}
```

## System Prompts and Agent Behavior

The `prompt` field is the most critical part of your agent configuration—it defines the agent's personality, expertise, and behavior patterns. A well-crafted system prompt transforms a generic AI into a specialized assistant.

### Effective System Prompt Structure

For non-trivial prompts, use a `file://` URI pointing to a markdown file. The path is resolved relative to the agent config file's directory (`.kiro/agents/`):

```json
{
  "prompt": "file://../prompts/blog-assistant.md"
}
```

The referenced markdown file can use full formatting:

```markdown
You are a specialized blog co-author assistant working alongside Mladen Trampic
to create high-quality technical content for a Hugo-based blog.

# CO-AUTHORSHIP REQUIREMENT
All content you create is co-authored by Mladen Trampic and Kiro.

# CORE RESPONSIBILITIES
- Research and fact-check technical topics using available documentation
- Create well-structured, engaging blog posts with proper Hugo frontmatter
- Ensure technical accuracy, especially for AWS and cloud-related content

# QUALITY STANDARDS
- Technical accuracy is paramount - verify all technical claims
- Write for both beginners and experienced practitioners
- Include practical examples and code snippets where relevant
```

For simple agents, inline prompts still work:

```json
{
  "prompt": "You are a code review assistant focused on security and performance."
}
```

### System Prompt Best Practices

1. **Define Role and Context**: Clearly state what the agent is and its primary purpose
2. **Set Behavioral Guidelines**: Specify how the agent should interact and respond
3. **Establish Quality Standards**: Define expectations for output quality and accuracy
4. **Include Domain Knowledge**: Reference specific technologies, frameworks, or methodologies
5. **Specify Output Format**: Indicate preferred structures, templates, or formatting

### Integrating Rules with Agent Configuration

Kiro CLI agents can load external rule files using the `resources` field. Resources with `file://` paths are resolved relative to the workspace root and automatically loaded into the agent's context:
```json
{
  "name": "blog-assistant",
  "prompt": "You are a specialized blog assistant for technical content creation.",
  "resources": [
    "file://.kiro/rules/blog-principles.md",
    "file://.kiro/rules/hugo-content.md",
    "file://.kiro/rules/technical-writing.md",
    "file://.kiro/rules/blog-authorship.md"
  ]
}
```

The `resources` field allows agents to directly access rule files as context, making the guidelines immediately available without requiring the agent to read files manually.

This approach offers several advantages:
- **Maintainability**: Update rules without modifying agent configuration
- **Reusability**: Share rules across multiple agents
- **Version Control**: Track rule changes independently
- **Collaboration**: Team members can contribute to rules without touching agent configs
- **Direct Access**: Resources are automatically loaded into agent context

## Agent Hooks: Adding Contextual Intelligence

Hooks are one of Kiro CLI's most powerful features, allowing agents to automatically gather project context by running shell commands at specific trigger points. The output of these commands is injected into the agent's context, making it aware of your project's current state.

### Hook Triggers

Kiro CLI supports five hook triggers:

- **`agentSpawn`**: Runs when the agent starts, providing initial context
- **`userPromptSubmit`**: Runs before each user message, ensuring fresh context
- **`preToolUse`**: Runs before a tool executes — can block the tool (exit code 2)
- **`postToolUse`**: Runs after a tool executes, with access to the tool's output
- **`stop`**: Runs when the assistant finishes responding — can force continuation

### Practical Hook Examples

Here's how to add intelligent context gathering to your blog assistant:

```json
{
  "hooks": {
    "agentSpawn": [
      {
        "command": "git status --porcelain"
      },
      {
        "command": "find content/posts -name '*.md' -mtime -7 | head -5"
      }
    ],
    "userPromptSubmit": [
      {
        "command": "hugo list drafts",
        "timeout_ms": 5000,
        "cache_ttl_seconds": 60
      }
    ]
  }
}
```

### Hook Configuration Options

Each hook command supports these optional parameters:

- **`timeout_ms`**: Maximum execution time (default: 30,000ms)
- **`max_output_size`**: Maximum output size in bytes (default: 10KB)
- **`cache_ttl_seconds`**: Cache duration to avoid repeated execution (default: 0)

### Benefits for Blog Projects

Hooks transform your agent from reactive to proactive:

1. **Git Awareness**: Knows which files are modified, staged, or uncommitted
2. **Content Discovery**: Sees recent posts to maintain consistency and avoid duplicates
3. **Draft Management**: Tracks current drafts and their status
4. **Project State**: Understands Hugo build status and configuration

### Example Interaction

With hooks enabled, your conversations become more intelligent:

```bash
You: "Create a new post about Docker containers"

Agent: "I see you have 2 draft posts and recently worked on 'kubernetes-basics.md'. 
Should this Docker post complement that series? Also, I notice you have uncommitted 
changes in content/posts/ - would you like me to help organize those first?"
```

### Performance Considerations

- Use `cache_ttl_seconds` to prevent expensive commands from running repeatedly
- Set appropriate `timeout_ms` for commands that might hang
- Keep hook commands lightweight and fast-executing
- Consider the frequency of `userPromptSubmit` hooks in long conversations

## Validation Commands

Kiro CLI provides built-in validation for agent configurations:

```bash
# Get complete schema information
kiro-cli chat --agent your-agent
# Then in the interactive session:
/agent schema

# Validate agent configuration
kiro-cli agent validate --path .kiro/agents/your-agent.json

# List available agents (run from project directory)
kiro-cli agent list

# Check Kiro CLI version
kiro-cli --version

# Get help for agent commands
kiro-cli agent --help
```

## Common Issues

**JSON only**: Agent configurations must be in JSON format. The CLI does not support YAML for agent configs.

**Prompt file:// resolution**: The `prompt` field's `file://` URIs resolve relative to the agent config file's directory (`.kiro/agents/`), not the workspace root. Use `../` to reach files outside the agents directory (e.g., `file://../prompts/my-prompt.md`).

**Resources file:// resolution**: Unlike `prompt`, the `resources` field resolves `file://` paths relative to the workspace root. So `file://.kiro/steering/*.md` works correctly from any agent.

**Agent Discovery**: Kiro CLI discovers workspace agents from the `.kiro/agents/` directory and global agents from `~/.kiro/agents/`. Place agent files in these standard locations.

**Tool Permissions**: Include tools in both `tools` and `allowedTools` arrays. The `tools` list controls visibility; `allowedTools` controls auto-approval without user confirmation. Use `toolsSettings` to restrict file operations to safe paths.

## Testing Your Agent

Once configured and validated, test your agent by starting a chat session:

```bash
kiro-cli chat --agent blog-assistant
```

Or if you've set it as your default agent:

```bash
kiro-cli chat
```

The CLI will use your specified agent or allow you to select from available agents.

## Subagents: Delegating Specialized Work

Agents can invoke other agents as tools using the `subagent` built-in. This enables a modular architecture where a primary agent delegates specialized tasks to focused subagents.

Configure subagent access in `toolsSettings`:

```json
{
  "tools": ["fs_read", "fs_write", "execute_bash", "subagent"],
  "toolsSettings": {
    "subagent": {
      "trustedAgents": ["aws-fact-checker"],
      "availableAgents": ["aws-fact-checker"]
    }
  }
}
```

- **`availableAgents`**: Which agents can be invoked (supports glob patterns like `"test-*"`)
- **`trustedAgents`**: Which agents are auto-approved without user confirmation

The subagent itself is a regular agent config in `.kiro/agents/` with its own tools, MCP servers, and prompt. This pattern keeps each agent focused and avoids loading unnecessary MCP servers into the parent agent's context.

## Additional Resources

For deeper insights into Kiro agents and advanced configurations, check out these resources:

- **[Kiro CLI Custom Agents Documentation](https://kiro.dev/docs/cli/custom-agents/creating/)** - Official documentation for creating and configuring custom agents.

## Conclusion

Custom Kiro CLI agents transform generic AI assistance into specialized, context-aware helpers tailored to your specific workflows. By understanding the JSON configuration structure and validation process, you can create agents that understand your project requirements and provide more relevant assistance. Start with simple configurations and gradually add advanced features like custom tools and MCP servers as your needs evolve.

**Want to see this in action?** Check out the complete project structure and agent configurations used for this blog at: https://github.com/mtrampic/mladen.trampic.info

Next steps: experiment with different prompt strategies, explore MCP server integration, and consider creating multiple agents for different aspects of your development workflow.

---

*This post was co-authored by Mladen Trampic and Kiro, demonstrating the collaborative approach to technical content creation.*
