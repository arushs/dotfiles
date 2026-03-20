---
description: Analyze Claude session logs and generate a daily work summary
---

Argument: $ARGUMENTS

Generate a comprehensive daily summary by analyzing Claude Code session logs.

## Steps

1. **Find today's session logs**:
```bash
find ~/.claude/projects -name "*.jsonl" -mtime -1 2>/dev/null
```

2. **Extract user messages from each session** to understand what was worked on:
```bash
grep '"type":"user"' <session_file> | jq -r '.message.content' 2>/dev/null | head -50
```

3. **Get git branch info** to understand active workstreams:
```bash
grep -h '"gitBranch"' ~/.claude/projects/*/*.jsonl 2>/dev/null | jq -r '.gitBranch' 2>/dev/null | sort -u
```

4. **Compile the summary** with these sections:

### Output Format

```markdown
# Daily Summary - [DATE]

## What You Did Today
[List major work items by project/feature with branch names]

## Dropped / Not Closed Out
| Item | Status | Notes |
|------|--------|-------|
[Items that were started but not completed]

## Needs Testing / Completion
[PRs with failing checks, code that needs verification]

## Blockers
[Build failures, dependencies, review requirements]

## Tomorrow's Potential Tasks
[Follow-up items based on today's work]
```

## Analysis Guidelines

- Group work by project (look at session paths like `-Users-...-project-name`)
- Identify incomplete work by looking for:
  - Sessions that ended with errors or "not working" messages
  - Tasks mentioned but not confirmed complete
  - PRs with failing checks (look for buildkite/github status discussions)
- Extract blockers from error messages and failed operations
- Suggest tomorrow's tasks based on incomplete items and natural follow-ups

## Optional Arguments

- `--project <name>`: Filter to specific project
- `--days <n>`: Look back n days instead of just today (default: 1)
- `--brief`: Output condensed version without details

If no arguments provided, analyze all sessions from today.
