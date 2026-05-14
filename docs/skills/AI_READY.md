---
name: ai-ready
description: 'Make any repo AI-ready — analyzes your codebase and generates AGENTS.md, copilot-instructions.md, CI workflows, issue templates, and more. Mines your PR review patterns and creates files customized to your stack. USE THIS SKILL when the user asks to "make this repo ai-ready", "set up AI config", or "prepare this repo for AI contributions".'
---

# AI Ready

This skill helps the user install the latest [ai-ready](https://github.com/johnpapa/ai-ready) `SKILL.md` by [John Papa](https://github.com/johnpapa) into their personal skills directory.

*Why?*: The full ai-ready skill is ~600 lines of detailed instructions that evolve frequently. This wrapper keeps it discoverable here while the source of truth stays in [johnpapa/ai-ready](https://github.com/johnpapa/ai-ready) — always up to date.

## Chamber 19 extension: new app AI-agent intake

When the user proposes a new app idea that will use local AI agents, run this intake before generating scaffolding.

1. Ask for `app_id`.
2. Ask for a single-sentence primary agent purpose.
3. Ask for initial capabilities (3-7 bullets).
4. Ask for data boundaries (in-scope and out-of-scope data).
5. Ask for starter mascot template selection.

Then generate the same starter wiring every time:

1. `agent-manifest.json` with `app_id`, purpose, capabilities, schema version.
2. Empty per-app datastore placeholders only (no seeded memory rows).
3. `AGENT_PURPOSE.md` with scope, constraints, and fail-open behavior.

Hard rule:

- Agent memory is per-app only. Never share learned memory databases across apps.

Starter mascot template shortlist (v7): Scarlet Jackal, Ash Golem, Forge Bear, Rose Moth, Graphite Owl.

## Steps

1. Tell the user to download the latest `SKILL.md` to their personal skills directory by running one of these commands in their terminal. This will overwrite any existing local copy.

   **bash / zsh**

   ```bash
   mkdir -p ~/.copilot/skills/ai-ready
   curl -fsSL https://raw.githubusercontent.com/johnpapa/ai-ready/main/skills/ai-ready/SKILL.md \
     -o ~/.copilot/skills/ai-ready/SKILL.md
   ```

   **PowerShell**

   ```powershell
   New-Item -ItemType Directory -Force -Path "$HOME/.copilot/skills/ai-ready" | Out-Null
   Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/johnpapa/ai-ready/main/skills/ai-ready/SKILL.md" -OutFile "$HOME/.copilot/skills/ai-ready/SKILL.md"
   ```

   For reproducible behavior, the user can replace `main` in the URL with a specific tag or commit SHA.
2. Suggest the user review the downloaded skill before loading it to confirm it contains expected instructions:

   ```bash
   head -20 ~/.copilot/skills/ai-ready/SKILL.md
   ```

3. After the user confirms they've installed it, tell them to reload skills with `/skills reload` and then say `make this repo ai-ready`.
4. Do **not** run the install command on the user's behalf. The user must run it themselves.
