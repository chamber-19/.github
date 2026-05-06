# MARKDOWN Skill

Use this skill when writing, editing, or reviewing any Markdown document —
including skill files, README files, copilot instructions, AGENTS.md,
memory files, eval specs, and changelogs. Apply it before producing or
modifying any `.md` file in the Chamber 19 org.

---

## Core principle

Markdown exists to make text readable — not to demonstrate that you know
every Markdown feature. A document that reads clearly as plain text is
better than one that looks impressive rendered but is hard to scan.

Before writing anything, ask: **would an engineer reading this in a
terminal, a GitHub diff, or a PR review be able to extract the key point
in under ten seconds?** If not, simplify.

---

## Structure

### Use headings to create scannable sections, not to decorate paragraphs

Every `##` heading should represent a genuinely distinct section that a
reader might want to jump to. Do not use headings as bold text or to
introduce a single sentence.

```markdown
# Good — distinct navigable sections
## Purpose
## Before you start
## Environment verification
## Forbidden actions

# Bad — headings used as decoration
## Overview
This file explains things.
## Note
Remember to be careful.
```

### Heading hierarchy must be consistent

- `#` — document title only. One per file.
- `##` — major sections.
- `###` — subsections within a major section.
- `####` — use sparingly. If you need four levels, the structure is
  probably wrong.

Never skip levels. Do not go from `##` to `####`.

### One idea per paragraph

Each paragraph covers one topic. When the topic shifts, start a new
paragraph. Two-sentence paragraphs are fine. Eight-sentence paragraphs
are not.

---

## Lists

### Use lists for genuinely enumerable things

Lists are for items that are parallel and discrete. They are not for
prose that happens to have been broken into fragments.

```markdown
# Good — parallel, discrete items
MUST do before starting:
- Read copilot-instructions.md
- Run cargo check
- Run npm run build

# Bad — prose disguised as a list
Things to keep in mind:
- It is important to remember that the file must be read carefully
  because it contains context that matters.
- Also, running the build is something you should do.
```

### List items must be grammatically parallel

All items in a list should be the same grammatical form — all imperatives,
all noun phrases, all complete sentences, or all fragments. Never mix.

```markdown
# Good — all imperatives
- Run cargo check
- Install Python dependencies
- Verify the health endpoint responds

# Bad — mixed forms
- Run cargo check
- Python dependencies installation
- The health endpoint should be verified
```

### Nested lists: maximum two levels

If you find yourself at three levels of nesting, flatten the structure.
Use a subheading instead of a third level of bullets.

### Ordered vs unordered lists

Use ordered lists (`1.`, `2.`, `3.`) only when sequence matters — steps
that must happen in order, a ranked priority list. Use unordered lists
for everything else. Do not use ordered lists just to make a list look
more formal.

---

## Emphasis

### Bold is for critical information only

`**bold**` draws the eye. Use it for things a reader must not miss —
a MUST rule, a WARNING, a term being defined for the first time. Do not
bold things because they seem important to you in the moment.

```markdown
# Good
**MUST** return `Result<T, String>` from every command.
Set **Copy Local to False** for all Autodesk assemblies.

# Bad
This is a **very important** section that contains **key information**
about **how to use** the **system**.
```

### Italic is for titles, technical terms, and light emphasis

Use `_italic_` for titles of documents, names of concepts being
introduced, or light stress. Do not use italic for decoration.

### Never combine bold and italic for emphasis

`**_this_**` is almost never the right choice. If something needs both,
the sentence is doing too much work. Rewrite it.

### ALLCAPS for keywords in instruction files only

Use `MUST`, `NEVER`, `PREFER` in instruction and rules documents where
they function as defined terms in the meta-contract. Do not use ALLCAPS
elsewhere for emphasis — use bold instead.

---

## Code formatting

### Inline code for anything that would be typed or read literally

Use backticks for: file names, paths, function names, variable names,
command-line arguments, environment variables, config keys, and any
string that would appear verbatim in code.

```markdown
# Good
Set `flush=True` on every `print()` call.
The setting lives in `foundry.settings.json`.
Run `cargo check --locked` before committing.

# Bad
Set flush=True on every print() call.
The setting lives in foundry.settings.json.
```

### Code blocks for anything multi-line

Never show multi-line code, commands, or file contents as inline code or
plain text. Always use a fenced code block with the language identifier.

````markdown
```bash
dotnet build Foundry.sln --configuration Release
dotnet test Foundry.sln --no-build
```

```python
def respond(payload: dict) -> None:
    print(json.dumps(payload), flush=True)
```

```rust
#[tauri::command]
fn read_folder(path: String) -> Result<Vec<String>, String> {
    todo!()
}
```
````

Always specify the language: `bash`, `python`, `rust`, `csharp`, `yaml`,
`toml`, `json`, `markdown`, `text`. Use `text` for output that is not
code. Never leave the language identifier blank on a code block that
contains real code.

### Shell commands: one command per block unless they are a sequence

```markdown
# Good — single command, clear intent
```bash
cargo check --locked
```

# Also good — explicit sequence with context
```bash
# Install dependencies then verify
npm install
npm run build
cargo check --locked
```

# Bad — dump of unrelated commands
```bash
cargo check --locked
pip install -r requirements.txt
ollama list
dotnet build
```
```

---

## Tables

