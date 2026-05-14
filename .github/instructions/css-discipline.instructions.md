---
applyTo: "**/*.{css,scss,sass,less}"
---

# CSS Discipline — Chamber 19 styling rules

These rules apply when writing or editing CSS, SCSS, Sass, or Less files in any Chamber 19 repo. They also apply to inline `style={{ ... }}` objects in `.jsx`/`.tsx` (loaded via the matching wrapper). For the complete reference — token contract, override extension pattern, build enforcement, and AI push-back contract — read `docs/skills/CSS_DISCIPLINE.md` in the `chamber-19/.github` repo.

## Scope

CSS Discipline applies to `.css`, `.scss`, `.sass`, `.less` files in every Chamber 19 repo. Inline JSX/TSX `style` objects fall under the broader UI/UX wrapper.

## Non-negotiable

- **MUST** reference design tokens (`--ch-*`) for all color, spacing, radius, shadow, font, line-height, letter-spacing, and z-index values
- **MUST** use classes only in component CSS — naked element selectors (`h1`, `p`, `button`, `input`) belong in `_reset.css` only
- **MUST** scope every selector to a component class — no bare `.title`, prefer `.app-card-title`
- **MUST** add a `:focus-visible` rule when overriding the default outline — `outline: none` alone is an accessibility violation
- **MUST** include a justification comment when overriding a toolkit-supplied component style — format: `/* override toolkit: reason — link */`
- **NEVER** write `!important` — if the cascade is fighting the rule, find the source rule outranking it
- **NEVER** write hex, `rgb()`, or `hsl()` outside the canonical tokens file or `_theme.override.css`
- **NEVER** duplicate token definitions across consumer apps — reference the toolkit's tokens instead
- **NEVER** use arbitrary z-index numbers — reference `--ch-z-*` tokens

## Build-blocking

`@chamber-19/stylelint-config` enforces these rules with `--max-warnings 0`. Violations fail CI with a Chamber 19 error message pointing back to `docs/skills/CSS_DISCIPLINE.md`. A pre-commit hook runs the same check locally.

## AI push-back contract

When asked to write CSS in a Chamber 19 repo, refuse hex outside tokens, `!important`, and naked element selectors in component CSS. Explain the cost and propose the token-based alternative in the same turn. Never comply-then-warn — the bad code is already in the diff.

## Suppression policy

`/* stylelint-disable */` comments are forbidden in component CSS. They appear only in `_tokens.css` (top-of-file) and `_theme.override.css`. If you genuinely need a non-token color, add it to the tokens file with a comment and PR-description callout — never inline.
