---
mode: agent
description: Bump the version of this app/package across all manifest files, regenerate lockfiles, and update CHANGELOG.
---

# Release version bump

You are bumping this repository's version to a new release. Ask the user
for the target version (e.g. `v0.4.2`) if not provided.

## Procedure

### Step 1 — Find all versioned manifest files

Common locations — check all that exist in this repo:

- `package.json` (root and any workspace packages)
- `frontend/package.json`
- `src-tauri/tauri.conf.json` or `frontend/src-tauri/tauri.conf.json`
- `src-tauri/Cargo.toml` or `frontend/src-tauri/Cargo.toml`
- `pyproject.toml`
- PowerShell module manifests (`*.psd1`)

List every file found before making any changes.

### Step 2 — Update every version field

Update all files found in Step 1 to the target version. Every version
field must agree. Mismatched versions between manifests cause build and
installer failures.

### Step 3 — Regenerate lockfiles

```bash
# JS lockfile
npm install

# Rust lockfile — update only this crate, not all deps
cargo update -p <crate-name>
cargo check
```

Commit both `package-lock.json` and `Cargo.lock` with the bump.

### Step 4 — Update CHANGELOG.md

Add a new section for the target version. Use the following to get the
list of commits since the previous tag:

```bash
git log $(git describe --tags --abbrev=0)..HEAD --oneline
```

Summarize meaningful changes only — skip dependency-only commits and
formatting fixes unless they are user-visible.

### Step 5 — Verify the build

Run the repo's standard test and build command:

```bash
npm test && cargo check
```

Both must pass before opening the PR. If either fails, fix it first.

### Step 6 — Open a PR

Title: `chore(release): vX.Y.Z`

The PR must contain only:
- Manifest version bumps (Step 2)
- Regenerated lockfiles (Step 3)
- CHANGELOG update (Step 4)

## Non-goals

- No code changes outside version metadata and CHANGELOG
- Do not tag or publish — that happens after PR merge and CI passes
- Do not modify CI workflows
- Do not combine with feature work

## Verification report

When complete, report:

1. Every manifest file updated and its new version value
2. Output of `npm test && cargo check`
3. The CHANGELOG section added
