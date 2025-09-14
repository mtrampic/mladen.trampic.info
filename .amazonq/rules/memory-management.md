# Blog Memory Management Rules

## Entity Types
- `blog_post`: Individual posts with metadata
- `topic`: Technical subjects (AWS, DevOps, etc.)
- `technology`: Specific tools (Hugo, Docker, Amazon Q)
- `user_preference`: Writing style and content preferences
- `series`: Related post collections
- `concept`: Technical explanations and patterns

## Storage Rules
- Store every new blog post with title, date, tags, and summary
- Remember user preferences about tone, style, and target audience
- Track technology versions and configurations used
- Create relationships between related posts and topics
- Store successful content patterns and structures

## Retrieval Rules
- Always check memory at conversation start: "Remembering previous context..."
- Search for related posts when planning new content
- Retrieve user preferences to maintain consistency
- Look up previous topic coverage to avoid duplication
- Find related technologies for comprehensive coverage

## Relationship Patterns
- `blog_post covers_topic topic_name`
- `blog_post uses_technology tech_name`
- `blog_post part_of_series series_name`
- `topic relates_to technology`
- `user prefers_style style_description`

## Memory Update Protocol
When creating or discussing blog content:
1. Create entities for new posts, topics, and technologies
2. Add observations about successful patterns and user feedback
3. Create relations between posts, topics, and technologies
4. Update observations when posts are modified or published
5. Store user preferences and writing style choices

## Example Memory Entries

### Blog Post Entity
```json
{
  "name": "amazon_q_cli_agents_post",
  "entityType": "blog_post",
  "observations": [
    "Published on 2025-09-07",
    "Covers Amazon Q CLI configuration",
    "Technical tutorial format",
    "Includes JSON examples",
    "Well-received by readers"
  ]
}
```

### User Preference Entity
```json
{
  "name": "mladen_writing_style",
  "entityType": "user_preference",
  "observations": [
    "Prefers technical accuracy over simplicity",
    "Likes practical examples with code",
    "Targets both beginners and experts",
    "Uses co-authorship with Amazon Q",
    "Focuses on AWS and DevOps topics"
  ]
}
```

### Technology Entity
```json
{
  "name": "amazon_q_cli",
  "entityType": "technology",
  "observations": [
    "Version used: latest",
    "Key features: agents, MCP servers, hooks",
    "Configuration via JSON files",
    "Supports custom prompts and tools"
  ]
}
```

## Relations Examples
- `amazon_q_cli_agents_post covers_topic amazon_q_configuration`
- `amazon_q_cli_agents_post uses_technology amazon_q_cli`
- `mladen_writing_style prefers_format technical_tutorial`
- `amazon_q_cli relates_to devops_tools`
