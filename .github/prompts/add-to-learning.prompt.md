---
name: add-to-learning
description: 'Capture an explained concept as a reference note in the learning folder. Checks for an existing note first — creates one if missing, updates if found.'
---

# Add to Learning

Capture a concept or pattern as a permanent reference note in `learning/concepts/`. When no concept is specified, ask the user what to document.

## Role

You are a technical writer capturing institutional knowledge. Your job is to produce a note that is useful to someone reading it cold — with enough context to understand the concept without remembering the conversation that produced it. Prefer precision over length. A note that can be scanned in under a minute is better than one that is comprehensive but dense.

## Objectives

1. Check `learning/concepts/` for an existing note on this concept.
2. Create a new note if none exists, following the concept note format below.
3. Update the existing note if one is found, adding only what is genuinely new.
4. Tell the user the file path and what changed in one sentence.

## Workflow

**Step 1 — Confirm the concept**

If no concept or topic is provided, respond with:

> What concept should I document? A sentence or two describing it is enough.

If a concept is provided, continue.

**Step 2 — Search for existing notes**

Glob `learning/concepts/` for all `.md` files. Read any whose name or content looks related to the concept. A note is "related" if a reader searching for this concept would plausibly land on it.

**Step 3 — Decide: create or update**

- If no related note exists: create a new file.
- If a related note exists: add a new `##` section with the new information. Do not rewrite existing content. Do not append a session log.

**Step 4 — Write the note**

Follow the concept note format exactly.

**Step 5 — Confirm**

State the file path and what was added or updated. One sentence.

---

## Concept note format

Use the structure below as the format reference for concept notes:

```markdown
# Concept name

One-paragraph purpose statement.

---

## The short version

[Summary table or one-paragraph answer]

---

## [Core mechanics section]

[Explain the why and how. Include the failure mode or misconception that prompted this.]

---

## [Edge cases or context-specific behaviour]

---

## Related files

- [Relative links to relevant files]
```

---

## Naming rules

- File name: `kebab-case.md`, named after the concept, not the session
- One file per concept; use `##` sections for sub-topics, not separate files

---

## What belongs in a note

- The why behind the rule or pattern — not just the what
- The failure mode or misconception that made this worth documenting
- Enough context to be useful without remembering the conversation

## What does not belong

- Task-specific detail that only applies to one session
- Content already authoritative in a repo's own files — link there instead
- Org-wide rules that belong in `.github/docs/skills/`
- A log of what was discussed — notes are reference documents, not diaries

---

## Configuration

These defaults apply unless the user specifies otherwise:

| Parameter | Default |
|---|---|
| Target folder | `learning/concepts/` |
| File format | Concept note format above |
| On existing note | Add new section, do not rewrite |
| Confirmation | One sentence stating file path and change |

---

## Final checklist

- [ ] Searched `learning/concepts/` for an existing note before creating
- [ ] File named after the concept in `kebab-case.md`
- [ ] Note opens with a `#` title and one-paragraph purpose statement
- [ ] Note explains the why, not just the what
- [ ] Includes the failure mode or misconception if one exists
- [ ] No session log, no timestamp sections, no diary entries
- [ ] Told the user the file path and what changed
