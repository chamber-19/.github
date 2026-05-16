---
applyTo: "**/*.{tsx,jsx,ts,js,html,vue,css,scss,sass,less}"
---

# UI/UX Discipline — Chamber 19 user-interface rules

These rules apply to any change that affects what a human sees, hears, or interacts with in a Chamber 19 product: React components, styles, HTML, Tauri webview UI, splash and update flows, activation screens, error/empty states, user-facing copy, and accessibility behavior. For the complete reference — toolkit primitive reuse contract, theme governance, microcopy rules, accessibility contract, and AI push-back contract — read `docs/skills/UI_UX_DISCIPLINE.md` in the `chamber-19/.github` repo.

## Scope

UI/UX Discipline applies to UI-affecting files in every Chamber 19 repo. Backend-only files (Python sidecars, Rust commands without UI hookup) are out of scope. Pair this skill with `CSS_DISCIPLINE.md` for any `.css`/`.scss` work.

## Non-negotiable

- **MUST** consult this skill **before** the first edit to a UI file — loading it after is too late
- **MUST** use toolkit primitives when one exists — `ToolkitThemeProvider`, `ActivationGate`, `UpdateModal`, `ReleaseNotes`, canonical Sidebar + TopBar scaffold all live in `@chamber-19/desktop-toolkit`
- **MUST** preserve toolkit-supplied accessibility (focus rings, ARIA labels, keyboard navigation) — PR description explains any removal
- **MUST** treat theme as toolkit-controlled — consumer apps consume `TOOLKIT_PALETTES`, do not ship their own
- **MUST** honor `prefers-reduced-motion` for every animation
- **MUST** add `id` + `name` to every `<input>`, `<select>`, `<textarea>` with label association
- **MUST** use `<button>` for clickable actions — never `<div onClick>` or `<span onClick>`
- **MUST** color contrast meet WCAG AA (4.5:1 normal text, 3:1 large/UI)
- **NEVER** duplicate toolkit shell components in a consumer app — extend the toolkit instead
- **NEVER** ship a consumer-app-local palette — palette additions land in the toolkit and propagate via pin bump
- **NEVER** write `outline: none` without `:focus-visible` with an equivalent visible ring
- **NEVER** use exclamation points in user-facing copy — tone is warm, matter-of-fact, engineering-grade
- **NEVER** introduce purple gradients on white, or use Inter/Roboto/Arial fonts — explicit brand violations
- **NEVER** rely on color alone to convey meaning — pair with text, icon, or shape

## Build-blocking

`@chamber-19/biome-config` enforces accessibility rules (`noAutofocus`, `useButtonType`, `useValidAriaProps`). `@chamber-19/stylelint-config` enforces CSS rules. CI emits `::error` annotations on the PR's Files Changed tab.

## AI push-back contract

When asked to do UI work, refuse to duplicate toolkit primitives, ship consumer-local palettes, write inaccessible markup, or use marketing tone. Explain the cost and propose the correct alternative in the same turn. When pushed back, escalate with a specific question — never silently comply.
