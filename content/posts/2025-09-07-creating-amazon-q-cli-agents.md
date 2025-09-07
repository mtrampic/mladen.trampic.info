---
title: "Creating Amazon Q CLI Agents: Configuration and Validation"
date: 2025-09-07T09:57:00Z
draft: false
tags: ["AWS", "Amazon Q", "CLI", "AI", "Development Tools"]
categories: ["Development"]
author: "Mladen Trampic & Amazon Q Developer"
description: "Learn how to create and configure custom Amazon Q CLI agents with proper JSON structure and validation commands."
series: []
---

## Introduction

Amazon Q CLI's agent system allows you to create specialized AI assistants tailored to specific workflows and domains. Instead of using a generic assistant, you can configure agents with custom prompts, tools, and behaviors that understand your project context and requirements. This guide walks through the complete process of creating, configuring, and validating custom Amazon Q CLI agents, from basic JSON structure to advanced configuration options.

Whether you're building a blog writing assistant, a code review agent, or a DevOps helper, understanding agent configuration will help you maximize Amazon Q's effectiveness in your development workflow.

## Agent Configuration Structure

Amazon Q CLI agents use JSON configuration files with a specific schema. Here are the key fields:

```json
{
  "name": "your-agent-name",
  "description": "Brief description of what your agent does",
  "prompt": "System prompt that defines the agent's behavior and context"
}
```

### Required Fields

- **name**: Unique identifier for your agent
- **description**: Human-readable description of the agent's purpose
- **prompt**: Instructions that define how the agent should behave

### Optional Fields

The schema also supports these optional fields:
- `$schema`: JSON schema reference
- `mcpServers`: Model Context Protocol server configurations
- `tools`: Specific tools the agent can use
- `toolAliases`: Custom aliases for tools
- `allowedTools`: Whitelist of permitted tools
- `resources`: Additional resources for the agent
- `hooks`: Event hooks for agent lifecycle
- `toolsSettings`: Tool-specific configuration
- `useLegacyMcpJson`: Legacy MCP JSON support flag

For the complete and up-to-date list of all available fields, refer to the [official agent schema](https://github.com/aws/amazon-q-developer-cli/blob/main/schemas/agent-v1.json) in the Amazon Q CLI repository.

## Creating an Agent

1. **Create the agent directory structure**:
```bash
mkdir -p .amazonq/agents
```

2. **Create your agent configuration**:
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

3. **Update the main configuration** in `.amazonq/config.json`:
```json
{
  "agents": {
    "blog-assistant": {
      "config_path": ".amazonq/agents/blog-assistant.json",
      "trust_policy": "trusted",
      "auto_approve_tools": true
    }
  },
  "default_agent": "blog-assistant"
}
```

## Agent Hooks: Adding Contextual Intelligence

Hooks are one of Amazon Q CLI's most powerful features, allowing agents to automatically gather project context by running shell commands at specific trigger points. The output of these commands is injected into the agent's context, making it aware of your project's current state.

### Hook Triggers

Amazon Q CLI supports two hook triggers:

- **`agentSpawn`**: Runs when the agent starts, providing initial context
- **`userPromptSubmit`**: Runs before each user message, ensuring fresh context

### Practical Hook Examples

Here's how to add intelligent context gathering to your blog assistant:

```json
{
  "hooks": {
    "agentSpawn": [
      {
        "command": "git status --porcelain",
        "cache_ttl_seconds": 30
      },
      {
        "command": "find content/posts -name '*.md' -mtime -7 | head -5",
        "cache_ttl_seconds": 300
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

```
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

Amazon Q CLI provides built-in validation for agent configurations:

```bash
# Validate agent configuration
q agent validate --path .amazonq/agents/your-agent.json

# List available agents (run from project directory)
q agent list

# Check Q CLI version
q --version

# Get help for agent commands
q agent --help
```

## Common Issues

**YAML vs JSON**: Agent configurations must be in JSON format, not YAML. The CLI expects JSON despite some documentation suggesting YAML support.

**Field Names**: Use `prompt` instead of `instructions` for the agent's system prompt.

**Local Discovery**: Local agents are only discovered when running commands from the directory containing them.

**Tool Permissions**: Include tools in both `tools` and `allowedTools` arrays. Use `toolsSettings` to restrict file operations to safe paths.

## Testing Your Agent

Once configured and validated, test your agent by starting a chat session:

```bash
q chat --agent blog-assistant
```

Or if you've set it as your default agent:

```bash
q chat
```

The CLI will use your specified agent or allow you to select from available agents.

## Additional Resources

For deeper insights into Amazon Q Developer agents and advanced configurations, check out these AWS blog posts:

- **[Mastering Amazon Q Developer with Rules](https://aws.amazon.com/blogs/devops/mastering-amazon-q-developer-with-rules/)** - Learn how to create sophisticated rule-based configurations that enhance Amazon Q's understanding of your codebase and development practices.

- **[Overcome Development Disarray with Amazon Q Developer CLI Custom Agents](https://aws.amazon.com/blogs/devops/overcome-development-disarray-with-amazon-q-developer-cli-custom-agents/)** - Explore real-world examples of custom agents that streamline development workflows and reduce context switching.

## Conclusion

Custom Amazon Q CLI agents transform generic AI assistance into specialized, context-aware helpers tailored to your specific workflows. By understanding the JSON configuration structure and validation process, you can create agents that understand your project requirements and provide more relevant assistance. Start with simple configurations and gradually add advanced features like custom tools and MCP servers as your needs evolve.

Next steps: experiment with different prompt strategies, explore MCP server integration, and consider creating multiple agents for different aspects of your development workflow.

---

*This post was co-authored by Mladen Trampic and Amazon Q Developer, demonstrating the collaborative approach to technical content creation.*
