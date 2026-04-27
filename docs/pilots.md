# Copilot pilot success criteria

Written **before** the pilots start so future-us can't fudge the evaluation.

Review date: **3 months from pilot start** (set a calendar reminder).

---

## Pilot 1: Copilot code review on `desktop-toolkit`

**Scope:** Enable Copilot code review on `chamber-19/desktop-toolkit` only. Two-week trial.

**Success criteria (must meet BOTH to expand):**
- Caught **≥1 real issue** during the trial that a human reviewer would plausibly have missed.
- Generated **<3 false-positive comments per PR on average** across the trial period.

**Decision tree:**
- **Pass:** Expand to `transmittal-builder` next. Re-evaluate after another 2 weeks.
- **Fail:** Disable. Do not retry for 6 months.

---

## Pilot 2: Path-specific instructions in `desktop-toolkit`

**Scope:** Add ONE file: `.github/instructions/powershell-release.instructions.md` with `applyTo: "scripts/**/*.ps1"`. Two-week trial.

**Success criteria (must meet at least ONE to keep):**
- At least one PR where Copilot demonstrably followed a PowerShell-specific rule (approved verbs, structured output, etc.) it would have otherwise violated.
- Reviewer notices Copilot's PowerShell suggestions are visibly more idiomatic vs. baseline.

**Decision tree:**
- **Pass:** Add `rust-core.instructions.md` next. Continue evaluating.
- **Fail:** Delete the file. Stay with the monolithic `copilot-instructions.md`.

---

## Pilot 3 (deferred): Copilot Spaces

Do NOT pre-build. Build the first Space (Desktop Toolkit Consumers) only when you reach for it during a real chat session.

**Trigger:** You ask a cross-repo question in Copilot Chat that would obviously be answered better with a curated Space.

---

## Pilot 4 (deferred): Custom agents

Do NOT build. Reconsider only if you notice yourself typing the same multi-paragraph framing into the cloud agent ≥3 times in a month.

---

## Evaluation log

| Date | Pilot | Result | Decision |
|------|-------|--------|----------|
|      |       |        |          |
