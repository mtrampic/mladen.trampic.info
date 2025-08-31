# mladen.trampic.info

Personal blog of Mladen Trampic built with Hugo and the Congo theme.

## Quick Start

### Prerequisites

- [Hugo](https://gohugo.io/installation/) (extended version)
- [Go](https://golang.org/doc/install) (for theme modules)

### Setup

1. Clone this repository
2. Initialize Hugo modules:
   ```bash
   hugo mod init github.com/mladentrampic/mladen.trampic.info
   hugo mod get
   ```

3. Start the development server:
   ```bash
   hugo server -D
   ```

4. Visit `http://localhost:1313` to see your site

### Creating Content

#### New Blog Post
```bash
hugo new content posts/my-new-post/index.md
```

#### New Project
```bash
hugo new content projects/my-project/index.md
```

### Amazon Q CLI Integration

This blog includes Amazon Q CLI rules for easier content management. Simply ask Amazon Q to perform tasks using natural language, and it will follow the defined workflows. To see all available operations, ask Amazon Q "show me available commands" or check `.amazonq/rules/view_commands.md`. The rules system is managed through markdown files in `.amazonq/rules/` - each operation has its own rule file that defines the specific workflow, commands to run, and output formatting, making Amazon Q context-aware of your blog's structure and preferred processes.

Example requests:
- "Create a new blog post about AWS Lambda"
- "Show me all my draft posts"
- "Start the development server"

## Configuration

The main configuration is in `config.yaml`. Key areas to customize:

- **baseURL**: Update to your domain
- **title**: Your site title
- **params.description**: Site description
- **params.social**: Your social media links
- **params.author**: Your author information

## Theme

This site uses the [Congo theme](https://jpanther.github.io/congo/) for Hugo. The theme is loaded as a Hugo module for easy updates.

## Deployment

The site can be deployed to various platforms:

- **GitHub Pages**: Push to a GitHub repository with GitHub Actions
- **Netlify**: Connect your repository for automatic deployments
- **Vercel**: Import your repository for instant deployments
- **AWS S3**: Use `hugo` command to build and upload to S3

## Content Structure

```
content/
├── _index.md          # Homepage content
├── about/             # About page
├── posts/             # Blog posts
├── projects/          # Project showcase
└── authors/           # Author profiles
```

## Customization

- **Colors**: Modify `params.colorScheme` in config.yaml
- **Layout**: The site uses profile layout for the homepage
- **Custom CSS**: Add styles to `assets/css/custom.css`
- **Images**: Place images in `static/images/`

## License

This blog template is based on the Congo theme and follows its licensing terms. Your content is your own.

---

Happy blogging! 🚀