### Use tables only for structured comparison data

Tables are appropriate for: feature comparisons, failure mode references
(symptom → cause → fix), library references (purpose → name → notes),
design token listings. They are not appropriate for lists of items that
have only one column, or for prose that has been forced into cells.

### Every table needs a header row

```markdown
| Symptom | Likely cause | Fix |
|---|---|---|
| App hangs | Missing flush=True | Add flush=True to all print calls |
```

### Keep cell content short

If a table cell needs more than one sentence, the content belongs in a
paragraph, not a table. Extract it.

### Alignment pipes

Use consistent pipe alignment. Left-align all columns unless the content
is numeric, in which case right-align. Do not obsess over perfect visual
alignment in source — rendered output is what matters.

---

## Links

### Link text must describe the destination

```markdown
# Good
See the [Tauri v2 documentation](https://v2.tauri.app/start/) for IPC patterns.
Read [RUST.md](docs/skills/RUST.md) before touching Cargo files.

# Bad
Click [here](https://v2.tauri.app/start/) for more information.
See [this file](docs/skills/RUST.md).
```

### Internal links use relative paths

For links within the same repo, always use relative paths. This makes
the link work in any clone, fork, or mirror without depending on a
specific GitHub URL.

```markdown
# Good
[AGENTS.md](./AGENTS.md)
[Rust skill](../docs/skills/RUST.md)

# Bad
[AGENTS.md](https://github.com/chamber-19/Foundry/blob/main/AGENTS.md)
```

---

## Tone and voice

### Write for engineers, not for documentation departments

Chamber 19 docs use a warm, matter-of-fact tone. Write the way a senior
engineer would explain something to a new team member — direct, specific,
no filler.

```markdown
# Good
Run cargo check before opening a PR. If it fails, fix it before
asking for review.

# Bad
It is important to ensure that the cargo check command has been
successfully executed prior to the initiation of the pull request
review process.
```

### No marketing language

Never use: "seamlessly", "powerful", "robust", "leverage", "cutting-edge",
"world-class", "best-in-class", "innovative", "state-of-the-art".
These words add no information.

### No exclamation points

Exclamation points are for celebrations. Documentation is not a
celebration.

```markdown
# Good
All evals passed.

# Bad
All evals passed!
```

### Active voice over passive voice

```markdown
# Good
Run cargo check after every change.
Commit Cargo.lock with your changes.

# Bad
cargo check should be run after every change.
Cargo.lock should be committed with your changes.
```

---

## Frontmatter

Files that use YAML frontmatter (instruction files, skill files with
metadata) must have valid YAML. Common mistakes:

```markdown
# Good
---
name: rust
description: Write idiomatic Rust for Tauri commands and library code.
---

# Bad — missing closing ---
---
name: rust
description: Write idiomatic Rust.

# Bad — unquoted value with colon in it
---
description: Rust: the systems language
---

# Good — quote values that contain colons
---
description: "Rust: the systems language"
---
```

---

## File-level conventions

### Every file needs a clear title

The first line of every Markdown file should be an `#` heading that
names the document unambiguously. Do not start with a paragraph.

### Files should open with a one-paragraph purpose statement

After the title, the first paragraph says what this file is for and who
should read it. A reader landing on this file for the first time should
know within three seconds whether it's relevant to them.

### Keep files focused

One file, one topic. A skill file covers one technology. A memory file
covers incidents. An eval file covers one eval case. If a file is trying
to cover two distinct topics, split it.

### Line length

Prefer wrapping prose at 80–100 characters per line in source. This
makes diffs readable and works in terminal editors. Do not hard-wrap code
blocks — let them run long.

---

## Failure modes — what bad Markdown looks like

| Symptom | Likely cause | Fix |
|---|---|---|
| Wall of text with no headings | Author wrote prose, not a document | Add `##` headings every 3–5 paragraphs |
| Every other word is bold | Bold used for decoration | Remove bold except for MUST/NEVER keywords and critical terms |
| Nested bullets 4 levels deep | List structure replacing document structure | Flatten with subheadings |
| Tables with paragraph-length cells | Content forced into table form | Extract cells into paragraphs with a subheading |
| Code shown without backticks | Inline literals not formatted | Wrap all file names, commands, and code in backticks |
| Link text says "here" or "this" | Lazy link text | Rewrite to describe the destination |
| Headings used as bold text | Author unfamiliar with heading semantics | Replace with bold or a proper section heading |
| File starts with a paragraph | No title heading | Add `#` title as first line |
| Mixed list grammar | Items not edited for parallelism | Rewrite all items to the same grammatical form |
| Language identifier missing from code block | Skipped for speed | Add `bash`, `python`, `rust`, etc. |

---

## Quick checklist before committing a Markdown file

- [ ] File starts with an `#` title
- [ ] First paragraph says what the file is for
- [ ] Heading hierarchy is consistent (no skipped levels)
- [ ] All code is in backticks or fenced blocks with language identifier
- [ ] File names, paths, and config keys use inline code
- [ ] Bold is used only for critical terms and MUST/NEVER keywords
- [ ] Lists are parallel in grammar
- [ ] No list is nested more than two levels
- [ ] Table cells are short — no paragraph-length cells
- [ ] Link text describes the destination
- [ ] No exclamation points
- [ ] No marketing language
- [ ] Tone is direct and active voice
