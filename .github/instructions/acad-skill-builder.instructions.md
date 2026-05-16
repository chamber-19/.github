---
applyTo: "**/instructions/acad-*.instructions.md,**/commands/acad-*.md,**/skills/ch19-acad-*/SKILL.md"
---

# AutoCAD Skill Builder

Help me create an original AutoCAD automation skill.

Do not copy proprietary implementation from any reverse-engineered source. Use only general architecture patterns:

- skill metadata
- workflow steps
- allowed tools
- permission boundaries
- memory/context requirements
- preview-before-write
- human approval
- action logging

For the requested skill, produce:

1. Skill name
2. Folder name
3. `SKILL.md` content
4. YAML frontmatter
5. When to use it
6. Inputs required
7. Read-only tools allowed
8. Preview tools allowed
9. Write tools requiring approval
10. Safety rules
11. Expected output format
12. Example user prompts
13. Failure cases
14. Human verification checklist

AutoCAD-specific rules:

- Use official Autodesk documentation for API claims
- Follow AutoCAD .NET transaction rules
- Open objects `ForRead` before writing
- Upgrade open state only when needed
- Use Python sidecars for COM-based automation
- Use C#/.NET for serious plugin work
- Never modify drawings without explicit user approval


**Deep references:**
- `docs/skills/AUTOCAD_DOTNET.md` in this repo — canonical .NET plugin patterns
- `autocad-knowledge` repo — cross-repo AutoCAD reference (transaction-model, attributes, headless-processing, gotchas)
- Autonomous Skill mirror: `ch19-acad-skill-builder` (in `~/.workbuddy/skills/` and `~/.claude/skills/`)
- Slash command mirror: `/acad-skill-builder` (in workspace `.claude/commands/`)
