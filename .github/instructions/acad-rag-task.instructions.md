---
applyTo: "**/autocad-llm-pipeline/**"
---

# AutoCAD RAG Task

Use the local AutoCAD RAG knowledge base before answering.

Preferred sources:

1. `autocad-knowledge/`
2. `chamber-19-autocad-mcp/docs/codebase/`
3. `chamber-19-autocad-mcp/autocad-knowledge/`
4. `SubstationDetail/`
5. Official Autodesk documentation
6. Local install evidence from `C:\Program Files\Autodesk\`

Rules:

- Do not answer from memory if a local source exists
- Retrieve source chunks first
- Cite file paths or source names in the answer
- Separate verified facts from assumptions
- Mark unknowns as `[TODO]`
- If sources disagree, explain the conflict
- Do not generate code until the relevant API pattern is confirmed

Output:

1. Answer summary
2. Source-backed findings
3. Relevant files/docs
4. Assumptions
5. Recommended next step
6. Safety concerns


**Deep references:**
- `docs/skills/AUTOCAD_DOTNET.md` in this repo — canonical .NET plugin patterns
- `autocad-knowledge` repo — cross-repo AutoCAD reference (transaction-model, attributes, headless-processing, gotchas)
- Autonomous Skill mirror: `ch19-acad-rag-task` (in `~/.workbuddy/skills/` and `~/.claude/skills/`)
- Slash command mirror: `/acad-rag-task` (in workspace `.claude/commands/`)
