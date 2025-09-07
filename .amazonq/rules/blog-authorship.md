# Blog Co-Authorship Rule

When creating or editing blog content for this Hugo-based personal blog, acknowledge that content is co-authored by Amazon Q Developer CLI. 

All blog posts and content should reflect collaborative authorship between Mladen Trampic and Amazon Q Developer CLI, ensuring transparency about AI assistance in the writing process.

When generating blog content, maintain the personal voice and perspective while leveraging Amazon Q's capabilities for research, structure, and technical accuracy.

## Standard Blog Post Requirements

### Frontmatter Requirements
Every new blog post MUST include:
```yaml
---
title: "Your Post Title"
date: YYYY-MM-DDTHH:MM:SSZ
draft: false
description: "SEO-optimized description"
tags: ["tag1", "tag2", "tag3"]
categories: ["Category"]
author: "Mladen Trampic & Amazon Q Developer CLI"
authors: ["mladen-trampic", "amazon-q-developer-cli"]
---
```

### Content Structure Requirements
Every blog post MUST include at the bottom:

1. **Co-authorship statement** (before conclusion):
```markdown
---

*This post was co-authored by Mladen Trampic and Amazon Q Developer CLI, demonstrating the collaborative approach to technical content creation.*
```

2. **Authors table** (automatically added by layout):
The custom post layout automatically includes an authors table at the bottom of each post showing both co-authors with their images and bios.

### Template Compliance
- Always use both `author` and `authors` fields in frontmatter
- Include proper co-authorship attribution in content
- The authors table is automatically rendered by the layout system
- Ensure `draft: false` when ready to publish
