---
name: exit-session
description: Stop work and dump the current state to HANDOFF.md so the next session does not re-derive it. Use when the user says "exit session", "dump handoff", "stopping", "wrap up", "/exit-session", or otherwise ends a working session.
---

# Exit session

Freeze the session and write `HANDOFF.md` at the workspace root — the dir the session
started in. Caveman + ponytail apply to every line written.

## Freeze first

Do **not** finish the edit in progress, start a verification run, or ask questions. A
half-applied change recorded as half-applied costs nothing; a session that dies mid-edit
with no record is the expensive failure.

## Gather from commands, not memory

At stop time recall is biased toward the last thing touched, which is rarely the important
thing. Run the workspace's gather block — its `CLAUDE.md` names the checkouts, the branch
that ships, and anything else holding live state. No gather block defined? Fall back to:

```bash
git status --short                              # per checkout
git rev-list --left-right --count @{u}...HEAD
docker ps --format '{{.Names}}\t{{.Status}}'    # if the work runs in containers
```

Read the existing HANDOFF before overwriting it — entries under **Stale** and **Ruled out**
belong to previous sessions and are destroyed if not carried or filed.

## Write these sections

| Section | Holds |
|---|---|
| **Tree** | Branch, dirty count, distance from the branch that ships, container state. |
| **In flight** | What this session did, and what is half-done — name the file and its state. |
| **Ruled out** | Staging only. See filing rule below; usually empty. |
| **Stale** | Committed claims that uncommitted work has already invalidated. |
| **Next** | The next action, then later phases one line each. |

**Stale is diff-driven, never memory-driven.** Ask what this session changed that now
contradicts a commit message or a doc. That comparison can only be looked up. It is the
section that gets forgotten and the one that costs the most: the next session trusts
`git log`, and uncommitted work turns a commit message into a lie.

**File ruled-out results next to the claim they settle**, in a tracked file — not here.
A measurement in an untracked overwritten file gets re-run every third session, each re-run
looking like ordinary diligence. Same for a settled decision: it goes to the
design-decisions section of the owning `CLAUDE.md`; HANDOFF only names it so it is not
reopened.

## Test every line

**Does this stop the next session re-deriving something?** If not, cut it, however short
the file already is. No line budget — a length cap cuts expensive facts alongside cheap
prose. No plan narrative: write current state, not the story of how it was reached, and
never a framing the work has since killed.

## Finish

Report in one line that the file is written. No session summary.
