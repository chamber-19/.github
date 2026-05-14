# CSS Discipline Skill

Read this skill **before any edit to a CSS, SCSS, Sass, Less file, or any inline style block in a JSX, TSX, Vue, or HTML file** in any Chamber 19 repo. This skill governs how styles are written: token contract, cascade discipline, selector hygiene, and the override extension pattern. Violations are build-blocking under `@chamber-19/stylelint-config`.

Trigger keywords for AI loading: CSS, SCSS, Sass, Less, styling, style, theme, palette, hex color, color token, design token, sidebar, topbar, top bar, navbar, button, modal, form, layout, component design, font, typography, font-family, font-size, line-height, spacing, margin, padding, border, border-radius, box-shadow, z-index, cascade, specificity, `!important`, override, dark mode, light mode, accessibility contrast, accent color, surface color, background, foreground, design system, visual design, UI polish, animation, transition, keyframe, focus ring, hover state, active state.

---

## Scope

CSS Discipline applies to:

| File type | Scope |
| --- | --- |
| `.css`, `.scss`, `.sass`, `.less` | All declarations |
| `.jsx`, `.tsx` inline `style={{ ... }}` objects | Color, border, spacing, font, shadow, z-index values |
| `.html` `<style>` blocks | All declarations |
| `.vue` `<style>` blocks | All declarations |

It does **not** apply to:

- CSS-in-JS strings inside Rust string literals (Tauri webview-injected styles) — those follow toolkit conventions but are outside stylelint's reach
- Generated CSS in `dist/`, `node_modules/`, or any build artifact
- Third-party CSS in `vendor/` directories

---

## Why this skill exists

CSS damage accumulates silently. Three patterns we have already had to clean up in Chamber 19:

1. **Hex colors duplicated across consumer apps.** A palette change in `desktop-toolkit` should re-skin every app for free. When consumer apps hardcode `#1C1B19` they break that contract — and you discover it only at the next palette iteration.
2. **`!important` fighting the cascade.** When a stylesheet uses `!important` to win, it means the cascade was fighting it. The fix is to find the source selector that's outranking the rule, not to bandage it. We saw this in `CivilEngineeringPlanner/src/styles/_layout.css` on `.topbar-heading`, `.topbar-date`, `.topbar-time`. We do not bring that pattern over.
3. **Naked element selectors in component CSS** (`h1 { font-size: 21px }`, `p { color: #aebbd0 }`). These leak into every consumer app that renders an `h1` or `p` inside that component's tree, causing accidental collisions and double-cascades. Component CSS uses **classes only**.

---

## Non-negotiable rules

