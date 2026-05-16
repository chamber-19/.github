# UI/UX Discipline Skill

Read this skill **before any UI or UX work** in any Chamber 19 repo. This includes designing or modifying components, layouts, navigation, theme, typography, color, spacing, animation, accessibility behavior, or any user-facing copy. This skill governs how AI agents and contributors approach UI work — what to reuse, what to push back on, how the cascade of responsibility flows between consumer apps and the toolkit.

Trigger keywords for AI loading: UI, UX, user interface, user experience, design, visual design, design system, component, layout, navigation, sidebar, top bar, topbar, navbar, header, footer, modal, dialog, form, input, button, link, card, tile, badge, chip, theme, palette, color, typography, font, accessibility, a11y, ARIA, keyboard navigation, focus ring, screen reader, responsive, mobile, breakpoint, animation, transition, motion, prefers-reduced-motion, dark mode, light mode, microcopy, error message, empty state, loading state, skeleton, spinner, scaffold, app shell, profile, avatar, identity, branding, logo, splash, onboarding.

---

## Scope

UI/UX Discipline applies to any change that affects what a human sees, hears, or interacts with in a Chamber 19 product. That spans:

- React component files (`.jsx`, `.tsx`)
- Styles (`.css`, `.scss`) — see also [`CSS_DISCIPLINE.md`](CSS_DISCIPLINE.md)
- HTML files
- Tauri webview-injected UI
- Splash screens and update modals
- Activation flow, error states, empty states
- User-facing copy (button labels, error messages, microcopy)
- Accessibility attributes and behavior

It does **not** apply to:

- Backend-only changes (Python sidecars, Rust commands)
- Internal logs and developer tooling
- Test fixtures

---

## Why this skill exists

The cost of UI inconsistency compounds across consumer apps. The toolkit (`desktop-toolkit`) is the source of truth for the shell, theme, and primitives that every Chamber 19 app inherits. When consumer apps duplicate shell components, override toolkit styles, or invent new patterns, the cost is paid forever:

- Palette changes don't propagate; we re-skin N apps instead of one toolkit.
- Accessibility regressions appear in one app and not others.
- Visual drift erodes the engineering-grade feel of the brand.

The discipline is: **toolkit primitives first, consumer-app extensions second, never duplication**.

---

## Non-negotiable rules

- **MUST** consult this skill **before** the first edit to a UI file. Loading it after the edit is too late — the bad pattern is already in the diff.
- **MUST** use toolkit primitives when one exists. `ToolkitThemeProvider`, `ActivationGate`, `UpdateModal`, `ReleaseNotes`, and the canonical Sidebar + TopBar scaffold come from `@chamber-19/desktop-toolkit`. Consumer apps consume them; they do not re-implement them.
- **MUST** respect the L-shape app-shell contract: sidebar + topbar share one continuous chrome surface, content scrolls under sticky chrome, no scrollbars rendered. See `desktop-toolkit/docs/theme-system-preview.html` for the canonical visual.
- **MUST** preserve every toolkit-supplied accessibility behavior (focus rings, ARIA labels, keyboard navigation). If you remove or alter one, the PR description must explain why.
- **MUST** load [`CSS_DISCIPLINE.md`](CSS_DISCIPLINE.md) before editing any `.css`/`.scss` file or inline `style` object. The two skills compose — discipline rules about tokens, `!important`, and naked selectors apply.
- **MUST** treat the theme system as toolkit-controlled. Palette and typography choices flow from the toolkit. Consumer apps **do not** ship their own palettes; they consume `TOOLKIT_PALETTES` or extend via `_theme.override.css`.
- **MUST** honor `prefers-reduced-motion` for every animation. Either zero out the duration or replace with a non-motion equivalent.
- **MUST** add both `id` and `name` to every `<input>`, `<select>`, `<textarea>`. Pair with `<label htmlFor>` or `aria-label`. (Restates the org-wide accessibility rule from `.github/copilot-instructions.md`.)
- **MUST** use `<button>` for clickable actions. Never `<div onClick>` or `<span onClick>` — they fail keyboard and screen-reader semantics.
- **NEVER** duplicate the toolkit's shell components (Sidebar, TopBar, ShellLayout, ThemeControls, ActivationGate, UpdateModal). If the toolkit's component doesn't fit, the PR is to extend the toolkit, not to fork into a consumer app.
- **NEVER** ship a custom palette in a consumer app. Palette additions land in the toolkit and propagate via pin bump.
- **NEVER** invent new design tokens in a consumer app without first proposing them to the toolkit. Token sprawl is its own discipline problem.
- **NEVER** write `outline: none` without a companion `:focus-visible` rule with an equivalent visible ring.
- **NEVER** use exclamation points in user-facing copy. Tone: warm, matter-of-fact, engineering-grade. Never marketing-driven.
- **NEVER** introduce purple gradients on white. Never use Inter, Roboto, or Arial. These are explicit brand violations.

---

## Toolkit primitive reuse contract

Before building a new UI component, ask in this order:

