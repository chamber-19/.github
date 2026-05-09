# Chamber 19

Engineering software for [Root 3 Power](https://root3power.com), built
around AutoCAD and Tauri.

## Tools

<!-- family-table:start -->
| Repo | Role |
|---|---|
| [`desktop-toolkit`](https://github.com/chamber-19/desktop-toolkit) | Shared framework for Tauri desktop apps — splash, updater, NSIS installer, Python sidecar plumbing |
| [`launcher`](https://github.com/chamber-19/launcher) | Desktop launcher and updater — installs, updates, and launches Chamber 19 tools |
| [`transmittal-builder`](https://github.com/chamber-19/transmittal-builder) | Standalone Tauri app for generating engineering transmittal packages |
| [`Drawing-List-Manager`](https://github.com/chamber-19/Drawing-List-Manager) | Standalone Tauri app for project drawing registers |
| [`batch-fnr`](https://github.com/chamber-19/batch-fnr) | Batch DXF Find-and-Replace — Tauri 2 desktop app with headless .NET AutoCAD sidecar |
| [`block-library`](https://github.com/chamber-19/block-library) | Tauri 2 desktop DXF viewer with Google Drive catalog sync and SQLite local cache |
| [`Foundry`](https://github.com/chamber-19/Foundry) | Local agent broker — routes GitHub and Discord jobs to local LLMs via Ollama |
| [`autocad-knowledge`](https://github.com/chamber-19/autocad-knowledge) | Reference patterns and knowledge base for AutoCAD .NET plugins |
| [`IFA-IFC-Checklist`](https://github.com/chamber-19/IFA-IFC-Checklist) | Macro-enabled Excel workbook for IFA and IFC pre-submittal checklists |
| [`.github`](https://github.com/chamber-19/.github) | TODO: curate whether this org-config repo should be listed in the public tools table |
<!-- family-table:end -->

## Design system

| Token | Value |
|---|---|
| Background | `#1C1B19` — warm dark |
| Accent | `#C4884D` — copper |
| Success | `#6B9E6B` |
| Warning | `#C4A24D` |
| Error | `#B85C5C` |
| Info | `#5C8EB8` |
| Body type | DM Sans |
| Display type | Instrument Serif |
| Mono / data | JetBrains Mono |

Warm industrial tone. Engineering-grade, not corporate-slick. Short,
matter-of-fact copy.

## Conventions

- All repos use SemVer (`vMAJOR.MINOR.PATCH`)
- GitHub Releases is the distribution channel
- Plugins and the launcher release on independent tags
- `desktop-toolkit` is version-pinned by each consumer; bumps are
  deliberate PRs that update npm and Cargo pins together

See [`.github/copilot-instructions.md`](./.github/copilot-instructions.md)
for org-wide Copilot and agent guidance.
