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

- `#` — document title only. One per file. A second `#` heading in the
  same file is a `single-h1` (MD025) lint failure.
- `##` — major sections.
- `###` — subsections within a major section.
- `####` — use sparingly. If you need four levels, the structure is
  probably wrong.

Never skip levels. Do not go from `##` to `####`. Jumping from `##` to
`####` or from no heading to `###` is a `heading-increment` (MD001) lint
failure.

### No duplicate headings

Every heading in a file must be unique. Duplicate headings break anchor
navigation in GitHub, confuse assistive technology, and fail markdown
linters.

If two sections cover different things, differentiate the headings by
adding context. For long reference documents with repeating structural
patterns (pattern blocks, gotcha entries), use `###` subsections inside
distinct `##` parent sections rather than repeating `##` headings with
the same name.

```markdown
# Good — context-qualified headings
## Transaction failure modes
## Block attributes failure modes

# Bad — same heading used twice
## Failure modes
...
## Failure modes
```

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

**`ol-prefix` (MD029) — ordered list item prefix must be sequential.**
Each item must use its actual number (`1.`, `2.`, `3.`), not `1.` repeated.

```markdown
# Good — sequential (style "ordered")
1. First step
2. Second step
3. Third step

# Bad — all-ones style causes MD029 warning
1. First step
1. Second step
1. Third step
```

Markdownlint expects `"style": "ordered"` (the default). Never use the
all-ones shorthand in Chamber 19 files — it fails linting and is harder
to read in raw text.

### Blank lines around lists

Every list must be surrounded by blank lines — one blank line before the
first item and one blank line after the last. Without the blank line
before, many renderers treat the list as a continuation of the preceding
paragraph rather than a standalone block.

```markdown
# Good
Best Practices:

- Use structured references
- Prefer named ranges
- Protect by default

More detail follows here.

# Bad — missing blank line before the list
Best Practices:
- Use structured references
- Prefer named ranges
- Protect by default
```

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

### No spaces inside emphasis markers

A space immediately inside an emphasis marker (`* text *`, `_ text _`)
is not valid Markdown. Most parsers render the markers as literal
characters rather than applying emphasis.

The most common source is code identifiers with trailing underscores
(`VAR_`, `RELAY_`, `PREFIX_`). These are code values — wrap them in
backticks, not underscores.

```markdown
# Good
`RELAY_*` matches relay block names.

# Bad — _ followed by a space is broken emphasis
RELAY_ you can filter on DxfCode.BlockName

# Fix — code identifiers belong in backticks
`RELAY_` followed by a wildcard gives `RELAY_*`
```

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

### Fenced code blocks must have a language and blank lines around them

Every fenced code block needs two things:

1. **A language identifier** on the opening fence — `bash`, `python`, `rust`,
   `csharp`, `yaml`, `toml`, `json`, `markdown`, `text`. Use `text` for
   terminal output. Never leave it blank.

2. **A blank line before and after** the block. A fence that runs directly
   into a paragraph above or below it renders incorrectly in some tools and
   breaks linters.

````markdown
# Good
Run the command:

```bash
cargo check --locked
```

The output should show no errors.

# Bad — no blank lines, no language

Run the command:

```
cargo check --locked
```

The output should show no errors.
````

### No inline HTML

Raw HTML tags (`<Private>`, `<br>`, `<span>`, etc.) are not valid
Markdown and will not render correctly in all tools. Linters flag them
as `no-inline-html` violations.

Wrap XML or HTML tag literals in backticks so they render as code, not
as markup. If you genuinely need rendered HTML in a web view, reconsider
whether Markdown is the right format for that content.

```markdown
# Good
Set the element to `<Private>False</Private>`.

# Bad
<Private>False</Private>
```

### Shell commands: one command per block unless they are a sequence

```markdown
# Good — single command, clear intent

\`\`\`bash
cargo check --locked
\`\`\`

# Also good — explicit sequence with context

\`\`\`bash
# Install dependencies then verify
npm install
npm run build
cargo check --locked
\`\`\`

# Bad — dump of unrelated commands

\`\`\`bash
cargo check --locked
pip install -r requirements.txt
ollama list
dotnet build
\`\`\`
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
| --- | --- | --- |
| App hangs | Missing flush=True | Add flush=True to all print calls |
```

### Table separator row style

The separator row (second row in any table) must use spaces inside the
pipes: `| --- | --- | --- |`. The compact form `|---|---|---|` is not
valid in all renderers and will fail markdown linters.

```markdown
# Good
| Symptom | Likely cause | Fix |
| --- | --- | --- |
| App hangs | Missing flush=True | Add flush=True |

# Bad
| Symptom | Likely cause | Fix |
|---|---|---|
| App hangs | Missing flush=True | Add flush=True |
```

### Keep cell content short

If a table cell needs more than one sentence, the content belongs in a
paragraph, not a table. Extract it.

### Alignment pipes

