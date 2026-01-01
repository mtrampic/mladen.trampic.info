---
title: "Kiro CLI in DevContainer"
date: 2025-08-24T17:00:00+02:00
draft: false
description: "How to use a custom devcontainer with Kiro CLI to streamline blog writing"
tags: ["devcontainer","kiro","hugo","blogging"]
categories: ["DevOps","Tools"]
author: "Mladen Trampic & Kiro"
authors: ["mladen-trampic", "kiro"]
series: []
---

## Introduction

Writing and maintaining a technical blog can be time-consuming—drafting outlines, polishing prose, and generating code snippets all take effort. Kiro CLI is an AI-powered assistant that can help automate many of these writing tasks, from suggesting headlines to drafting detailed explanations. By integrating Kiro CLI directly into a VS Code devcontainer, you get a consistent, reproducible environment preconfigured with everything you need to kick off a new post.

## Main Content

> **Prerequisites & Platform Note**: This guide is written from a macOS perspective. The Kiro CLI credentials configuration shown here is part of the devcontainer setup and may differ on other operating systems. Windows and Linux users may need to adjust credential mounting paths and authentication methods accordingly.

### Setting Up the DevContainer

1. We base our container on a lightweight Ubuntu image and install comprehensive development tools: Hugo (for static site generation), Go, Python, Node.js, AWS CLI, GitHub CLI, and Docker-in-Docker for complete development capabilities.

2. In `.devcontainer/devcontainer.json`, a `postCreateCommand` runs a comprehensive setup that installs Hugo, downloads the appropriate Kiro CLI binary, and configures the development environment:

```json
{
	"name": "Ubuntu",
	"image": "mcr.microsoft.com/devcontainers/base:jammy",
	"features": {
		"ghcr.io/devcontainers/features/aws-cli:1": {},
		"ghcr.io/devcontainers-extra/features/gh-cli:1": {},
		"ghcr.io/devcontainers/features/go:1": {},
		"ghcr.io/devcontainers/features/python:1": {},
		"ghcr.io/devcontainers/features/node:1": {},
		"ghcr.io/devcontainers/features/docker-in-docker:2.12.3": {}
	},
	"mounts": [
		"source=${localEnv:HOME}/.aws,target=/home/vscode/.aws,type=bind,consistency=cached",
		"source=${localEnv:HOME}/Library/Application Support/kiro-cli,target=/home/vscode/.local/share/kiro-cli,type=bind,consistency=cached",
		"source=memory-volume,target=/home/vscode/.memory,type=volume"
	],
	"postCreateCommand": "bash -lc 'HUGO_VERSION=0.145.0 && ARCH=$(uname -m) && if [[ $ARCH = aarch64 || $ARCH = arm64 ]]; then HUGO_ARCH=arm64; DOWNLOAD_URL=https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-${ARCH}-linux.zip; else HUGO_ARCH=amd64; DOWNLOAD_URL=https://desktop-release.q.us-east-1.amazonaws.com/latest/kirocli-x86_64-linux.zip; fi && wget -O /tmp/hugo.deb https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_extended_${HUGO_VERSION}_linux-${HUGO_ARCH}.deb && sudo dpkg -i /tmp/hugo.deb && rm /tmp/hugo.deb && sudo mkdir -p /home/vscode/.local/bin && sudo chown -R vscode:vscode /home/vscode/.local && curl --proto \"=https\" --tlsv1.2 -sSf \"$DOWNLOAD_URL\" -o kirocli.zip && unzip -o kirocli.zip && KIRO_CLI_SKIP_SETUP=1 ./kirocli/install.sh && echo \"export PATH=\\\"\\$HOME/.local/bin:\\$PATH\\\"\" >> ~/.bashrc && rm -rf kirocli.zip kirocli && pip install uv && uv tool install ruff && hugo mod get github.com/jpanther/congo/v2@v2.11.0'",
	"forwardPorts": [1313],
	"runArgs": [
		"--privileged",
		"--env-file", ".devcontainer/devcontainer.env"
	]
}
```json

3. We mount the user's AWS credentials and the Kiro CLI config directory into `/home/vscode/.aws` and `/home/vscode/.local/share/kiro-cli` so you can reuse your existing credentials and settings. A memory volume is also mounted for persistent AI context.

### Using Kiro CLI to Write Posts

- In VS Code's integrated terminal (in the devcontainer), run `kiro-cli chat` to start a conversational session. You can ask it to:

  ```
  kiro-cli chat "Generate an outline for a blog post about configuring a Hugo devcontainer with AWS and Kiro CLI."
  ```

- To draft a section directly into your Markdown file, pipe the AI's response:

  ```bash
  kiro-cli chat "Write the Introduction section for my post on Kiro CLI in DevContainer" \
    >> content/posts/2025-08-24-kiro-in-devcontainer.md
  ```

- Use the `kiro-cli` command for exploratory prompts, quick code snippets, and troubleshooting commands without leaving the container.

### Workflow Example

1. Open the project in VS Code. If prompted, reopen in Dev Container.
2. Wait for the container to build and for the `postCreateCommand` to install Hugo, Kiro CLI, and all development tools.
3. Start writing: open a new Markdown file under `content/posts` and interact with Kiro CLI inside the terminal. Kiro will help you craft headings, bullet lists, code blocks, and more.
4. When your draft is ready, run `hugo server --buildDrafts` (container port forwarded to 1313) to preview your site locally.

## Conclusion

By bundling Kiro CLI into your DevContainer, you get an on-demand AI writing partner in every environment. This setup ensures consistency across machines and speeds up the content creation process—freeing you to focus on ideas and technical depth rather than boilerplate writing.

---

*This post was co-authored by Mladen Trampic and Kiro, demonstrating the collaborative approach to technical content creation.*
