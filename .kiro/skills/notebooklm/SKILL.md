---
name: notebooklm
description: Google NotebookLM CLI for deep research, multi-source analysis, and content generation. Use when researching topics, analyzing documents, synthesizing multiple URLs, generating reports, or creating podcasts/videos from research. Activates on research tasks that need multiple sources gathered and cross-referenced.
---

# NotebookLM CLI Reference

Programmatic access to Google NotebookLM — create notebooks, add sources (URLs, YouTube, PDFs, audio, video, images), chat with content, run web research, generate artifacts, and download results.

## Authentication

If commands fail with auth errors, ask the user to run `notebooklm login` interactively.

Verify auth: `notebooklm status` or `notebooklm auth check`

## Quick Reference

| Task | Command |
|------|---------|
| List notebooks | `notebooklm list --json` |
| Create notebook | `notebooklm create "Title" --json` |
| Set context | `notebooklm use <notebook_id>` |
| Show context | `notebooklm status` |
| Add URL source | `notebooklm source add "https://..." --json` |
| Add file | `notebooklm source add ./file.pdf --json` |
| Add YouTube | `notebooklm source add "https://youtube.com/..." --json` |
| List sources | `notebooklm source list --json` |
| Wait for source | `notebooklm source wait <source_id>` |
| Web research (fast) | `notebooklm source add-research "query"` |
| Web research (deep) | `notebooklm source add-research "query" --mode deep --no-wait` |
| Wait for research | `notebooklm research wait --import-all` |
| Chat | `notebooklm ask "question"` |
| Chat (with citations) | `notebooklm ask "question" --json` |
| Chat (specific sources) | `notebooklm ask "question" -s src_id1 -s src_id2` |
| Get source fulltext | `notebooklm source fulltext <source_id>` |
| Generate report | `notebooklm generate report --format blog-post --json` |
| Generate mind map | `notebooklm generate mind-map --json` |
| Generate podcast | `notebooklm generate audio "instructions" --json` |
| Check artifact status | `notebooklm artifact list --json` |
| Wait for artifact | `notebooklm artifact wait <artifact_id>` |
| Download report | `notebooklm download report ./report.md` |
| Download mind map | `notebooklm download mind-map ./map.json` |

Always use `--json` for machine-readable output and parse IDs from responses.

## JSON Output Schemas

```bash
# Create notebook → {"id": "abc123...", "title": "Research"}
# Add source → {"source_id": "def456...", "title": "Example", "status": "processing"}
# Ask with citations → {"answer": "...", "references": [{"source_id": "...", "citation_number": 1, "cited_text": "..."}]}
# Generate → {"task_id": "xyz789...", "status": "pending"}
```

## Research Workflows

### Topic Research (most common for blog writing)

1. `notebooklm create "Research: [topic]" --json` → parse notebook ID
2. `notebooklm use <id>`
3. Add sources: `notebooklm source add "url" --json` for each
4. Wait for indexing: `notebooklm source list --json` until all `status: "ready"`
5. Query: `notebooklm ask "question" --json` → get answer with citations
6. Repeat queries as needed to build understanding

### Deep Web Research

For broad topics needing comprehensive coverage (20+ sources, 2-5 min):

```bash
notebooklm create "Research: [topic]" --json
notebooklm use <id>
notebooklm source add-research "topic query" --mode deep --import-all
# Blocks until research completes and sources are imported
```

For non-blocking: use `--no-wait` then `notebooklm research wait --import-all`

**Mode selection:**
- `--mode fast`: Specific topic, quick overview (5-10 sources, seconds)
- `--mode deep`: Broad topic, comprehensive (20+ sources, 2-5 min)

### Blog Report Generation

After gathering sources, generate a structured blog-ready report:

```bash
notebooklm generate report --format blog-post --append "Focus on practical examples" --json
notebooklm artifact wait <task_id>
notebooklm download report ./research-output.md
```

Report formats: `briefing-doc`, `study-guide`, `blog-post`, `custom`

## Generation Types

| Type | Command | Time | Download |
|------|---------|------|----------|
| Report | `generate report` | 5-15 min | .md |
| Mind Map | `generate mind-map` | instant | .json |
| Data Table | `generate data-table` | 5-15 min | .csv |
| Podcast | `generate audio` | 10-20 min | .mp3 |
| Video | `generate video` | 15-45 min | .mp4 |
| Slide Deck | `generate slide-deck` | 5-15 min | .pdf/.pptx |
| Quiz | `generate quiz` | 5-15 min | .json/.md |
| Flashcards | `generate flashcards` | 5-15 min | .json/.md |
| Infographic | `generate infographic` | 5-15 min | .png |

Audio formats: `--format [deep-dive|brief|critique|debate]`
Video styles: `--style [auto|classic|whiteboard|kawaii|anime|watercolor]`

## Error Handling

| Error | Cause | Action |
|-------|-------|--------|
| Auth/cookie error | Session expired | Ask user to run `notebooklm login` |
| "No notebook context" | Context not set | Run `notebooklm use <id>` |
| Rate limiting | Google API limit | Wait 5-10 min, retry |
| Download fails | Generation incomplete | Check `artifact list --json` for status |

Exit codes: 0 = success, 1 = error, 2 = timeout (wait commands)

## Source Types

PDFs, YouTube URLs, web URLs, Google Docs, text files, Markdown, Word docs, audio, video, images.

Source limits vary by plan: Standard 50, Plus 100, Pro 300, Ultra 600 per notebook.

## Parallel Safety

Use explicit notebook IDs (`-n <id>`) instead of `notebooklm use` when running in parallel workflows.
