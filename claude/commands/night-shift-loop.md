# Night Shift Loop

Start the Night Shift autonomous loop using `/loop`. Each cycle picks and completes one spec from `./Specs/`.

---

## Execution

1. Verify `./Specs/` exists. If not, output the setup instructions below and stop.
2. Count available specs (BUG-*.md and FEAT-*.md in `./Specs/`, excluding `DONE/` and `NEEDS_REVIEW/`).
3. If zero specs, output "Night Shift: no specs remaining. Nothing to do." and stop.
4. Output: "Night Shift Loop: starting. [N] specs queued."
5. Use the Skill tool to invoke `loop` with args: `$ARGUMENTS /night-shift`
   - `/loop` defaults to 10m, so no interval needed unless the user passes one
   - User can customize: `/night-shift-loop 5m` → `/loop 5m /night-shift`

The `/night-shift` command handles exit conditions — when no specs remain, it outputs "No specs remaining" and the loop becomes a no-op.

## Setup Instructions (shown if no Specs/ directory)

```
Night Shift requires a ./Specs/ directory with spec files.

Create specs like:
  Specs/BUG-login-timeout.md
  Specs/FEAT-user-export.md

Spec template:
  # [BUG/FEAT]-[short-name]
  ## Summary
  ## Acceptance Criteria
  ## Context
  ## Notes

Then run /night-shift-loop to start processing.
```

## Important

- Do NOT ask the user anything. This is fully autonomous.
- The loop continues until all specs are in DONE/ or NEEDS_REVIEW/.
