---
applyTo: "**/*.cs,**/*.dwg,**/*.dwt"
---

# AutoCAD Layer Standards

Use this skill to inspect layers, compare against standards, and suggest cleanup.

Workflow:

1. Read all layers in the active drawing
2. Group layers by discipline or naming pattern
3. Compare layer names to known project/company standards
4. Identify:
   - nonstandard layers
   - likely typos
   - empty layers
   - frozen/off/locked layers that may matter
   - objects on incorrect layers
5. Produce a report
6. Suggest corrections
7. Preview any layer rename/move operation
8. Require approval before writing

Safety rules:

- Do not delete layers automatically
- Do not purge automatically
- Do not move objects between layers without approval
- Do not rename layers without showing affected object counts
- Warn if xrefs or dependent layers are involved

Expected output:

| Layer | Status | Object Count | Issue | Suggested Action | Risk |
|---|---|---:|---|---|---|


**Deep references:**
- `docs/skills/AUTOCAD_DOTNET.md` in this repo — canonical .NET plugin patterns
- `autocad-knowledge` repo — cross-repo AutoCAD reference (transaction-model, attributes, headless-processing, gotchas)
- Autonomous Skill mirror: `ch19-acad-layer-standards` (in `~/.workbuddy/skills/` and `~/.claude/skills/`)
- Slash command mirror: `/acad-layer-standards` (in workspace `.claude/commands/`)