Use `:---`, `---:`, or `:---:` in the separator row to control text
alignment within a column. Left-align text columns, right-align numeric
columns. This is about content alignment, not pipe position.

### Table column style must be consistent

Choose one pipe style and apply it to every row in the table — header,
separator, and all data rows:

- **Compact** (default): single space inside each pipe throughout —
  `| content |` — separator uses `| --- |`.
- **Aligned**: all pipe positions align vertically across every row;
  separator dashes pad to match column width.

Never mix styles in the same table. The most common mistake is using
padded dashes in the separator while leaving data rows unpadded.

```markdown
# Good — compact, consistent across all rows
| System | Purpose | Auth model |
| --- | --- | --- |
| AutoCAD | Drawing reads | API key |

# Good — aligned, consistent across all rows
| System   | Purpose       | Auth model |
| -------- | ------------- | ---------- |
| AutoCAD  | Drawing reads | API key    |

# Bad — aligned separator, unpadded data rows
| System | Purpose | Auth model |
| ------ | ------- | ---------- |
| AutoCAD | Drawing reads | API key |
```

### Table column count must be consistent

Every row in a table — header, separator, and all data rows — must have the same number of cells. A row with too few cells produces empty cells that may break alignment. A row with too many cells has the extra data silently dropped by most renderers.

```markdown
# Good — every row has 3 cells
| Symptom | Cause | Fix |
| --- | --- | --- |
| App hangs | Missing flush=True | Add flush=True |

# Bad — data row has only 2 cells (third cell missing)
| Symptom | Cause | Fix |
| --- | --- | --- |
| App hangs | Missing flush=True |

# Bad — data row has 4 cells (extra cell dropped silently)
| Symptom | Cause | Fix |
| --- | --- | --- |
| App hangs | Missing flush=True | Add flush=True | Extra data |
```

Count the pipes when writing or reviewing tables. Header column count = separator cell count = every data row cell count.

### No multiple spaces inside table cells

Each cell must have exactly one space between the pipe and the cell
content: `| content |`. Do not use extra spaces to pad cell width
visually — the renderer handles column widths.

A cell with no space adjacent to the pipe (`|content|`) is also a
violation — always include exactly one space on each side.

```markdown
# Good
| Store | Role | Access layer |
| --- | --- | --- |
| database | read-write | repository layer |

# Bad — excessive spacing and missing space before last cell
| Store                 | Role     | Access layer     |
| --- | --- | --- |
| database              | read-write   | repository layer |[file]|
```

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

### No bare URLs

A bare URL (`https://example.com`) is not a proper Markdown link. Most
renderers do not auto-link bare URLs, and linters flag them as
`no-bare-urls` violations.

Wrap every URL in Markdown link syntax with descriptive link text. If
the URL itself must be visible (for reference or copying), use it as the
link text rather than leaving it bare.

```markdown
# Good
See the [Rust reference](https://doc.rust-lang.org/stable/) for syntax details.
The Cargo registry lives at [crates.io](https://crates.io).

# Also acceptable — URL as link text when the destination is the point
Install from [https://rustup.rs](https://rustup.rs).

# Bad — bare URL, not wrapped
See https://doc.rust-lang.org/stable/ for syntax details.
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

### No trailing spaces

Trailing spaces (spaces after the last visible character on a line) are
invisible in editors but cause `no-trailing-spaces` linter failures. Some
Markdown parsers also interpret two trailing spaces as a hard line break,
creating invisible formatting that is hard to diagnose.

Configure your editor to trim trailing whitespace on save. Do not use
two trailing spaces as a line-break mechanism — use a new paragraph
instead.

---

## Accessibility

Markdown rendered on GitHub is read by engineers using screen readers, keyboard navigation, and assistive technology. These rules are not optional polish — they affect whether the content is usable.

### Images must have descriptive alt text

Every image needs alt text that conveys what the image shows. Empty alt text (`![]()`) is only acceptable for purely decorative images.

```markdown
# Good
![Diagram showing Tauri command flow from React UI through Rust shell to Python sidecar](docs/command-flow.png)

# Bad — filename, not a description
![command-flow-diagram-v2.png](docs/command-flow.png)

# Bad — empty
![](docs/command-flow.png)
```

Rules for alt text:

- Describe what the image shows, not what it is ("screenshot of" is acceptable)
- Do not prefix with "image of" — screen readers announce that automatically
- Include any text visible in the image
- For charts or diagrams, summarise the data or relationship being shown
- Keep it under two sentences; longer descriptions belong in a `<details>` block below the image

### Emoji: use sparingly, never as bullet markers

Screen readers read every emoji name aloud in full. Three emoji in a row becomes "rocket sparkles fire" spoken verbatim. Rules:

- Never use emoji as bullet points or list markers — use proper Markdown list syntax (`-`, `*`, `1.`)
- Never use emoji to convey meaning that is not also in the text
- Never use multiple consecutive emoji
- One emoji per paragraph at most, and only when it adds genuine context

```markdown
# Bad — emoji as bullets
🔧 Install dependencies
🚀 Run the build
✅ Verify the output

