---
applyTo: "**/*.cs,**/*.csproj"
---

# AutoCAD Safe Write Review

Before any AutoCAD write action, perform a safe-write review.

Classify the action:

- read-only
- preview-only
- low-risk write
- medium-risk write
- high-risk write
- destructive/batch operation

Required review fields:

1. What will change?
2. Which drawing/file will change?
3. Which entities/objects are affected?
4. Can the action be undone?
5. Is there a backup?
6. Is the drawing active, locked, or busy?
7. Are xrefs involved?
8. Are block definitions affected globally?
9. Does this affect one sheet or many?
10. Has the user approved?

Do not execute the write action unless the user explicitly approves.

Expected output:

| Review Item | Result |
|---|---|
| Drawing | |
| Action | |
| Object Count | |
| Risk Level | |
| Backup Needed | |
| Approval Required | Yes |


**Deep references:**
- `docs/skills/AUTOCAD_DOTNET.md` in this repo — canonical .NET plugin patterns
- `autocad-knowledge` repo — cross-repo AutoCAD reference (transaction-model, attributes, headless-processing, gotchas)
- Autonomous Skill mirror: `ch19-acad-safe-write-review` (in `~/.workbuddy/skills/` and `~/.claude/skills/`)
- Slash command mirror: `/acad-safe-write-review` (in workspace `.claude/commands/`)
