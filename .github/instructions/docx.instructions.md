---
applyTo: "**/templates/**,**/*.docx,**/docx/**"
---

# DOCX — Chamber 19 rules

The rules below apply even if you cannot access the skill file. For complete guidance — API patterns and failure modes — read `docs/skills/DOCX.md` in the `chamber-19/.github` repo when you can access it.

## Creating documents

- **MUST** use `python-docx` for all `.docx` creation in Python backends
- **MUST** use the `docx` npm package for any JavaScript document creation
- **MUST** open a template with `Document(template_path)` — never bare `Document()` for transmittal work; the template carries all required styles and margins
- **MUST** use styles, not direct formatting — never set font size or bold directly on runs
- **MUST** use `pathlib.Path` for all file paths — never string-concatenate
- **MUST** verify output by opening in Microsoft Word — there is no automated visual check
- **NEVER** write to stdout from document generation code — it is the FastAPI sidecar's IPC channel
- **NEVER** hardcode content strings into the `.dotx` template — treat the template as a layout artifact only
- **NEVER** call COM/Word automation from the Tauri process — all DOCX work lives in the Python sidecar

## docx-js critical rules (JavaScript only)

- **NEVER** use `\n` inside a `TextRun` for line breaks — use separate `Paragraph` elements
- **NEVER** use `new PageBreak()` standalone — always wrap in `new Paragraph({ children: [new PageBreak()] })`
- **NEVER** use `ShadingType.SOLID` for table cell shading — use `ShadingType.CLEAR` or cells render black
- **NEVER** use the string `"bullet"` for list format — use the `LevelFormat.BULLET` constant
- **MUST** specify `type` on every `ImageRun` (`"png"`, `"jpg"`, etc.)
- **MUST** set `columnWidths` array on the `Table` AND `width` on each `TableCell`
