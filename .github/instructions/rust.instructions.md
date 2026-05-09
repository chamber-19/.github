---
applyTo: "**/*.rs,**/Cargo.toml,**/Cargo.lock"
---

# Rust rules

Rust is the backbone of our Tauri applications and .NET interop. The following guidelines are mandatory:

MUST use explicit error handling. Functions exposed over IPC via #[tauri::command] return Result<T, String>; avoid unwrap() or expect() anywhere in a command body. When reading files or parsing data, map errors to descriptive strings.
MUST run cargo fmt and cargo clippy -- -D warnings before committing. Code should compile cleanly with no warnings.
MUST commit Cargo.lock. Version drift will break reproducibility and is treated as a bug.
MUST prefer immutable bindings (let x = ...) and explicit lifetimes where necessary. Mutable state should be encapsulated.
PREFER using crates from the standard Rust ecosystem over custom implementations. Consult the official Rust crate registry for common tasks (e.g. serde for serialization, tokio for async tasks).
NEVER add unsafe code unless absolutely necessary and justified. If unsafe is required, document the invariants clearly.
NEVER introduce global mutable static variables. Use dependency injection or Tauri state for shared state.

Refer to RUST.md in docs/skills/ for mental models and examples.
