RUST SKILL
Mental model

Rust is a systems programming language focused on memory safety and zero‑cost abstractions. It uses ownership to guarantee that every value has exactly one owner at a time. When the owner goes out of scope, the value is dropped. Borrowing (&T and &mut T) allows temporary access without transferring ownership. The compiler enforces these rules statically, eliminating many classes of bugs.

Error handling in Rust is explicit: functions return Result<T, E> or Option<T>. You must handle these possibilities using pattern matching (match) or combinators (?, .map_err(), .unwrap_or() etc.). Panics should be reserved for unrecoverable logic errors.

Non‑negotiable patterns
Use Result and propagate errors up the call stack. At the top layer (Tauri commands), convert errors into String to send back to the frontend.
Avoid .unwrap() and .expect() in library code. Use pattern matching or the ? operator to propagate errors.
Keep functions short and focused. Break complex logic into private helper functions.
Prefer immutability. Use let mut only when necessary.
Document public functions with /// doc comments. Rustdoc makes it easy to generate documentation.
Use clippy to catch common pitfalls and enforce style.
Common crates
Category	Crate	Notes
JSON serialization	serde, serde_json	Derive Serialize and Deserialize for your structs
HTTP requests	reqwest	Async HTTP client built on hyper
CLI parsing	clap	Declarative command‑line argument parser
Async runtime	tokio	Use tokio::spawn to run tasks concurrently
Logging	tracing, tracing-subscriber	Structured, async‑aware logging
Testing	proptest	Property‑based testing; complement to #[test]
Failure modes
Symptom	Likely cause	Fix
“borrowed value does not live long enough” compile error	A reference’s lifetime is shorter than the value it points to	Rework the function to extend lifetimes or clone the data before returning
“cannot move out of borrowed content” compile error	Attempting to move a value out of a borrowed context	Clone the value or restructure code so the owner moves it
Runtime panic with called unwrap on an Err value	Unwrapping a Result that contains an error	Replace unwrap() with proper error propagation using ?
Deadlock or high CPU usage	Blocking code running on the async runtime	Offload blocking work to tokio::task::spawn_blocking or a separate thread
Quick reference commands
Build and run: cargo run --bin your_app
Run tests: cargo test
Format code: cargo fmt
Lint with clippy: cargo clippy -- -D warnings
Update dependencies: cargo update
Generate docs: cargo doc --open
Chamber 19 specifics
desktop‑toolkit is the root of the dependency tree. When bumping Rust dependencies, coordinate with Node and Python pin bumps.
Always include Cargo.lock in your commits; it is required for deterministic builds across the organisation.
Commands in Tauri or service layers must return Result<T, String> and must not panic.
Avoid global mutable state; use Tauri’s managed state or dependency injection.