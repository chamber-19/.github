---
applyTo: "**/*.cs,**/*.csproj,**/*.lsp,**/*.dwg,**/*.dwt"
---

# AutoCAD Read-Only-First Workflow

Apply the read-only-first AutoCAD automation workflow.

For any AutoCAD automation task:

1. Identify the user’s goal
2. Determine the drawing context needed
3. Read the drawing data first
4. Summarize what was found
5. Identify possible actions
6. Separate actions into:
   - read-only
   - preview-only
   - write actions
   - destructive/high-risk actions
7. Ask for approval before any write action
8. Log the planned write action before execution

Read-only examples:

- list layers
- count blocks
- read selected entity
- read block attributes
- enumerate text
- measure polyline length
- inspect drawing units
- inspect layouts
- inspect title block fields

Preview-only examples:

- proposed layer fixes
- proposed title block changes
- proposed connector point locations
- proposed text replacements
- proposed drawing index corrections

Write actions requiring approval:

- modify attributes
- create layers
- draw geometry
- move entities
- create connector points
- update title blocks
- batch process drawings

High-risk actions requiring strong confirmation:

- delete entities
- purge layers
- overwrite files
- batch replace text
- modify many drawings
- save over original DWG files


**Deep references:**
- `docs/skills/AUTOCAD_DOTNET.md` in this repo — canonical .NET plugin patterns
- `autocad-knowledge` repo — cross-repo AutoCAD reference (transaction-model, attributes, headless-processing, gotchas)
- Autonomous Skill mirror: `ch19-acad-readonly-first` (in `~/.workbuddy/skills/` and `~/.claude/skills/`)
- Slash command mirror: `/acad-readonly-first` (in workspace `.claude/commands/`)