# Good
- Install dependencies
- Run the build
- Verify the output
```

### Links must not open in a new tab

Do not use `target="_blank"` in Markdown links. Markdown does not support it natively; if you are writing raw HTML links in a `.md` file for this reason, stop. Opening links in a new tab disorients screen reader users and breaks keyboard navigation expectations.

### Bold and italic are not announced by screen readers

Screen readers typically do not announce emphasis styling. Do not rely on bold or italic to convey critical information — write it in the text itself.

```markdown
# Bad — the warning depends on visual styling
Run the command. **Do not run this as administrator.**

# Good — the warning is in the text regardless of rendering
Run the command. Running as administrator will corrupt the token store.
```

### Multimedia needs captions and transcripts

- Provide captions for all videos
- Provide transcripts for all recorded audio
- Do not auto-play audio or video
- Pause animated images on page load if possible

---

## Failure modes — what bad Markdown looks like

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Wall of text with no headings | Author wrote prose, not a document | Add `##` headings every 3–5 paragraphs |
| Every other word is bold | Bold used for decoration | Remove bold except for MUST/NEVER keywords and critical terms |
| Nested bullets 4 levels deep | List structure replacing document structure | Flatten with subheadings |
| Tables with paragraph-length cells | Content forced into table form | Extract cells into paragraphs with a subheading |
| Code shown without backticks | Inline literals not formatted | Wrap all file names, commands, and code in backticks |
| Link text says "here" or "this" | Lazy link text | Rewrite to describe the destination |
| Headings used as bold text | Author unfamiliar with heading semantics | Replace with bold or a proper section heading |
| File starts with a paragraph | No title heading | Add `#` title as first line |
| Mixed list grammar | Items not edited for parallelism | Rewrite all items to the same grammatical form |
| Language identifier missing from code block | Skipped for speed | Add `bash`, `python`, `rust`, etc. — never leave the fence blank |
| Code block runs into surrounding paragraph | No blank line before or after the fence | Add a blank line above the opening ` ``` ` and below the closing ` ``` ` |
| List runs directly into preceding paragraph | No blank line before first bullet | Add a blank line between the paragraph and the list |
| Table renders as plain text or breaks in some tools | Separator row uses `\|---\|` without spaces | Change to `\| --- \|` with spaces inside every pipe |
| Bare URL in file | URL not wrapped in link syntax | Wrap as `[descriptive text](url)` |
| Raw HTML tag renders or breaks layout | HTML element not in backticks | Wrap tag in backticks: `` `<Tag>` `` |
| Trailing whitespace causes linter failure | Editor not trimming whitespace | Configure editor to trim trailing spaces on save |
| Same heading appears more than once | Two sections share an identical label | Add context to differentiate, or demote to `###` subsection |
| Space inside `_` or `*` renders as literal character | Code identifier with trailing `_` not in backticks | Wrap identifiers like `` `RELAY_` `` in backticks |
| Second `#` heading in the file | `single-h1` violation — only one document title per file | Demote to `##` or merge content into the title section |
| Heading jumps from `##` to `####` | `heading-increment` violation — level skipped | Insert the missing `###` level or restructure the document |
| Table pipes don't align vertically with header | Aligned separator mixed with unpadded data rows | Pick one style: all rows compact (`\| --- \|`) or all rows aligned (`\| -------- \|`) |
| Table row has fewer cells than the header | Missing cell — likely a forgotten pipe | Count pipes; every row must match header column count |
| Table row has more cells than the header | Extra data silently dropped by renderer | Remove extra cells or add a column to the header |
| Extra spaces inside table cells | Cell content padded with multiple spaces for visual alignment | Use exactly one space on each side of cell content — `\| content \|` — never `\| content              \|` |

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
- [ ] Images have descriptive alt text (not filenames, not empty)
- [ ] No emoji used as bullet points or list markers
- [ ] Critical information is stated in text, not conveyed only through bold or italic
- [ ] Every list has a blank line before the first item and after the last
- [ ] Every fenced code block has a blank line above and below it
- [ ] Every fenced code block has a language identifier — never a bare ` ``` `
- [ ] Table separator rows use `| --- |` style (spaces inside pipes), not `|---|`
- [ ] No bare URLs — all external links use `[text](url)` syntax
- [ ] No raw HTML tags outside code blocks — XML/HTML literals are wrapped in backticks
- [ ] No trailing spaces on any line
- [ ] All headings are unique — no duplicate heading text in the file
- [ ] No spaces inside emphasis markers — identifiers with trailing `_` or `*` are in backticks
- [ ] Table column style is consistent — header, separator, and data rows all use compact or all use aligned; never mixed
- [ ] Table cells have exactly one space inside each pipe — no extra padding spaces inside cells
