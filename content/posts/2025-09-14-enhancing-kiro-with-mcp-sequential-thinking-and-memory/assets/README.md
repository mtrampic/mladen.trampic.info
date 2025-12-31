---
title: "MCP Demo Assets"
date: 2025-09-14T10:36:00Z
draft: false
description: "Supporting assets for MCP sequential thinking and memory demo"
tags: ["assets", "demo"]
categories: ["Development"]
author: "Mladen Trampic & Kiro"
authors: ["mladen-trampic", "kiro"]
---

## MCP Sequential Thinking Demo Assets

This directory contains the Python scripts and setup instructions to replicate the performance optimization example from the blog post "Enhancing Kiro with MCP: Sequential Thinking and Memory Tools".

## Files

- `slow_script.py` - Original slow script with individual database queries
- `fast_script_agentic_after_profiling.py` - Optimized script after MCP agent analysis
- `create_test_data.py` - Database setup and test data generation

## Prerequisites

- Docker
- Python 3.x
- `mysql-connector-python` package

## Setup Instructions

### 1. Start MySQL Database

```bash
docker run --name test-mysql \
  -e MYSQL_ROOT_PASSWORD=testpass \
  -e MYSQL_DATABASE=testdb \
  -p 3306:3306 \
  -d mysql:8.0
```bash

### 2. Install Python Dependencies

```bash
pip install mysql-connector-python
```bash

### 3. Create Test Data

```bash
python create_test_data.py
```bash

This creates 1 million test records in the database.

### 4. Run Performance Tests

**Test the slow script:**
```bash
python slow_script.py
```bash

**Profile the slow script:**
```bash
python -m cProfile -s cumulative slow_script.py
```bash

**Test the optimized script:**
```bash
python fast_script_agentic_after_profiling.py
```bash

## Expected Results

- **Slow script**: ~1.32 seconds for 10,000 records
- **Optimized script**: ~0.02 seconds for 10,000 records
- **Performance improvement**: ~60x faster

## MCP Agent Workflow Demonstration

This example demonstrates how an MCP agent with sequential thinking would:

1. **Analyze the problem** systematically
2. **Use cProfile** to identify bottlenecks
3. **Find root cause** (N+1 query problem)
4. **Implement optimization** (batch queries)
5. **Measure results** (60x improvement)

## Cleanup

```bash
docker stop test-mysql
docker rm test-mysql
```bash

## Testing with MCP Demo Assistant

To test this workflow with the MCP demo assistant:

```bash
q chat --agent mcp-demo-assistant
```bash

Then ask: *"My Python script slow_script.py is processing records slowly. Help me optimize it."*

The agent should use sequential thinking to conclude that profiling is needed first, then run cProfile to identify the database query bottleneck.
