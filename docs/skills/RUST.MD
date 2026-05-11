# Rust Skill

Use this skill when writing Rust code in any Chamber 19 repo — Tauri command handlers, library code, build scripts, or service layers. Apply it before producing or modifying any `.rs` file.

---

## Mental model

Rust is a systems programming language focused on memory safety and zero-cost abstractions. Every value has exactly one owner; when the owner goes out of scope, the value is dropped. Borrowing (`&T` and `&mut T`) allows temporary access without transferring ownership. The compiler enforces these rules statically.

Error handling is explicit: functions return `Result<T, E>` or `Option<T>`. Handle these with pattern matching (`match`), the `?` operator, or combinators (`.map_err()`, `.unwrap_or()`). Panics are reserved for unrecoverable logic errors — not for anything that can reach production.

---

## Non-negotiable patterns

- **Return `Result<T, String>`** from every `#[tauri::command]` function. Convert errors to `String` at the command boundary so the frontend receives a usable error message.
- **No `.unwrap()` or `.expect()`** in library code or command handlers. Use `?` to propagate errors or pattern-match explicitly.
- **Keep functions short and focused**. Break complex logic into private helper functions.
- **Prefer immutability**. Use `let mut` only when mutation is necessary.
- **Document public functions** with `///` doc comments. Run `cargo doc --open` to verify.
- **Run `cargo clippy -- -D warnings`** before committing. Treat clippy warnings as errors.
- **Commit `Cargo.lock`**. It is required for deterministic builds across the org. Never add it to `.gitignore`.
- **No global mutable state**. Use Tauri's managed state (`tauri::State`) or dependency injection.

---

## Common crates

| Category | Crate | Notes |
| --- | --- | --- |
| JSON serialization | `serde`, `serde_json` | Derive `Serialize` and `Deserialize` for all structs sent over IPC |
| HTTP client | `reqwest` | Async HTTP client; use `reqwest::Client` as a managed Tauri state value |
| CLI parsing | `clap` | Declarative argument parser with derive macros |
| Async runtime | `tokio` | Use `tokio::spawn` for concurrent tasks; `spawn_blocking` for CPU-bound work |
| Logging | `tracing`, `tracing-subscriber` | Structured, async-aware logging |
| Property testing | `proptest` | Complement to `#[test]` for edge-case coverage |

---

## Failure modes

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `borrowed value does not live long enough` | Reference lifetime shorter than the value it points to | Extend the owner's lifetime, clone the data, or restructure ownership |
| `cannot move out of borrowed content` | Attempting to move a value out of a `&T` reference | Clone the value or restructure so the owner moves it |
| Runtime panic: `called unwrap() on an Err value` | `.unwrap()` on a `Result` containing an error | Replace `.unwrap()` with `?` or explicit error handling |
| Deadlock or high CPU on the async runtime | Blocking code running directly on the async executor | Move to `tokio::task::spawn_blocking` or a dedicated thread |

---

## Chamber 19 specifics

- `desktop-toolkit` is the root of the Rust dependency tree. When bumping Rust dependencies, co-ordinate with Node and Python pin bumps in a dedicated PR — never mix version bumps with feature work.
- Commands in Tauri or service layers must return `Result<T, String>` and must never panic.
- Stream long-running work to the frontend via `emit_all()` or `emit()`. Frontend polling is not allowed.

---

## Reference documentation

- [The Rust Reference](https://doc.rust-lang.org/stable/) — language specification, syntax, and standard library
- [The Cargo Book](https://doc.rust-lang.org/cargo/index.html) — Cargo is the Rust package manager and build tool; use it for dependencies, workspaces, and builds

Cargo manages `Cargo.toml` (dependency manifest) and `Cargo.lock` (pinned versions). Always commit `Cargo.lock` in application repos.

---

## Quick reference

```bash
# Build and run
cargo run --bin your_app

# Run tests
cargo test

# Format code
cargo fmt

# Lint (treat warnings as errors)
cargo clippy -- -D warnings

# Update dependencies
cargo update

# Generate and open documentation
cargo doc --open

# Check with locked Cargo.lock (required before PR)
cargo check --locked
```
