---
applyTo: "**/*.cs,**/*.dwg,**/*.dwt"
---

# AutoCAD Drawing Package QA/QC

Use this skill for drawing package review, submittal readiness, and QA/QC checks.

Scope:

- drawing index
- title blocks
- revision fields
- sheet numbers
- project numbers
- issue dates
- xrefs
- missing sheets
- duplicate sheet numbers
- layer standard issues
- plotted sheet consistency
- checklist readiness

Workflow:

1. Identify the package folder
2. Read the drawing index if available
3. Compare listed sheets against actual DWG/PDF files
4. Inspect title block fields if tools are available
5. Check revision/date consistency
6. Flag missing, duplicate, or inconsistent items
7. Produce a QA/QC report
8. Separate issues into:
   - critical
   - moderate
   - minor
   - informational
9. Provide a human review checklist

Safety rules:

- Do not modify drawings during QA/QC unless explicitly requested
- Do not rename files without approval
- Do not overwrite PDFs
- Do not mark the package complete; only recommend readiness

Expected output:

| Severity | Drawing/File | Issue | Evidence | Recommended Fix | Needs Human Review |
|---|---|---|---|---|---|


**Deep references:**
- `docs/skills/AUTOCAD_DOTNET.md` in this repo — canonical .NET plugin patterns
- `autocad-knowledge` repo — cross-repo AutoCAD reference (transaction-model, attributes, headless-processing, gotchas)
- Autonomous Skill mirror: `ch19-acad-drawing-package-qaqc` (in `~/.workbuddy/skills/` and `~/.claude/skills/`)
- Slash command mirror: `/acad-drawing-package-qaqc` (in workspace `.claude/commands/`)
