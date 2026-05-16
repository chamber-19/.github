---
applyTo: "**/*.cs,**/*.py"
---

# AutoCAD Plugin Python Sidecar

Use this skill when a task involves Python, COM automation, external file processing, Excel/PDF parsing, or sidecar communication with AutoCAD tooling.

Architecture rule:

- Do not use COM APIs from AutoCAD .NET plugins
- Use Python sidecars for COM-based automation or external automation
- Keep the .NET plugin responsible for safe in-process AutoCAD API work
- Keep Python responsible for external file processing, COM side tasks, and orchestration when appropriate

Design the sidecar contract:

1. Input format
2. Output format
3. Error format
4. Logging
5. Dry-run mode
6. Write approval boundary
7. Timeout behavior
8. How the .NET plugin or Tauri app calls it

Preferred communication styles:

- newline-delimited JSON over stdin/stdout
- local HTTP only if needed
- local WebSocket only for streaming progress
- no hardcoded credentials
- no hidden writes

Expected output:

1. Proposed sidecar responsibility
2. JSON input schema
3. JSON output schema
4. Error handling plan
5. Dry-run behavior
6. Human approval boundary
7. Example request/response


**Deep references:**
- `docs/skills/AUTOCAD_DOTNET.md` in this repo — canonical .NET plugin patterns
- `autocad-knowledge` repo — cross-repo AutoCAD reference (transaction-model, attributes, headless-processing, gotchas)
- Autonomous Skill mirror: `ch19-acad-python-sidecar` (in `~/.workbuddy/skills/` and `~/.claude/skills/`)
- Slash command mirror: `/acad-python-sidecar` (in workspace `.claude/commands/`)
