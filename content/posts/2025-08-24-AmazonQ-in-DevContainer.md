---
title: "Amazon Q in DevContainer"
date: 2025-08-24T17:00:00+02:00
draft: false
description: "How to use a custom devcontainer with Amazon Q to streamline blog writing"
tags: ["devcontainer","amazon-q","hugo","blogging"]
categories: ["DevOps","Tools"]
author: "Mladen Trampic & Amazon Q Developer CLI"
authors: ["mladen-trampic", "amazon-q-developer-cli"]
series: []
---

## Amazon Q in DevContainer

## Introduction

Writing and maintaining a technical blog can be time-consuming—drafting outlines, polishing prose, and generating code snippets all take effort. Amazon Q is an AI-powered assistant that can help automate many of these writing tasks, from suggesting headlines to drafting detailed explanations. By integrating Amazon Q directly into a VS Code devcontainer, you get a consistent, reproducible environment preconfigured with everything you need to kick off a new post.

## Main Content

> **Prerequisites & Platform Note**: This guide is written from a macOS perspective. The Amazon Q CLI credentials configuration shown here is part of the devcontainer setup and may differ on other operating systems. Windows and Linux users may need to adjust credential mounting paths and authentication methods accordingly.

### Setting Up the DevContainer

1. We base our container on a lightweight Ubuntu image and install common tools: Hugo (for static site generation), Go (needed by Hugo), the AWS CLI, and Amazon Q.
2. In `.devcontainer/devcontainer.json`, a `postCreateCommand` runs a shell snippet that detects the CPU architecture, downloads the appropriate Amazon Q binary, unpacks it, and installs `q` and `qchat` into `/usr/local/bin`.
```bash
{
	"name": "Ubuntu",
	"image": "mcr.microsoft.com/devcontainers/base:jammy",
	"features": {
		"ghcr.io/devcontainers/features/aws-cli:1": {},
		"ghcr.io/devcontainers-extra/features/gh-cli:1": {},
		"ghcr.io/devcontainers/features/go:1": {}
	},
	"mounts": [
		"source=${localEnv:HOME}/.aws,target=/home/vscode/.aws,type=bind,consistency=cached",
		"source=${localEnv:HOME}/Library/Application Support/amazon-q,target=/home/vscode/.local/share/amazon-q,type=bind,consistency=cached"

	],
	"postCreateCommand": "bash -lc 'ARCH=$(uname -m) && if [[ $ARCH = aarch64 || $ARCH = arm64 ]]; then DOWNLOAD_URL=https://desktop-release.q.us-east-1.amazonaws.com/latest/q-${ARCH}-linux.zip; else DOWNLOAD_URL=https://desktop-release.q.us-east-1.amazonaws.com/latest/q-x86_64-linux.zip; fi && curl --proto \"=https\" --tlsv1.2 -sSf \"$DOWNLOAD_URL\" -o q.zip && unzip q.zip && sudo mv q/bin/q* /usr/local/bin/ && rm -rf q.zip q && echo \"alias q=\\\"/usr/local/bin/qchat\\\"\" >> ~/.bashrc ~/.bash_profile ~/.zshrc ~/.profile'",
	"forwardPorts": [1313]
}
```json
3. We mount the user’s AWS credentials and the Amazon Q config directory into `/home/vscode/.aws` and `/home/vscode/.local/share/amazon-q` so you can reuse your existing credentials and settings.

### Using Amazon Q to Write Posts

- In VS Code’s integrated terminal (in the devcontainer), run `qchat` to start a conversational session. You can ask it to:

  ```bash
  qchat "Generate an outline for a blog post about configuring a Hugo devcontainer with AWS and Amazon Q."
  ```

- To draft a section directly into your Markdown file, pipe the AI’s response:

  ```bash
  qchat "Write the Introduction section for my post on Amazon Q in DevContainer" \
    >> content/posts/2025-08-24-AmazonQ-in-DevContainer.md
  ```

- Use the `q` alias (which points to `qchat`) for exploratory prompts, quick code snippets, and troubleshooting commands without leaving the container.

### Workflow Example

1. Open the project in VS Code. If prompted, reopen in Dev Container.
2. Wait for the container to build and for the `postCreateCommand` to install Amazon Q.
3. Start writing: open a new Markdown file under `content/posts` and interact with Q inside the terminal. Q will help you craft headings, bullet lists, code blocks, and more.
4. When your draft is ready, run `hugo server` (container port forwarded to 1313) to preview your site locally.

## Conclusion

By bundling Amazon Q into your DevContainer, you get an on-demand AI writing partner in every environment. This setup ensures consistency across machines and speeds up the content creation process—freeing you to focus on ideas and technical depth rather than boilerplate writing.

---

*This post was co-authored with Amazon Q Developer, combining human expertise with AI assistance for technical accuracy and comprehensive coverage.*

