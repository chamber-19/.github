---
applyTo: "**/PackageContents.xml,**/*.bundle/**,**/*.csproj"
---

# AutoCAD Plugin Install Audit

Run an AutoCAD local install audit.

Scope:

- Inspect `C:\Program Files\Autodesk\`
- Identify installed AutoCAD versions
- Locate AutoCAD executable paths such as `acad.exe` and `accoreconsole.exe`
- Locate managed API assemblies:
  - `acdbmgd.dll`
  - `acmgd.dll`
  - `accoremgd.dll`
- Check whether ObjectARX SDK folders exist
- Check common bundle locations:
  - `%ProgramData%\Autodesk\ApplicationPlugins`
  - `%AppData%\Autodesk\ApplicationPlugins`
- Check whether custom plugin folders are in trusted paths if AutoCAD can be queried
- Do not modify any system setting unless explicitly asked

Output:

1. Installed AutoCAD versions
2. Important executable paths
3. Managed API assembly paths
4. Bundle/plugin folders found
5. Trusted/support path concerns
6. Missing pieces
7. Recommended next actions

Rules:

- Do not assume paths. Verify them.
- Do not install anything.
- Do not edit environment variables unless explicitly requested.
- Cite official Autodesk documentation when explaining support paths, trusted paths, plug-in bundles, or .NET behavior.


**Deep references:**
- `docs/skills/AUTOCAD_DOTNET.md` in this repo — canonical .NET plugin patterns
- `autocad-knowledge` repo — cross-repo AutoCAD reference (transaction-model, attributes, headless-processing, gotchas)
- Autonomous Skill mirror: `ch19-acad-install-audit` (in `~/.workbuddy/skills/` and `~/.claude/skills/`)
- Slash command mirror: `/acad-install-audit` (in workspace `.claude/commands/`)
