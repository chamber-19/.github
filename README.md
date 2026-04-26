# chamber-19/.github

This repository holds the Chamber 19 organization's shared configuration and landing page assets.

## What lives here

- `profile/README.md` — the landing page rendered at https://github.com/chamber-19
- `.github/copilot-instructions.md` — family-wide GitHub Copilot guidance inherited by every repo in the org
- `.github/CONTRIBUTING.md`, `.github/SECURITY.md`, `.github/SUPPORT.md` (future) — fallback templates for repos that don't define their own

## How inheritance works

GitHub treats a repo named `.github` under an org as a community defaults repo. The inheritance is:

- If a consumer repo has its own `.github/copilot-instructions.md`, it is loaded **alongside** (not instead of) the org-shared file. Both apply.
- If a consumer repo lacks one of the templated files (CONTRIBUTING, SECURITY, etc.), GitHub falls back to the org-shared version.
- If a consumer repo has its own version, the consumer's version wins.

In practice this means the org-shared `copilot-instructions.md` should hold *only* family-wide rules. Repo-specific rules belong in each repo's own file.

## Contributing

Changes here propagate immediately to every repo in the chamber-19 org. Treat updates with the same care as a `desktop-toolkit` framework change — review carefully, test mentally against each consumer's existing rules, and prefer additive changes over breaking ones.
