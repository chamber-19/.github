---
applyTo: "**/*.csproj,**/PackageContents.xml,**/*.sln"
---

# AutoCAD Plugin Bootstrap

Apply the AutoCAD automation operating rules for this session.

First, read and apply these existing command skills if available:

- `.claude/commands/autocad-assistant.md`
- `.claude/commands/autocad-dotnet.md`
- `.claude/commands/python.md`
- `.claude/commands/powershell.md`
- `.claude/commands/markdown.md`

Then verify the local AutoCAD environment before making recommendations:

- Check for installed AutoCAD folders under `C:\Program Files\Autodesk\`
- Prefer the active installed version, likely `AutoCAD 2027` or `AutoCAD 2026`
- Locate these assemblies when relevant:
  - `acdbmgd.dll`
  - `acmgd.dll`
  - `accoremgd.dll`
- Do not assume an ObjectARX SDK is installed unless a folder proves it exists
- Do not hardcode install paths without checking

Reference official Autodesk documentation when explaining AutoCAD API behavior, especially:

- AutoCAD .NET API
- ObjectARX Developer Guide
- AutoCAD trusted paths
- AutoCAD support file paths
- Transactions
- Plug-in bundles
- `accoreconsole.exe`

Safety rules:

- Read-only inspection comes first
- Preview before write
- Human approval before drawing modification
- Never delete, purge, overwrite, batch-replace, or modify DWGs without explicit approval
- Log every proposed write action before applying it
- Treat AI output as advisory until verified


**Deep references:**
- `docs/skills/AUTOCAD_DOTNET.md` in this repo — canonical .NET plugin patterns
- `autocad-knowledge` repo — cross-repo AutoCAD reference (transaction-model, attributes, headless-processing, gotchas)
- Autonomous Skill mirror: `ch19-acad-bootstrap` (in `~/.workbuddy/skills/` and `~/.claude/skills/`)
- Slash command mirror: `/acad-bootstrap` (in workspace `.claude/commands/`)
