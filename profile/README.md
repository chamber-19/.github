# Chamber 19

Engineering software and local AI infrastructure for
[Root 3 Power](https://root3power.com).

Two tightly coupled tracks:

**Engineering desktop tools** — Tauri desktop apps with Rust shells and
Python backends supporting substation design workflows: transmittal
builders, drawing list managers, batch drawing tools, and AutoCAD
automation plugins. Generates the labelled data used to train domain
models.

**Local AI infrastructure** — Foundry brokers local inference via Ollama
and hosts Qdrant-backed RAG stacks. Evaluates code changes and drawing
markups, routes jobs to local LLMs with deterministic checks before
calling any model.

Org configuration, shared agent instructions, skill files, and all
automation live in the
[`.github`](https://github.com/chamber-19/.github) repo.

## Tools

<!-- family-table:start -->
| Repo | Role |
| --- | --- |
| [`desktop-toolkit`](https://github.com/chamber-19/desktop-toolkit) | Shared framework for Tauri desktop apps — splash, updater, NSIS installer, Python sidecar plumbing |
| [`launcher`](https://github.com/chamber-19/launcher) | Desktop launcher and updater — installs, updates, and launches Chamber 19 tools |
| [`transmittal-builder`](https://github.com/chamber-19/transmittal-builder) | Backend service for engineering transmittal generation (invoked by launcher) |
| [`Drawing-List-Manager`](https://github.com/chamber-19/Drawing-List-Manager) | Backend service for project drawing registers (invoked by launcher) |
| [`batch-fnr`](https://github.com/chamber-19/batch-fnr) | Backend service for batch DXF find-and-replace workflows |
| [`block-library`](https://github.com/chamber-19/block-library) | Tauri 2 desktop DXF viewer with Google Drive catalog sync and SQLite local cache |
| [`Foundry`](https://github.com/chamber-19/Foundry) | Local agent broker — routes GitHub and Discord jobs to local LLMs via Ollama |
| [`autocad-knowledge`](https://github.com/chamber-19/autocad-knowledge) | Reference patterns and knowledge base for AutoCAD .NET plugins |
| [`chamber-19-autocad-mcp`](https://github.com/chamber-19/chamber-19-autocad-mcp) | AutoCAD .NET plugin exposing an MCP server inside acad.exe — read-only inspection tools for LLM agents |
| [`IFA-IFC-Checklist`](https://github.com/chamber-19/IFA-IFC-Checklist) | Macro-enabled Excel workbook for IFA and IFC pre-submittal checklists |
| [`Glyphic`](https://github.com/chamber-19/Glyphic) | TODO: curate role for Glyphic |
| [`.github`](https://github.com/chamber-19/.github) | Org-wide configuration hub: shared instructions, skills, workflows, and maintenance scripts |
| [`chamber-19-assets`](https://github.com/chamber-19/chamber-19-assets) | TODO: curate role for chamber-19-assets |
| [`vanguard`](https://github.com/chamber-19/vanguard) | TODO: curate role for vanguard |
<!-- family-table:end -->

## Architecture (2026)

Desktop tools follow a **shared shell + per-app backend** model:

- **Launcher** — one universal Tauri shell for all tools (desktop
  integration, routing, activation, updates)
- **Backends** — stateless Python FastAPI services, one per tool
  (`transmittal-builder`, `Drawing-List-Manager`, etc.)
- **Activation** — centralised in `desktop-toolkit`; all tools reuse the
  same PIN-based machine-binding logic

New tools are backend services registered in launcher config. No new
Tauri shell needed.

## Design system

| Token | Value |
| --- | --- |
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
