# Hugo Content Guidelines

## Core Principles

All blog content is co-authored by Mladen Trampic and Amazon Q Developer. This collaborative approach ensures both personal perspective and AI-enhanced research, structure, and technical accuracy.

## Frontmatter Requirements

Every blog post must include proper Hugo frontmatter with these required fields:

```yaml
---
title: "Descriptive and SEO-Optimized Title"
date: 2025-MM-DDTHH:MM:SSZ
draft: false
description: "Compelling meta description (150-160 characters)"
tags: ["tag1", "tag2", "tag3"]
categories: ["Category"]
author: "Mladen Trampic & Amazon Q Developer"
---
```

### Frontmatter Field Guidelines

- **title**: Clear, descriptive, and SEO-optimized (50-60 characters)
- **date**: ISO 8601 format with timezone
- **draft**: Set to `false` for published content
- **description**: Compelling meta description for SEO (150-160 characters)
- **tags**: Relevant, specific tags (3-7 tags recommended)
- **categories**: Broad categorization (1-2 categories)
- **author**: Always "Mladen Trampic & Amazon Q Developer"

## Content Structure

### Standard Blog Post Structure

1. **Introduction** (100-200 words)
   - Hook the reader with a compelling opening
   - Clearly state what the post will cover
   - Mention any prerequisites or target audience

2. **Main Content** (800-2000 words)
   - Use clear headings (H2, H3) for organization
   - Include practical examples and code snippets
   - Add relevant images, diagrams, or screenshots
   - Use bullet points and numbered lists for clarity

3. **Conclusion** (100-150 words)
   - Summarize key takeaways
   - Suggest next steps or related topics
   - Include call-to-action if appropriate

### Heading Hierarchy

- Use H1 only for the post title (handled by Hugo template)
- Use H2 for main sections
- Use H3 for subsections
- Use H4 sparingly for detailed breakdowns

## Writing Style

### Voice and Tone
- Professional but approachable
- Technical accuracy without unnecessary jargon
- Explain complex concepts clearly
- Use active voice when possible
- Write in second person ("you") to engage readers

### Technical Content
- Always verify technical accuracy using documentation
- Include working code examples
- Provide context for commands and configurations
- Explain the "why" behind technical decisions
- Include error handling and troubleshooting tips

## Code Snippets

### Formatting
```markdown
```language
// Your code here with proper syntax highlighting
```
```

### Best Practices
- Always specify the language for syntax highlighting
- Include comments explaining complex logic
- Use realistic examples, not just "foo/bar"
- Test code snippets before publishing
- Include file paths or context when relevant

## Images and Media

### Image Guidelines
- Store images in `static/images/posts/YYYY-MM-DD-post-slug/`
- Use descriptive filenames
- Optimize for web (WebP preferred, max 1MB)
- Include alt text for accessibility
- Use captions when helpful

### Image Markdown
```markdown
![Alt text describing the image](/images/posts/2025-01-01-example-post/screenshot.webp)
*Caption explaining the image context*
```

## SEO Optimization

### Content SEO
- Include target keywords naturally in content
- Use descriptive headings with keywords
- Write compelling meta descriptions
- Include internal links to related posts
- Add external links to authoritative sources

### Technical SEO
- Ensure proper heading hierarchy
- Use descriptive URLs (handled by Hugo)
- Include structured data where relevant
- Optimize images with alt text
- Ensure fast loading times

## Accessibility

### Content Accessibility
- Use clear, simple language
- Provide alt text for all images
- Use sufficient color contrast
- Structure content with proper headings
- Include transcripts for video content

### Code Accessibility
- Use semantic HTML in examples
- Include ARIA labels in code snippets
- Explain visual elements in text
- Provide keyboard navigation examples

## Quality Checklist

Before publishing, verify:

- [ ] Frontmatter includes all required fields
- [ ] Co-authorship is properly attributed
- [ ] Technical accuracy has been verified
- [ ] Code snippets are tested and working
- [ ] Images are optimized and have alt text
- [ ] Content follows SEO best practices
- [ ] Accessibility guidelines are met
- [ ] Hugo build completes without errors
- [ ] Content is proofread for grammar and clarity

## Content Types

### Tutorial Posts
- Step-by-step instructions
- Prerequisites clearly stated
- Expected outcomes defined
- Troubleshooting section included

### Technical Deep Dives
- Comprehensive coverage of topic
- Multiple examples and use cases
- Performance considerations
- Best practices and pitfalls

### News and Updates
- Timely and relevant information
- Context for why it matters
- Impact on readers' work
- Links to official sources

### Opinion and Analysis
- Clear statement of perspective
- Supporting evidence and examples
- Acknowledgment of alternative views
- Personal experience and insights
