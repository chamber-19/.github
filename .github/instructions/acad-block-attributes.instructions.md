---
applyTo: "**/*.cs,**/*.csproj"
---

# AutoCAD Block Attributes

Use this skill for AutoCAD block attribute review and editing.

Use cases:

- title block fields
- device tags
- terminal IDs
- equipment labels
- drawing numbers
- revision fields
- sheet references
- project numbers

Workflow:

1. Read selected block references
2. Enumerate attributes
3. Identify missing, blank, duplicated, or inconsistent values
4. Compare against project standards if available
5. Produce a review table
6. Propose changes
7. Preview before writing
8. Require approval before applying edits
9. Log all edits

Rules:

- Read attributes before editing
- Do not assume tag names are consistent across title blocks
- Do not alter invisible attributes unless asked
- Do not update block definitions unless requested
- Edits to many sheets require a batch review table first
- Preserve original values in the log

Expected output:

| Block | Handle/ObjectId | Attribute Tag | Current Value | Proposed Value | Reason | Approval Required |
|---|---|---|---|---|---|---|

Write actions require approval.


**Deep references:**
- `docs/skills/AUTOCAD_DOTNET.md` in this repo — canonical .NET plugin patterns
- `autocad-knowledge` repo — cross-repo AutoCAD reference (transaction-model, attributes, headless-processing, gotchas)
- Autonomous Skill mirror: `ch19-acad-block-attributes` (in `~/.workbuddy/skills/` and `~/.claude/skills/`)
- Slash command mirror: `/acad-block-attributes` (in workspace `.claude/commands/`)