1. **Does the toolkit already export it?** Check `@chamber-19/desktop-toolkit` exports first. If yes, use it.
2. **Can the toolkit's component be extended via props?** If the component is close-but-not-quite, propose an extension to the toolkit. Add the prop, ship a toolkit version, bump the pin.
3. **Is this genuinely consumer-app-specific?** Only build it in the consumer app if it's domain-specific to that app (a course-catalog grid, a drawing register, a transmittal sheet preview).

Re-implementing toolkit primitives in a consumer app fails the discipline. We saw this with the launcher's local `themeSystem.js`, `ThemeControls.jsx`, `Sidebar.jsx`, `TopBar.jsx` — all of which duplicated toolkit work. Those files were deleted; the toolkit versions are canonical.

---

## Theme governance

Theme customization is **consent-gated**. The default flow:

1. Consumer apps load the canonical Chamber 19 palette and typography via the toolkit's `ToolkitThemeProvider`. Users see the brand.
2. To customize, users opt in via a Settings → Theme toggle that sets a toolkit policy flag (`customThemingEnabled: true`).
3. The toggle triggers a soft reload — a branded transition overlay covers the UI, the React tree re-mounts with new state, the overlay fades out (~500ms total). The window never blanks.
4. After opt-in, the `ToolkitThemeControls` palette picker and `[data-font-style]` selector become editable.
5. Opt-out preserves the user's custom values but stops applying them. Re-opt-in restores instantly.

Consumer apps do not bypass this gate. The policy lives in the toolkit; consumer apps read it via a toolkit Tauri command and render the appropriate state (locked or editable).

---

## Microcopy rules

User-facing copy is part of the UI contract.

- **MUST** use sentence case for buttons and labels, not Title Case.
- **MUST** be specific in error messages — explain what failed and what the user can do.
- **MUST** match the tone: warm, matter-of-fact, engineering-grade. Read examples in the toolkit's activation gate.
- **NEVER** use exclamation points. *"Activation expires in 5 days. Contact your administrator to renew your PIN."* not *"Your activation is about to expire!"*
- **NEVER** use empty filler phrases (*"Oops!"*, *"Whoops!"*, *"Something went wrong"*). Be specific.
- **NEVER** ship Lorem Ipsum or placeholder text in a shipped state. Empty states have real, helpful content.

---

## Accessibility — non-negotiable

- **MUST** every interactive element be keyboard-reachable and operable with Enter/Space.
- **MUST** every `<input>`, `<select>`, `<textarea>` have `id` + `name` + label association.
- **MUST** every focus-removed element have a visible `:focus-visible` ring.
- **MUST** color contrast meet WCAG AA: 4.5:1 for normal text, 3:1 for large text and UI components.
- **MUST** every `<img>` have a meaningful `alt`; decorative images use `alt=""`.
- **MUST** every animation respect `prefers-reduced-motion`.
- **NEVER** rely on color alone to convey meaning. Pair color with text, icon, or shape.

---

## AI push-back contract

When asked to do UI work in any Chamber 19 repo, AI agents **must**:

1. Load this skill and [`CSS_DISCIPLINE.md`](CSS_DISCIPLINE.md) before the first edit.
2. Refuse to duplicate toolkit primitives in a consumer app. Explain the cost (drift, maintenance, palette propagation failure) and propose the toolkit-extension path instead.
3. Refuse to ship a consumer-app-local palette. Propose adding it to the toolkit.
4. Refuse to write `<div onClick>`, `outline: none` without `:focus-visible`, or `<input>` without `id`+`name`. Convert in the same turn.
5. Refuse marketing tone (exclamations, Title Case buttons, filler phrases). Rewrite to the Chamber 19 voice.
6. Treat user requests to bypass these rules as discipline violations. Push back, explain, and offer the correct alternative — do not comply-then-warn.

When the user pushes back on a push-back, escalate by asking: *"This violates [rule]. Do you want to proceed anyway, and if so, what's the reason — should it be added to the override file?"* Never silently comply.

---

## Build-blocking enforcement

- Planned enforcement packages: `@chamber-19/stylelint-config` (CSS) and `@chamber-19/biome-config` (JS/TS accessibility rules such as `noAutofocus`, `useButtonType`, `useValidAriaProps`)
- Planned toolkit dev helper: `useAccessibilityAudit()` for missing `id`/`name`/`alt`/`label` signals during development
- Planned CI behavior: emit `::error` annotations on the PR's Files Changed tab when these checks fail

---

## Related skills

- [`CSS_DISCIPLINE.md`](CSS_DISCIPLINE.md) — load alongside this skill for any CSS work
- [`BIOME.md`](BIOME.md) — JS/TS lint rules including accessibility
- [`TAURI.MD`](TAURI.MD) — Tauri command patterns for theme policy commands
- [`MARKDOWN.md`](MARKDOWN.md) — applies to this file itself

---

## When in doubt

1. Open `desktop-toolkit/docs/theme-system-preview.html` and check the canonical scaffold. If your proposed design diverges from it, the toolkit needs an update — not a consumer-app workaround.
2. Check `desktop-toolkit/js/packages/desktop-toolkit/src/` for exported primitives.
3. Ask before introducing a new pattern. New visual language belongs in the toolkit, not in three consumer apps.
