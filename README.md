# Mladen Trampic's Technical Blog

A Hugo-based technical blog featuring co-authored content created through collaboration between human expertise and Amazon Q Developer AI assistance.

## Co-Authoring Workflow with Amazon Q CLI

This blog demonstrates an innovative approach to technical content creation using Amazon Q CLI as a co-authoring partner. All blog posts are collaboratively written, combining human perspective with AI-enhanced research, structure, and technical accuracy.

### Key Features

- **AI-Enhanced Writing**: Amazon Q CLI assists with research, content structure, and technical validation
- **Consistent Quality**: Automated content validation and Hugo build checks via git hooks
- **DevContainer Environment**: Reproducible development setup with all tools pre-configured
- **Rule-Based Guidelines**: Structured content principles maintained in `.amazonq/rules/`

## Getting Started

### Prerequisites

- **macOS** (this setup is optimized for macOS users)
- **Docker Desktop** or compatible container runtime
- **VS Code** with Dev Containers extension
- **Git** for version control

### Setup Instructions

1. **Clone the repository**:
   ```bash
   git clone https://github.com/mtrampic/mladen.trampic.info.git
   cd mladen.trampic.info
   ```

2. **Open in VS Code**:
   ```bash
   code .
   ```

3. **Reopen in Dev Container**:
   - VS Code will prompt to "Reopen in Container"
   - Or use Command Palette: `Dev Containers: Reopen in Container`

4. **Wait for container setup**:
   - The devcontainer will automatically install Hugo, AWS CLI, and Amazon Q CLI
   - Amazon Q CLI credentials are mounted from your macOS `~/Library/Application Support/amazon-q`

## DevContainer Configuration

The `.devcontainer/devcontainer.json` provides a complete development environment:

### Base Setup
- **Ubuntu Jammy** base image
- **Hugo** static site generator
- **Go** runtime (required by Hugo)
- **AWS CLI** for cloud integrations
- **GitHub CLI** for repository management

### Amazon Q CLI Integration
- Automatically downloads and installs Amazon Q CLI based on system architecture (ARM64/x86_64)
- Mounts macOS credentials from `~/Library/Application Support/amazon-q`
- Creates `q` alias pointing to `qchat` for easy access
- Port forwarding for Hugo development server (1313)

### Credential Mounting (macOS Specific)
```json
"mounts": [
  "source=${localEnv:HOME}/.aws,target=/home/vscode/.aws,type=bind,consistency=cached",
  "source=${localEnv:HOME}/Library/Application Support/amazon-q,target=/home/vscode/.local/share/amazon-q,type=bind,consistency=cached"
]
```

## Content Creation Workflow

### Using Amazon Q CLI for Co-Authoring

1. **Start a chat session**:
   ```bash
   q chat --agent blog-assistant
   ```

2. **Generate content ideas**:
   ```bash
   q "Generate an outline for a blog post about [topic]"
   ```

3. **Create structured content**:
   ```bash
   q "Write the introduction section for my post on [topic]" >> content/posts/new-post.md
   ```

4. **Research and validate**:
   - Amazon Q CLI accesses documentation and validates technical accuracy
   - Follows content guidelines defined in `.amazonq/rules/`

### Local Development

1. **Start Hugo development server**:
   ```bash
   hugo server --buildDrafts
   ```

2. **Preview at**: http://localhost:1313

3. **Create new posts**:
   ```bash
   hugo new posts/YYYY-MM-DD-post-title.md
   ```

## Content Guidelines

All content follows structured principles defined in:

- **`.amazonq/rules/blog-principles.md`** - Core content creation standards
- **`.amazonq/rules/hugo-content.md`** - Hugo-specific formatting guidelines  
- **`.amazonq/rules/technical-writing.md`** - Technical accuracy and style standards
- **`.amazonq/rules/blog-authorship.md`** - Co-authorship attribution requirements

## Publishing Process

1. **Content validation** runs automatically via git hooks
2. **Hugo build verification** ensures site integrity
3. **Automated deployment** triggers on push to main branch

### Manual Publishing

```bash
# Change draft: true to draft: false in frontmatter
# Then commit and push
git add .
git commit -m "Publish: [Post Title]"
git push origin main
```

## Project Structure

```
├── .amazonq/
│   ├── cli-agents/          # Amazon Q CLI agent configurations
│   └── rules/               # Content creation guidelines
├── .devcontainer/           # VS Code devcontainer configuration
├── content/
│   └── posts/               # Blog post content
├── static/                  # Static assets
├── themes/                  # Hugo theme (Congo)
└── config.yaml             # Hugo site configuration
```

## Technology Stack

- **Hugo** - Static site generator
- **Congo Theme** - Modern, responsive Hugo theme
- **Amazon Q CLI** - AI-powered development assistant
- **GitHub Actions** - Automated deployment
- **VS Code Dev Containers** - Consistent development environment

## Contributing

This is a personal blog, but the co-authoring workflow and devcontainer setup can serve as a template for others interested in AI-enhanced content creation.

---

*All content is co-authored by Mladen Trampic and Amazon Q Developer, demonstrating the collaborative potential of human-AI content creation.*
