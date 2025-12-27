# Enhanced Blog Co-Author Agent System

This directory contains a sophisticated Kiro CLI agent system designed for collaborative blog content creation, based on patterns reverse-engineered from advanced agent configurations.

## System Overview

The blog co-author agent system combines human expertise with AI-enhanced research, writing, and validation capabilities to create high-quality technical content for a Hugo-based blog.

## Key Components

### 1. Agent Configuration (`agents/blog-assistant.json`)
- **Schema-validated JSON configuration** following Kiro CLI v1 schema
- **MCP server integrations** for research and documentation access
- **Tool restrictions and permissions** for secure content creation
- **Resource access patterns** for rules and project intelligence
- **Hooks for automated operations** and validation

### 2. Content Guidelines (`rules/`)
- **`hugo-content.md`**: Comprehensive Hugo-specific content guidelines
- **`technical-writing.md`**: Technical writing standards and best practices
- **`blog-authorship.md`**: Co-authorship requirements and transparency rules

### 3. Project Intelligence (`project-intelligence/`)
- **`blog-architecture.md`**: Technical architecture and stack documentation
- **`content-strategy.md`**: Content strategy, audience, and quality standards

### 4. Validation System (`hooks/`)
- **`content-validation.sh`**: Automated content quality and structure validation
- Frontmatter validation with co-authorship verification
- Hugo build testing and content structure checks

### 5. Enhanced Configuration (`config.json`)
- Trust policies for MCP servers
- Content validation settings
- Hugo-specific configurations
- Default context and resource access

## Features

### MCP Server Integrations
- **Context7**: Research and documentation lookup capabilities
- **AWS Documentation**: Official AWS documentation access for technical accuracy
- **Trusted server policies**: Secure, pre-approved tool access

### Content Creation Capabilities
- **Structured content creation** following Hugo conventions
- **Automated frontmatter generation** with proper co-authorship
- **Technical accuracy verification** through documentation lookup
- **SEO optimization** with meta descriptions and tag management

### Quality Assurance
- **Automated validation hooks** for content quality
- **Co-authorship verification** ensuring transparency
- **Hugo build testing** before publication
- **Content structure validation** for consistency

### Security and Permissions
- **Restricted file system access** to content directories only
- **Tool allowlisting** for secure operations
- **Trusted MCP server policies** for external integrations
- **Resource access controls** for sensitive configurations

## Usage

### Starting the Agent
```bash
q chat --agent blog-assistant
```

### Creating New Content
The agent will:
1. Research topics using available documentation tools
2. Create structured content with proper frontmatter
3. Ensure co-authorship attribution
4. Validate content quality and Hugo compatibility
5. Assist with SEO optimization and technical accuracy

### Content Validation
Run manual validation:
```bash
./.amazonq/hooks/content-validation.sh
```

### Available Tools
- **File Operations**: Read/write content files
- **Research**: Context7 and AWS documentation lookup
- **Build Testing**: Hugo build validation
- **Git Operations**: Version control integration

## Configuration Details

### Agent Capabilities
- **Research and fact-checking** using official documentation
- **Content structure optimization** for Hugo static sites
- **Technical accuracy verification** especially for AWS content
- **SEO best practices** implementation
- **Accessibility compliance** checking

### Tool Restrictions
- File system access limited to `content/`, `static/`, `archetypes/`
- MCP servers configured with trusted policies
- Automated approval for trusted tools
- Resource access to rules and project intelligence

### Validation Rules
- Required frontmatter fields validation
- Co-authorship attribution verification
- Content structure and heading hierarchy
- Code block language specification
- Hugo build compatibility

## Best Practices

### Content Creation Workflow
1. **Research Phase**: Use documentation tools for accuracy
2. **Structure Phase**: Follow Hugo conventions and guidelines
3. **Writing Phase**: Maintain co-authorship transparency
4. **Validation Phase**: Run automated quality checks
5. **Publication Phase**: Ensure Hugo build success

### Quality Standards
- **Technical Accuracy**: Verify all technical claims
- **Co-Authorship**: Always acknowledge AI assistance
- **SEO Optimization**: Include proper meta descriptions and tags
- **Accessibility**: Follow accessibility best practices
- **Consistency**: Maintain voice and structure consistency

## Troubleshooting

### Common Issues
- **Validation Failures**: Check frontmatter completeness and co-authorship
- **Hugo Build Errors**: Verify content structure and syntax
- **MCP Server Issues**: Check trust policies and server availability
- **Permission Errors**: Verify file system access restrictions

### Validation Fixes
- Add missing frontmatter fields
- Update author field to include co-authorship
- Fix heading hierarchy (avoid H1 in content)
- Add language specifications to code blocks

## Advanced Features

### MCP Server Configuration
- Context7 for research capabilities
- AWS documentation server for technical accuracy
- Configurable trust policies and auto-approval
- Environment variable configuration for servers

### Hook System
- Pre-commit validation hooks
- Content quality assurance
- Automated git operations
- Hugo build verification

### Resource Management
- Structured access to rules and guidelines
- Project intelligence integration
- Content template management
- Configuration file access

## Maintenance

### Regular Updates
- Review and update content guidelines
- Refresh project intelligence documentation
- Update MCP server configurations
- Validate and test hook functionality

### Content Auditing
- Run validation hooks regularly
- Review co-authorship compliance
- Check technical accuracy of existing content
- Update deprecated information

This enhanced blog agent system provides a sophisticated, secure, and efficient platform for collaborative technical content creation, leveraging the best practices observed in advanced Kiro CLI agent configurations.
