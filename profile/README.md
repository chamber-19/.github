<!-- markdownlint-disable MD013 -->
# Chamber 19

Engineering software for [Root 3 Power](https://root3power.com), built around AutoCAD and Tauri.

## Tools

| Repo | Role |
| --- | --- |
| [`desktop-toolkit`](https://github.com/chamber-19/desktop-toolkit) | Shared framework for Tauri desktop apps — splash, updater, NSIS installer, Python sidecar plumbing |
| [`launcher`](https://github.com/chamber-19/launcher) | Desktop tool shell — installs, updates, and launches Chamber 19 tools |
| [`transmittal-builder`](https://github.com/chamber-19/transmittal-builder) | Standalone Tauri app for generating engineering transmittals |
| [`Drawing-List-Manager`](https://github.com/chamber-19/Drawing-List-Manager) | Standalone Tauri app for project drawing registers |

## Design system

- **Background:** `#1C1B19` — warm dark
- **Accent:** `#C4884D` — copper
- **Body type:** DM Sans
- **Display type:** Instrument Serif
- **Mono / data:** JetBrains Mono

Warm industrial tone. Engineering-grade, not corporate-slick. Short, matter-of-fact copy.

## Conventions

- All repos use SemVer
- GitHub Releases is the distribution channel
- Plugins and the launcher release on independent tags
- The `desktop-toolkit` framework is version-pinned by each consumer; bumps are deliberate

See [`.github/copilot-instructions.md`](./.github/copilot-instructions.md) for org-wide Copilot guidance.
