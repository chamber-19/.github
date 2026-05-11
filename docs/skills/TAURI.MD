# Tauri 2.0 Skill

Use this skill when writing Tauri commands, IPC handlers, sidecar integrations, events, or packaging configuration in any Chamber 19 desktop app. Apply it before producing or modifying any Tauri-related Rust or frontend code.

---

## Mental model

Tauri is a toolkit for building desktop applications with a Rust backend and a WebView frontend. A Tauri 2.0 app has two processes:

- **Rust core** — exposes commands (annotated `#[tauri::command]`), handles filesystem access, and spawns sidecars. It owns application state and orchestrates background work.
- **WebView frontend** — React/TypeScript running inside a native WebView (WebKit on macOS, WebView2 on Windows). It communicates with the Rust core over an IPC bridge.

Communication is always asynchronous. The frontend calls Rust commands via `invoke()` from `@tauri-apps/api`. The Rust core pushes updates to the frontend via `emit_all()` or `emit()`. Blocking the event loop is not allowed — long-running work must stream progress via events or run in a sidecar.

---

## Non-negotiable patterns

- **Define `isTauri` at module load** and use it before every IPC call:
  
  ```ts
  const isTauri = typeof window !== "undefined" && "__TAURI_INTERNALS__" in window;
  ```

  Never use inline checks or repeated string literals. This guard prevents errors when the frontend runs in a browser context (dev, test, Storybook).

- **Return `Result<T, String>`** from every `#[tauri::command]`. Never `.unwrap()` inside a command handler — propagate errors to the frontend so it can display them.

- **Stream long-running work via events**. Never make the frontend poll:
  
  ```rust
  #[tauri::command]
  async fn process(app: tauri::AppHandle) -> Result<(), String> {
      app.emit_all("process-started", ()).map_err(|e| e.to_string())?;
      for step in 0..=100 {
          // do work
          app.emit_all("process-progress", step).map_err(|e| e.to_string())?;
      }
      app.emit_all("process-finished", ()).map_err(|e| e.to_string())?;
      Ok(())
  }
  ```

- **Communicate with sidecars via newline-delimited JSON**. Spawn Python sidecars using Tauri's `Command` API and read/write one JSON object per line.

- **Commit `Cargo.lock`** and run `cargo check --locked` before every PR. Dependency drift is a build failure.

- **Bump desktop-toolkit pins together**. When updating `desktop-toolkit`, update `Cargo.toml`, `package.json`, and `requirements.txt` in a single dedicated PR. Never mix pin bumps with feature work.

---

## Common libraries and APIs

| Use case | Library / Crate | Notes |
| --- | --- | --- |
| IPC from frontend | `@tauri-apps/api` | `invoke("command_name", { args })`, `listen("event", callback)` |
| JSON serialization | `serde`, `serde_json` | Derive `Serialize`/`Deserialize` on all structs sent over IPC |
| Async tasks | `tokio` | `tokio::spawn` for concurrent work; `spawn_blocking` for CPU tasks |
| Sidecar processes | `tauri::api::process::Command` | Spawn Python scripts and pipe stdio |
| Managed state | `tauri::State<T>` | Share state between commands without global mutables |
| System notifications | `@tauri-apps/api/notification` | Show OS-level notifications or dialogs |

---

## Failure modes

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Frontend never receives progress updates | Synchronous loop in command without emitting events | Break work into chunks and call `emit_all()` between iterations |
| App hangs during sidecar execution | Python sidecar missing `flush=True` on `print()` | Add `flush=True` to all sidecar print calls |
| `unknown IPC channel` error | Calling `invoke()` without the `isTauri` guard or before the WebView is ready | Define and use the `isTauri` constant; wait for `onMounted` or document ready |
| Deadlock reading a file | Same file opened twice in different modes | Use Rust ownership correctly; never hold multiple locks on the same path |
| Stale UI after backend state change | Frontend polled and missed an update | Convert to event-based updates using `emit_all()` and `listen()` |

---

## Chamber 19 specifics

- All Chamber 19 Tauri apps share a common architecture: React frontend, Rust Tauri shell, Python FastAPI sidecar. See `CLAUDE.md` at the repo root for the full layout.
- `desktop-toolkit` provides shared Tauri primitives, the activation service, and sidecar boilerplate. Do not duplicate these in consumer repos.
- Activation logic (`toolkit_check_activation`, `toolkit_activate_with_pin`, `toolkit_deactivate`) lives in `desktop-toolkit`. Never re-implement it in a consumer app.
- The `launcher` is the single desktop shell for all Chamber 19 tools. Consumer apps do not ship their own installers.

---

## Reference documentation

- [Tauri v2 documentation](https://v2.tauri.app/start/) — official guide covering commands, events, plugins, permissions, and packaging for Tauri 2.0

---

## Quick reference

```bash
# Install frontend dependencies
npm ci

# Start frontend + Rust in dev mode (hot reload)
npm run desktop

# Build production desktop app
npm run desktop:build

# Type-check Rust (from frontend/src-tauri/)
cargo check --locked

# Format Rust
cargo fmt

# Lint Rust
cargo clippy -- -D warnings
```
