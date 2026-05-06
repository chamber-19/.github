TAURI 2.0 SKILL
Mental model

Tauri is a toolkit for building desktop applications using a Rust backend and a WebView frontend. In Tauri 2.0, your app consists of two processes:

A Rust core that exposes commands (annotated with #[tauri::command]), handles filesystem access and spawns sidecars. It owns the application state and orchestrates background work.
A web UI that runs inside a native WebView (Chromium on Windows/Linux, WebKit on macOS). It uses JavaScript/TypeScript to render the interface and talk to the Rust core over an IPC bridge.

Communication between the frontend and backend is asynchronous. The frontend calls Rust commands via the @tauri-apps/api package, and the backend emits events to the frontend using emit_all or emit. Tauri does not allow blocking the event loop—long‑running work must stream progress via events or run in a sidecar.

Non‑negotiable patterns
Define a single isTauri constant: const isTauri = typeof window !== "undefined" && "TAURI_INTERNALS" in window;. Use this guard before calling any Tauri APIs to avoid errors in browser contexts.
Annotate each command with #[tauri::command] and return Result<T, String>. Do not unwrap results in command handlers; propagate errors to the frontend so it can display them.
Stream progress using emit_all (for global events) or emit (for a specific window). For example:
#[tauri::command]
async fn download(app: tauri::AppHandle) -> Result<(), String> {
    app.emit_all("download-started", ());
    // ... perform work and periodically emit progress
    for pct in 0..=100 {
        app.emit_all("download-progress", pct)?;
    }
    app.emit_all("download-finished", ());
    Ok(())
}
Handle sidecar communication via newline‑delimited JSON. Spawn Python sidecars using Tauri’s Command API and read/write JSON objects line by line.
Commit Cargo.lock and keep your Rust, Node and Python dependency versions pinned. Use desktop‑toolkit as the root of the dependency tree; bump versions in a dedicated PR.
Common libraries and APIs
Use case	Library/Crate	Notes
IPC from frontend	@tauri-apps/api/tauri	invoke("command", { args }), listen("event", callback)
JSON serialization	serde / serde_json	derive Serialize/Deserialize on structs sent over IPC
Async tasks	tokio	Spawn tasks with tokio::spawn for long‑running work
Sidecar processes	tauri::api::process::Command	Spawn Python scripts and pipe stdio
UI notifications	@tauri-apps/api/notification	Show system notifications or dialogues
Failure modes
Symptom	Likely cause	Fix
Frontend never receives progress updates	Using a synchronous loop in a command without emitting events	Break the work into chunks and call emit_all() between iterations
App hangs during sidecar execution	Missing flush=True in Python print statements	Ensure all sidecar print calls include flush=True
Error “unknown IPC channel”	Calling invoke() without defining isTauri guard	Define and use the isTauri constant before invoking commands
Deadlock when reading a file from the plugin	Opening the same file twice in different modes	Use Rust’s ownership correctly and avoid holding multiple locks on the same file
Quick reference
Development: npm install followed by npm run tauri dev runs the frontend in hot‑reload mode and compiles the Rust backend.
Build: npm run tauri build produces platform installers (e.g. MSI, DMG). Use the --target flag to cross‑compile.
Rust tools: cargo fmt formats the code; cargo clippy -- -D warnings lints it; cargo tauri dev is an alternative to the npm script if you prefer a pure Rust workflow.
Updating dependencies: Bump versions in Cargo.toml, package.json and python/requirements.txt together in a single pin bump PR.