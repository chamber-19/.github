---
applyTo: "**/*.cs,**/*.csproj"
---

# AutoCAD Plugin Error Diagnosis

Diagnose the error using a layered approach.

Layers:

1. User task
2. AutoCAD state
3. Local install path
4. Plugin/bundle loading
5. .NET build
6. Autodesk references
7. Transaction model
8. MCP server
9. Python sidecar
10. Ollama/RAG pipeline
11. Permissions/trusted paths
12. File paths and environment variables

When diagnosing, ask for or inspect:

- exact error message
- command used
- AutoCAD version
- active drawing status
- plugin path
- install path under `C:\Program Files\Autodesk\`
- `.csproj` references
- `Copy Local` behavior
- bundle manifest
- log output
- whether AutoCAD was idle or busy

Output:

1. Most likely cause
2. Evidence
3. What to check first
4. Minimal safe fix
5. What not to change yet
6. Follow-up test


**Deep references:**
- `docs/skills/AUTOCAD_DOTNET.md` in this repo — canonical .NET plugin patterns
- `autocad-knowledge` repo — cross-repo AutoCAD reference (transaction-model, attributes, headless-processing, gotchas)
- Autonomous Skill mirror: `ch19-acad-error-diagnosis` (in `~/.workbuddy/skills/` and `~/.claude/skills/`)
- Slash command mirror: `/acad-error-diagnosis` (in workspace `.claude/commands/`)
