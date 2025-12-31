---
title: "Creating Kiro CLI Agents: Configuration and Validation"
date: 2025-09-07T09:57:00Z
draft: false
tags: ["AWS", "Kiro", "CLI", "AI", "Development Tools"]
categories: ["Development"]
author: "Mladen Trampic & Kiro"
authors: ["mladen-trampic", "kiro"]
description: "Learn how to create and configure custom Kiro CLI agents with proper JSON structure and validation commands."
series: []
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
  "tools": ["read","write"],
  "allowedTools": ["read"],
  "resources": ["file://README.md", "file://.kiro/steering/**/*.md"],
  "prompt": "You are a helpful coding assistant",
  "model": "claude-sonnet-4"
}
```bash

### Required Fields

- **name**: Unique identifier for your agent
- **description**: Human-readable description of the agent's purpose
- **prompt**: Instructions that define how the agent should behave

### Optional Fields

The schema supports many additional optional fields for advanced configuration. For the complete and up-to-date list of all available fields and their descriptions, use the schema command within a Kiro CLI chat session:

```bash
kiro-cli chat --agent your-agent
# Then in the interactive session:
/agent schema
```bash

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
```bash

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
```bash

## System Prompts and Agent Behavior

The `prompt` field is the most critical part of your agent configuration—it defines the agent's personality, expertise, and behavior patterns. A well-crafted system prompt transforms a generic AI into a specialized assistant.

### Effective System Prompt Structure

```json
{
  "prompt": "You are a specialized blog co-author assistant working alongside Mladen Trampic to create high-quality technical content for a Hugo-based blog.\n\n# CO-AUTHORSHIP REQUIREMENT\nAll content you create is co-authored by Mladen Trampic and Kiro.\n\n# CORE RESPONSIBILITIES\n- Research and fact-check technical topics using available documentation\n- Create well-structured, engaging blog posts with proper Hugo frontmatter\n- Ensure technical accuracy, especially for AWS and cloud-related content\n- Follow SEO best practices and content optimization guidelines\n\n# QUALITY STANDARDS\n- Technical accuracy is paramount - verify all technical claims\n- Write for both beginners and experienced practitioners\n- Include practical examples and code snippets where relevant\n- Optimize for search engines while maintaining readability"
}
```bash

### System Prompt Best Practices

1. **Define Role and Context**: Clearly state what the agent is and its primary purpose
2. **Set Behavioral Guidelines**: Specify how the agent should interact and respond
3. **Establish Quality Standards**: Define expectations for output quality and accuracy
4. **Include Domain Knowledge**: Reference specific technologies, frameworks, or methodologies
5. **Specify Output Format**: Indicate preferred structures, templates, or formatting

### Integrating Rules with Agent Configuration

Kiro CLI agents can reference external rule files in two ways:

**Method 1: Reference in System Prompt**
```json
{
  "prompt": "You are a specialized blog assistant. Strictly adhere to all guidelines defined in the `.kiro/rules/` directory, including:\n- blog-principles.md for content quality standards\n- hugo-content.md for Hugo-specific formatting\n- technical-writing.md for writing standards\n- blog-authorship.md for co-authorship requirements"
}
```bash

**Method 2: Direct Resource References**
```json
{
  "name": "blog-assistant",
  "prompt": "You are a specialized blog assistant for technical content creation.",
  "resources": [
    ".kiro/rules/blog-principles.md",
    ".kiro/rules/hugo-content.md", 
    ".kiro/rules/technical-writing.md",
    ".kiro/rules/blog-authorship.md"
  ]
}
```bash

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

Kiro CLI supports two hook triggers:

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
```bash

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
```bash

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
```bash

## Common Issues

**YAML vs JSON**: Agent configurations must be in JSON format, not YAML. The CLI expects JSON despite some documentation suggesting YAML support.

**Field Names**: Use `prompt` instead of `instructions` for the agent's system prompt.

**Agent Discovery**: While you can specify any path in config.json, Kiro CLI has a discovery preference for the `.kiro/agents/` directory. For best compatibility, place agent files in this standard location rather than custom directories.

**Tool Permissions**: Include tools in both `tools` and `allowedTools` arrays. Use `toolsSettings` to restrict file operations to safe paths.

## Testing Your Agent

Once configured and validated, test your agent by starting a chat session:

```bash
kiro-cli chat --agent blog-assistant
```bash

Or if you've set it as your default agent:

```bash
kiro-cli chat
```bash

The CLI will use your specified agent or allow you to select from available agents.

## Additional Resources

For deeper insights into Kiro agents and advanced configurations, check out these AWS blog posts:

- **[Mastering Kiro with Rules](https://aws.amazon.com/blogs/devops/mastering-amazon-q-developer-with-rules/)** - Learn how to create sophisticated rule-based configurations that enhance Kiro's understanding of your codebase and development practices.

- **[Overcome Development Disarray with Kiro CLI Custom Agents](https://aws.amazon.com/blogs/devops/overcome-development-disarray-with-kiro-custom-agents/)** - Explore real-world examples of custom agents that streamline development workflows and reduce context switching.

## Conclusion

Custom Kiro CLI agents transform generic AI assistance into specialized, context-aware helpers tailored to your specific workflows. By understanding the JSON configuration structure and validation process, you can create agents that understand your project requirements and provide more relevant assistance. Start with simple configurations and gradually add advanced features like custom tools and MCP servers as your needs evolve.

**Want to see this in action?** Check out the complete project structure and agent configurations used for this blog at: https://github.com/mtrampic/mladen.trampic.info

Next steps: experiment with different prompt strategies, explore MCP server integration, and consider creating multiple agents for different aspects of your development workflow.

---

*This post was co-authored by Mladen Trampic and Kiro, demonstrating the collaborative approach to technical content creation.*
