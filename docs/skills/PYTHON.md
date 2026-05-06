PYTHON SKILL
Mental model

Python is a dynamically typed language suited for scripting, rapid development and glue code. In Chamber 19 it is primarily used for FastAPI sidecars that expose REST endpoints to Tauri apps and for light automation via COM. Python code runs in its own process, communicating with the Rust frontend over stdin/stdout using newline‑delimited JSON.

The interpreter executes code line by line and relies on an event loop (asyncio) for concurrency. For CPU‑bound tasks use threads or processes; for IO‑bound tasks use async/await.

Non‑negotiable patterns
Print all output with flush=True to ensure that Tauri receives each line immediately.
Use json.loads and json.dumps for message parsing. Each message must be a complete JSON object terminated by a newline.
Use pathlib.Path instead of os.path for filesystem operations. It provides an object‑oriented API and better cross‑platform handling.
Annotate all functions with type hints and run mypy or pyright to catch type errors.
Catch specific exceptions rather than using a bare except:. Always log or return a descriptive error.
Avoid global variables. Use dependency injection or pass state through function arguments.
Manage dependencies in a requirements.txt or pyproject.toml. Keep versions pinned and update them in coordination with Rust and Node packages.
Common libraries
Purpose	Library	Notes
Web API	fastapi	Declare routes with decorators; uses pydantic for data validation
Serving HTTP	uvicorn	ASGI server used in development and production
Data models	pydantic	Creates data classes with validation and type hints
AutoCAD COM	pythonnet	Provides .NET interop in Python sidecars for attribute reads
File manipulation	pandas, openpyxl	Reading/writing Excel files and DataFrames
Async tasks	asyncio, concurrent.futures	Use await for IO and thread pools for CPU tasks
Failure modes
Symptom	Likely cause	Fix
Tauri app hangs waiting for response	Sidecar printing buffered output without flush=True	Add flush=True to all print calls
JSON decode error in Rust	Sidecar wrote multiple JSON objects on a single line or wrote non‑JSON logs	Ensure each print writes exactly one JSON object followed by \n and no other output
FileNotFoundError when reading user files	Using relative paths incorrectly	Resolve paths via Path(root) / filename or prompt user for absolute paths
COMException when reading AutoCAD attributes	Attempting heavy operations through COM	Limit COM usage to lightweight attribute reads and perform batch processing in .NET
Quick reference commands
Create a virtual environment: python -m venv .venv and activate it via source .venv/bin/activate (Linux/macOS) or .venv\Scripts\Activate.ps1 (Windows).
Install dependencies: pip install -r requirements.txt.
Run a FastAPI app: uvicorn main:app --reload --port 8000.
Format code: ruff format . (if using ruff) or black ..
Type checking: pyright or mypy.
Chamber 19 specifics
Sidecars exchange newline‑delimited JSON exclusively. Do not output logs or progress indicators to stdout; use structured messages instead.
Use pythonnet sparingly and only for reading attributes from AutoCAD objects. Do not write to drawings from Python; that belongs in the .NET plugin.
Use the IFA‑IFC‑Checklist workbook via COM only for controlled automation; do not attempt to run macros externally.
Always co‑ordinate Python dependency bumps with Rust and JavaScript version bumps through the desktop‑toolkit.