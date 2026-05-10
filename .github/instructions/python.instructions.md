---
applyTo: "**/*.py, **/requirements.txt, **/pyproject.toml"
---

# Python sidecar rules

Python sidecars power our back‑end APIs and interact with AutoCAD via COM where necessary. To ensure predictable behaviour, adhere to these rules:

MUST write newline‑delimited JSON to stdout and read from stdin. Each message must be a single JSON object followed by a newline. This contract is consumed by Tauri; any deviation will break IPC.
MUST call print(..., flush=True) for all output. Buffered output can cause Tauri to hang waiting for a newline【n/a†n/a】.
MUST use pathlib.Path for all filesystem paths. The legacy os.path API is forbidden. Converting Path to string should happen only when calling external libraries.
MUST provide type hints on every function signature. This improves readability and enables static analysis.
MUST handle exceptions explicitly. Catch specific exception classes (e.g. except FileNotFoundError) and return descriptive errors. NEVER use a bare except: clause.
PREFER using virtual environments and pinning dependencies in requirements.txt or pyproject.toml. Dependencies must be kept up to date in coordination with desktop‑toolkit pin bumps.
NEVER perform heavy computations on the main thread that interacts with Tauri. Use worker threads or asynchronous APIs for long‑running tasks.

More details, including common libraries and error handling patterns, are available in PYTHON.md under docs/skills/.
