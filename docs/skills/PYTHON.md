# Python Skill

Use this skill when writing Python code in any Chamber 19 repo — FastAPI sidecars, COM automation, data processing, or test code. Apply it before producing or modifying any `.py` file.

---

## Mental model

Python is a dynamically typed language used in Chamber 19 primarily for FastAPI sidecars that expose REST endpoints to Tauri apps and for light automation via COM. Each sidecar runs in its own process, communicating with the Rust frontend over stdin/stdout using newline-delimited JSON.

The interpreter executes code line by line and relies on an event loop (`asyncio`) for concurrency. For CPU-bound tasks use threads or processes; for IO-bound tasks use `async/await`.

---

## Non-negotiable patterns

- **Print with `flush=True`** on every `print()` call. Tauri reads the sidecar's stdout line by line — buffered output causes deadlocks.
- **Exchange newline-delimited JSON** on stdin/stdout. Each message is one complete JSON object terminated by `\n`. No other output on stdout.
- **Use `pathlib.Path`** for all filesystem operations. Never use `os.path`.
- **Annotate every function** with type hints. Run `pyright` or `mypy` to catch type errors before committing.
- **Catch specific exceptions**. Never use a bare `except:`. Always name the exception type and log or return a descriptive error.
- **Avoid global variables**. Pass state through function arguments or dependency injection.
- **Pin all dependencies** in `requirements.txt` or `pyproject.toml`. Co-ordinate Python version bumps with Rust and Node pin bumps via `desktop-toolkit`.

---

## Common libraries

| Purpose | Library | Notes |
| --- | --- | --- |
| Web API | `fastapi` | Declare routes with decorators; uses Pydantic for data validation |
| HTTP server | `uvicorn` | ASGI server for development and production |
| Data models | `pydantic` | Type-validated data classes with serialization |
| AutoCAD COM | `pythonnet` | .NET interop for attribute reads from Python sidecars |
| File manipulation | `pandas`, `openpyxl` | Reading and writing Excel files and DataFrames |
| Async tasks | `asyncio`, `concurrent.futures` | `await` for IO; thread pools for CPU tasks |

---

## Failure modes

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Tauri app hangs waiting for response | Sidecar printing buffered output without `flush=True` | Add `flush=True` to every `print()` call |
| JSON decode error in Rust | Sidecar wrote multiple objects on one line, or wrote non-JSON logs to stdout | Each `print()` writes exactly one JSON object followed by `\n`; send logs to stderr |
| `FileNotFoundError` on user files | Relative path resolved against wrong working directory | Use `pathlib.Path(root) / filename` or require absolute paths from the frontend |
| `COMException` when reading AutoCAD attributes | Heavy operations attempted through COM | Limit COM to lightweight attribute reads; batch processing belongs in the .NET plugin |

---

## Chamber 19 specifics

- Sidecars exchange newline-delimited JSON exclusively. Do not write logs, progress indicators, or debug output to stdout — use structured JSON messages or write to stderr instead.
- Use `pythonnet` sparingly and only for reading attributes from AutoCAD objects. Never write to drawings from Python; that belongs in the `.NET` plugin.
- Always co-ordinate Python dependency bumps with Rust and JavaScript version bumps through `desktop-toolkit`.

---

## Reference documentation

- [Python documentation](https://www.python.org/doc/) — language reference, standard library, and tutorials

---

## Quick reference

```bash
# Create and activate a virtual environment
python -m venv .venv
.venv\Scripts\Activate.ps1          # Windows
source .venv/bin/activate           # macOS/Linux

# Install dependencies
pip install -r requirements.txt

# Run a FastAPI sidecar in development
uvicorn app:app --reload --port 8000

# Type checking
pyright
# or
mypy .

# Format code
ruff format .
```
