# Biome Skill

Read this skill when writing, reviewing, or linting TypeScript and JavaScript files in Chamber 19 frontend repos. It defines how to use Biome locally, the PR policy, suppression rules, and the incremental adoption strategy across the org.

---

## Scope

Biome applies to JS/TS code only. The repos in scope are:

| Repo | Directory |
| --- | --- |
| `launcher` | `frontend/src/` |
| `block-library` | `frontend/src/` |
| `desktop-toolkit` | `frontend/src/` (JS/TS portions) |

Biome does **not** apply to Python backends, Rust shells, C# plugins, or VBA workbooks. Do not run `biome check` against those directories.

---

## Purpose

Use Biome to:

- Enforce consistent formatting and lint rules across all Chamber 19 TS/JS frontends
- Catch accessibility and correctness issues before review
- Apply safe automatic corrections without manual intervention
- Gate pull requests with a predictable, fast quality check

---

## Standard npm scripts

Every Chamber 19 frontend repo that adopts Biome wires these script names in `package.json`. Use these names, not ad-hoc variants:

```json
{
  "scripts": {
    "lint": "biome check src",
    "lint:fix": "biome check --write .",
    "format": "biome format --write src"
  }
}
```

| Script | Effect |
| --- | --- |
| `npm run lint` | Read-only check — reports violations, makes no changes |
| `npm run lint:fix` | Applies all safe auto-fixes |
| `npm run format` | Formats source files only |

---

## Local workflow

Run these in order before opening a PR:

```bash
npm run lint
npm run lint:fix
npm run lint && npm run build
```

1. Run `npm run lint` to see violations.
2. Run `npm run lint:fix` to apply auto-fixable changes.
3. Resolve any remaining non-fixable diagnostics manually.
4. Run `npm run lint && npm run build` to confirm lint and build health together.

---

## Example: non-obvious rule — `noAutofocus`

Biome enforces accessibility rules including `noAutofocus`. This is not a style preference — it prevents unexpected focus-stealing for keyboard and screen reader users.

Bad pattern:

```tsx
<input autoFocus />
```

Preferred pattern:

```tsx
const inputRef = useRef<HTMLInputElement>(null);

useEffect(() => {
  inputRef.current?.focus();
}, []);

<input ref={inputRef} />
```

The `useEffect` approach gives the component explicit control over focus timing. The `autoFocus` attribute fires immediately on mount, which disorients users navigating by keyboard or assistive technology.

---

## PR policy

Required status checks on all Chamber 19 frontend PRs:

- Biome lint (`npm run lint` passes)
- TypeScript build (`npm run build` passes)
- Block merge on lint errors
- Treat warnings as informational only; upgrade to errors incrementally as repos mature

PR checklist:

- [ ] `npm run lint` passes
- [ ] `npm run build` passes
- [ ] Any suppression includes a justification comment and a tracking reference

---

## Org-wide correction workflows

Reusable GitHub Actions workflows for Biome are tracked in the workspace-level `IMPLEMENTATION_PLAN.md`. They are not yet wired to product repos. The planned shape:

**Read-only gate** (`biome-check.yml` — reusable, consumed by product repos):

```yaml
name: biome-check
on:
  workflow_call:
    inputs:
      node-version:
        required: false
        type: string
        default: "20"
      lint-target:
        required: false
        type: string
        default: "src"
jobs:
  check:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: ${{ inputs.node-version }}
          cache: npm
      - run: npm ci
      - run: npx biome check ${{ inputs.lint-target }}
```

**Scheduled auto-correction** (`biome-autofix.yml` — runs weekly, opens a PR):

```yaml
name: biome-autofix
on:
  schedule:
    - cron: "0 3 * * 1"
  workflow_dispatch:
permissions:
  contents: write
  pull-requests: write
jobs:
  autofix:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          ref: main
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci
      - run: npx biome check --write .
      - name: Create PR if changes exist
        uses: peter-evans/create-pull-request@v7
        with:
          branch: chore/biome-autofix
          title: "chore: biome autofix"
          commit-message: "chore: apply biome autofixes"
          body: |
            Automated Biome autofix run.
            Applied safe lint and format fixes. Review any semantic-sensitive changes before merging.
```

Safety contract: never push directly to `main`. Always create a PR. Keep branch names stable (`chore/biome-autofix`) so stale PRs are updated, not duplicated.

---

## Rule governance

Shared rule sets live in `chamber-19/org-maintenance/biome/`:

- `biome.base.json` — org minimum standards, inherited by all repos
- `biome.strict.json` — opt-in stricter rules for mature repos

Per-repo policy:

- Inherit from `biome.base.json`
- Allow narrow repo-specific overrides only with a written rationale in the repo's `copilot-instructions.md`
- Document temporary suppressions with an owner and an expiry target

---

## Suppression policy

Suppress the smallest possible scope. Include a reason and a follow-up reference.

```ts
// biome-ignore lint/a11y/noAutofocus: Temporary for kiosk-mode login; remove when ENG-1234 is resolved
<input autoFocus />
```

Never add file-wide or directory-wide ignores without architecture review. A suppression without a justification comment is a lint violation that should be flagged in review.

---

## Incremental adoption strategy

For repos with existing violations, adopt in phases rather than fixing everything at once:

1. Start in check-only mode — no auto-fix, just visibility.
2. Scope to the most active directory first (typically `src/components/`).
3. Enable the autofix PR workflow after the initial cleanup pass.
4. Increase strictness in phases:
   - Phase A: formatting and obvious correctness
   - Phase B: accessibility rules and suspicious patterns
   - Phase C: stricter style and correctness rules

Track the violation count weekly. The target is a downward trend, not an immediate zero. New violations introduced on a branch should be resolved before merge; do not let the baseline grow.

---

## Troubleshooting

| Symptom | Cause | Fix |
| --- | --- | --- |
| Biome passes locally, fails in CI | Node version mismatch or lockfile drift | Pin Node version in workflow; run `npm ci` locally to reproduce CI exactly |
| Autofix PR keeps changing the same files | Competing formatter in CI or editor | Make Biome the single source of truth for formatting; remove overlapping formatter writes |
| Accessibility rule broke a UX flow | Rule conflicts with a legitimate interaction pattern | Prefer the compliant implementation; if suppression is unavoidable, add scoped ignore with tracking reference |

---

## Quick reference

```bash
# Check lint rules (read-only)
npm run lint

# Apply safe auto-fixes
npm run lint:fix

# Format source files
npm run format

# Validate lint and build together before opening a PR
npm run lint && npm run build
```

---

## References

- [Biome documentation](https://biomejs.dev/guides/getting-started/)
- [Biome GitHub](https://github.com/biomejs/biome)
- Reusable workflows: tracked in the workspace-level `IMPLEMENTATION_PLAN.md`
