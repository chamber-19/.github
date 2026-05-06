applyTo:

"**/*.rs"
"/src-tauri/"
"**/tauri.conf.json"
"/capabilities/"
Tauri rules (Rust + IPC layer)

The following patterns are mandatory for all Rust code and configuration files used in a Tauri application:

MUST declare a single const isTauri = typeof window !== "undefined" && "TAURI_INTERNALS" in window in each JavaScript/TypeScript module that makes IPC calls. Inline checks or repeated string literals are not allowed; this prevents subtle bugs when executing outside of Tauri.
MUST return Result<T, String> from every #[tauri::command] function. Commands should perform their own error handling and propagate errors back to the frontend as strings. Using .unwrap() or calling .expect() inside a command handler is forbidden.
MUST stream long‑running work to the frontend via global events. Use emit_all() or emit() to send progress updates rather than requiring the frontend to poll. Polling is explicitly NEVER allowed because it blocks the Tauri event loop and caused hangs in previous versions.
MUST commit Cargo.lock and keep it in sync with Cargo.toml. Do not update Rust dependencies outside of a dedicated version bump PR.
MUST keep tauri.conf.json configuration minimal and environment‑agnostic. Secrets should be injected via environment variables or tauri.conf.json.$env overrides.
NEVER invoke blocking or long‑running code on the Tauri main thread. Offload heavy tasks to Rust worker threads or Python sidecars.

Use the RUST.md and TAURI.md skill files in docs/skills/ to understand the mental model of the runtime and available APIs.