- **MUST** reference design tokens for all color, spacing, radius, shadow, font, line-height, letter-spacing, and z-index values. Tokens live in `desktop-toolkit/js/packages/desktop-toolkit/src/theme/` (CSS variables prefixed `--ch-*`) and consumer-app local equivalents. No raw hex, `rgb()`, or `hsl()` outside a tokens file.
- **MUST** use **classes only** in component CSS. Naked element selectors (`h1`, `p`, `button`, `input`) are allowed **only** in a single per-repo reset file (`_reset.css` or equivalent).
- **MUST** keep all token definitions in one canonical file per repo (`_tokens.css` or the toolkit's theme module). Custom extensions go in `_theme.override.css` per the documented extension pattern — never inline edits to the canonical file.
- **MUST** scope every selector to the component class it belongs to. No bare class selectors that could accidentally match across components — prefer `.app-card-title` over `.title`.
- **MUST** add a `:focus-visible` rule whenever you remove or override the browser default outline. `outline: none` without `:focus-visible` is an accessibility violation.
- **MUST** include a justification comment when overriding a toolkit-supplied component style. Format: `/* override toolkit: reason — link */`.
- **NEVER** write `!important`. If the cascade is fighting the rule, the fix is to find the source rule that's outranking it. The only legitimate use is overriding a third-party stylesheet inside a heavily-scoped class, and even then the override file is the place — not the component file.
- **NEVER** write hex colors, `rgb()`, or `hsl()` values outside the tokens file or `_theme.override.css`. This is enforced by the `color-no-hex` stylelint rule.
- **NEVER** write naked element selectors in component CSS (`h1`, `h2`, `p`, `a`, `button`, `input`, `select`, `textarea`). These go in the reset file only. Enforced by `selector-max-type: 0`.
- **NEVER** duplicate token definitions across consumer apps. If a consumer app defines its own `--bg`, `--accent`, or `--text-1` matching the toolkit's contract, that's drift waiting to happen. Reference the toolkit's tokens instead.
- **NEVER** style state with raw colors (`background: green` for success). Reference the semantic token (`var(--ch-success)`).
- **NEVER** use arbitrary z-index numbers. All z-index values come from `--z-*` tokens (`--z-base`, `--z-raised`, `--z-sticky`, `--z-modal`, `--z-toast`, `--z-overlay`).

---

## The override extension pattern

Chamber 19 uses a deliberate **last-loaded override file** pattern adapted from `CivilEngineeringPlanner/src/styles/_theme.override.css`. The shape:

```text
main.css (or main.scss)
├── _tokens.css            ← canonical tokens, ONLY hex allowed here
├── _fonts.css             ← @import / @font-face declarations
├── _reset.css             ← naked element selectors allowed
├── _typography.css        ← utility classes
├── ...                    ← component layer (classes only)
└── _theme.override.css    ← LAST IMPORT — cherry-pick extension slot
```

`_theme.override.css` is **not** for fixing component bugs. It exists for two reasons:

1. **Defining a `[data-theme="custom"]` palette** without editing the canonical tokens file
2. **Orthogonal style axes** like `[data-font-style="..."]` — these decouple typography choice from color choice and let users mix them

Anything else that ends up in `_theme.override.css` is a signal the canonical file needs a rule added, not a workaround.

---

## Token contract

Chamber 19 standardizes on these token categories. All values must come from this contract.

| Category | Token shape | Examples |
| --- | --- | --- |
| Color | `--ch-{role}` | `--ch-bg`, `--ch-accent`, `--ch-text`, `--ch-muted`, `--ch-border`, `--ch-success`, `--ch-warning`, `--ch-error`, `--ch-info` |
| Surface elevation | `--ch-surface-{n}` | `--ch-surface-0` through `--ch-surface-3` |
| Typography font | `--ch-font-{role}` | `--ch-font-display`, `--ch-font-ui`, `--ch-font-data` |
| Typography scale | `--ch-text-{step}` | `--ch-text-2xs` through `--ch-text-3xl` |
| Weight | `--ch-weight-{name}` | `--ch-weight-regular`, `--ch-weight-semibold` |
| Line height | `--ch-leading-{name}` | `--ch-leading-tight`, `--ch-leading-body` |
| Letter spacing | `--ch-tracking-{name}` | `--ch-tracking-tight`, `--ch-tracking-wide` |
| Spacing | `--ch-space-{n}` | `--ch-space-1` (4px) through `--ch-space-24` (96px) |
| Radius | `--ch-radius-{name}` | `--ch-radius-sm`, `--ch-radius-md`, `--ch-radius-pill` |
| Z-index | `--ch-z-{name}` | `--ch-z-sticky`, `--ch-z-modal`, `--ch-z-overlay` |
| Duration | `--ch-dur-{name}` | `--ch-dur-fast`, `--ch-dur-base` |
| Easing | `--ch-ease-{name}` | `--ch-ease-out`, `--ch-ease-spring` |
| Shadow | `--ch-shadow-{name}` | `--ch-shadow-md`, `--ch-shadow-glow` |

Inline JSX `style` objects reference these via CSS variable syntax:

```tsx
// CORRECT
<div style={{ background: 'var(--ch-bg)', color: 'var(--ch-text)' }} />

// WRONG — hardcoded hex
<div style={{ background: '#1C1B19', color: '#EFEAE2' }} />
```

---

## Right vs wrong examples

### Hex outside tokens

```css
/* WRONG — _layout.css, _course.css, etc. */
.course-card {
  background: rgba(255, 255, 255, 0.04);
  color: #aebbd0;
  border: 1px solid rgba(196, 136, 77, 0.18);
}

/* CORRECT */
.course-card {
  background: var(--ch-surface-1);
  color: var(--ch-text-2);
  border: 1px solid var(--ch-accent-muted);
}
```

### `!important`

```css
/* WRONG — fighting the cascade */
.topbar-heading {
  font-size: clamp(18px, 2vw, 26px) !important;
  font-weight: 900 !important;
  color: #ffffff !important;
}

/* CORRECT — find the rule outranking this and scope it properly */
.app-shell .topbar-heading {
  font-size: clamp(var(--ch-text-md), 2vw, var(--ch-text-xl));
  font-weight: var(--ch-weight-bold);
  color: var(--ch-text-1);
}
```

### Naked element selectors

```css
/* WRONG — collides across every component */
h1 {
  margin-bottom: 0;
  font-size: 21px;
}
p, small, span {
  color: #aebbd0;
}

/* CORRECT — class-scoped */
.workspace-heading {
  margin-bottom: 0;
  font-size: var(--ch-text-lg);
}
.workspace-body {
  color: var(--ch-text-2);
}
```

### Focus rings

```css
/* WRONG — strips keyboard accessibility */
.btn {
  outline: none;
}

/* CORRECT */
.btn {
  outline: none;
}
.btn:focus-visible {
  outline: 2px solid var(--ch-accent);
  outline-offset: 2px;
}
```

---

## Build-blocking enforcement

These rules are enforced by `@chamber-19/stylelint-config` (toolkit-published) and `@chamber-19/stylelint-plugin-chamber19` (custom rule wrappers). Every consumer repo's CI runs:

```bash
stylelint "**/*.{css,scss,sass,less}" --max-warnings 0
```

Violations fail the build with an explicit Chamber 19 error message of the form:

```text
src/components/Foo.css:42:5
✖ Disallowed: direct hex `#1C1B19`.
  Chamber 19 toolkit rule: use --ch-bg or extend via _theme.override.css.
  Reference: chamber-19/.github → docs/skills/CSS_DISCIPLINE.md
```

CI emits the same message as a `::error` annotation on the PR's Files Changed tab.

A pre-commit hook (husky / lefthook, per repo) runs the same check locally so violations are caught before push.

---

## AI push-back contract

When asked to write or modify CSS in any Chamber 19 repo, AI agents **must**:

1. Load this skill into context before the first edit.
2. Refuse to write hex outside the tokens file. Explain the cost (palette drift, build failure) rather than complying. Suggest the right token or recommend adding one if missing.
3. Refuse to add `!important`. Trace the cascade conflict and propose the source-rule fix.
4. Refuse to write naked element selectors in component CSS. Convert to class-scoped.
5. Treat user requests like *"just use `#fff` for now"* as a discipline violation. Push back, explain, and offer the token-based alternative.

The push-back is not optional. A complying-then-warning response defeats the discipline — the bad code is already in the diff. Refuse and propose the correct alternative in the same turn.

---

## Suppression policy

There is no per-line suppression for this skill's rules. If you genuinely need a hex outside the tokens file (e.g., an external integration that requires a specific brand color), the path is:

1. Add the color as a named token in the canonical tokens file with a comment explaining why it's not a Chamber 19 brand color
2. Reference the token from the component CSS
3. PR description must call out the addition for review

`/* stylelint-disable */` comments are forbidden in component CSS. They may appear only in `_tokens.css` (where hex is legitimately required) and `_theme.override.css` (the extension slot). Both files already have a top-of-file `stylelint-disable` comment.

---

## Related skills

- [`BIOME.md`](BIOME.md) — JS/TS lint rules; works alongside this skill for component files with both `.tsx` and `.css`
- [`UI_UX_DISCIPLINE.md`](UI_UX_DISCIPLINE.md) — broader UI/UX rules including accessibility, toolkit primitive reuse, and consent-gated custom theming
- [`MARKDOWN.md`](MARKDOWN.md) — applies to this file itself

---

## When in doubt

1. Check `desktop-toolkit/docs/theme-system-preview.html` for the canonical visual contract.
2. Check the toolkit's theme module source for available tokens.
3. Ask before adding a token — token sprawl is its own discipline problem.
