---
description: Generate standup notes from recent git activity and Claude sessions
---

Argument: $ARGUMENTS

Generate standup notes based on recent work.

## Steps

1. **Get recent commits** (last 24h or since last standup):
```bash
git log --all --oneline --since="24 hours ago" --author="$(git config user.email)"
```

2. **Get active branches**:
```bash
git branch -v --sort=-committerdate | head -5
```

3. **Check PR status**:
```bash
gh pr list --author @me --state all --limit 10
```

4. **Analyze Claude sessions** (if available):
```bash
find ~/.claude/projects -name "*.jsonl" -mtime -1 2>/dev/null
```

5. **Format standup**:

```markdown
## Standup - [DATE]

### Yesterday
- [Completed work from commits and sessions]

### Today
- [Planned work based on open PRs and incomplete tasks]

### Blockers
- [Any identified blockers from PR reviews or failed builds]
```

## Arguments

- `--days <n>`: Look back n days (default: 1)
- `--team`: Include team PR reviews and mentions
