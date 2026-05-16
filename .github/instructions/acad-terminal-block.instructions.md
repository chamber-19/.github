---
applyTo: "**/*.cs,**/TerminalBlock*,**/oneshot/**,**/*.dwt"
---

# AutoCAD Terminal Block Workflow

Use this skill when working on AutoCAD MEP terminal blocks, connector points, wire routing starts, terminal numbers, or copied terminal block devices.

Goal:

Help configure terminal blocks so wires start from the correct numbered terminals, not from incorrect insertion points or random connector locations.

Workflow:

1. Confirm the selected object is a terminal block or terminal-related device
2. Read the selected block/device data
3. Identify:
   - block name
   - insertion point
   - visible terminal numbers
   - attributes
   - existing connector points
   - layer
   - rotation
   - scale
4. Explain the current connector behavior in plain language
5. Propose connector point positions relative to the block insertion point
6. Show a preview table before writing
7. Ask for approval before modifying the block/device
8. After approval, apply the connector points
9. Log:
   - drawing name
   - block name
   - terminal numbers
   - connector coordinates
   - date/time
   - action taken

Safety rules:

- Never guess connector points if terminal numbering is unclear
- Never modify a block definition without explaining whether it affects all inserted instances
- Never write changes without preview
- Never batch-update all terminal blocks unless explicitly approved
- Keep coordinates relative to insertion point when possible
- Warn if copied blocks may inherit connector behavior from the block definition

Expected output format:

| Terminal | Proposed X | Proposed Y | Reason | Risk |
|---|---:|---:|---|---|

Also include:

- plain-English explanation
- what will change
- what will not change
- approval question


**Deep references:**
- `docs/skills/AUTOCAD_DOTNET.md` in this repo — canonical .NET plugin patterns
- `autocad-knowledge` repo — cross-repo AutoCAD reference (transaction-model, attributes, headless-processing, gotchas)
- Autonomous Skill mirror: `ch19-acad-terminal-block` (in `~/.workbuddy/skills/` and `~/.claude/skills/`)
- Slash command mirror: `/acad-terminal-block` (in workspace `.claude/commands/`)
