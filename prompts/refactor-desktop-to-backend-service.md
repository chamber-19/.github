# Prompt: Refactor Tauri Desktop App to Backend-Only HTTP Service

**Purpose:** Template for refactoring a Chamber 19 Tauri desktop application into a stateless backend-only HTTP service aligned with the May 2026 architecture.

**Example Predecessor:** See `transmittal-builder` Phase 1 execution for the complete reference implementation.

---

## Executive Summary

This is a **breaking architectural change** that moves a desktop tool from:

- **Before:** React UI + Tauri shell (desktop-only, packaged as Windows installer)
- **After:** Python FastAPI backend service (stateless HTTP, deployable anywhere, routes through `launcher` desktop shell)

**Scope:** One repository, affects four (this repo + `.github` + `launcher` + `desktop-toolkit`).

**Effort:** ~2-4 hours for a typical backend extraction + testing + documentation.

---

## Pre-Refactor Checklist

Before starting, confirm:

- [ ] The app's business logic can be cleanly separated from Tauri/React UI
- [ ] All UI state machines can be modeled as stateless HTTP request/response pairs
- [ ] The app produces **stateless artifacts** (files, emails, PDFs, etc.) — not persistent user sessions
- [ ] No hardcoded file paths; all I/O respects working directory or temp folders
- [ ] No Tauri-specific features required (deep linking, protocol handlers, system tray, file associations)
- [ ] Product team agrees this is a breaking change (version bump, CHANGELOG, release notes required)

---

## Part 1: Backend Extraction (2-3 hours)

### 1.1 Create `backend/` directory with Python FastAPI service

**File structure:**
```
backend/
├── app.py                         # FastAPI application definition
├── requirements.txt               # Pip dependencies (use exact pins)
├── requirements-build.txt         # Build-time deps (for PyInstaller if needed)
├── core/
│   ├── __init__.py
│   ├── business_logic.py          # Extracted Rust/Tauri logic
│   ├── utils.py                   # Helpers
│   └── models.py                  # Pydantic request/response models
├── tests/
│   ├── __init__.py
│   ├── test_endpoints.py          # Pytest unit tests for each endpoint
│   └── conftest.py                # Pytest fixtures
├── README_SIDECAR.md              # Local testing instructions
└── Dockerfile                     # Optional: containerization
```

### 1.2 Extract business logic from Tauri commands

For each Tauri command in `frontend/src-tauri/src/`:

1. **Identify the handler function** — strip `#[tauri::command]` decorator
2. **Convert to FastAPI endpoint:**
   ```python
   from fastapi import FastAPI, UploadFile, File
   from pydantic import BaseModel
   
   app = FastAPI(title="MyService", version="1.0.0")
   
   class RequestPayload(BaseModel):
       param1: str
       param2: int
   
   @app.post("/api/process")
   async def process(payload: RequestPayload):
       # Original Tauri logic here
       result = do_work(payload.param1, payload.param2)
       return {"status": "success", "data": result}
   ```

3. **Replace Tauri FFI types:**
   - `String` → `str`
   - `Vec<T>` → `List[T]` (Pydantic `BaseModel` for structured data)
   - `Result<T, String>` → `dict` with `"error"` key (HTTP 400/500 for errors)
   - File I/O → `UploadFile` for input, disk write for output (return path or file download)

4. **Handle file uploads/downloads:**
   ```python
   from fastapi import UploadFile, File
   from fastapi.responses import FileResponse
   
   @app.post("/api/upload-and-process")
   async def upload_and_process(file: UploadFile = File(...)):
       temp_path = f"/tmp/{file.filename}"
       with open(temp_path, "wb") as f:
           f.write(await file.read())
       result = process_file(temp_path)
       return {"output_file": "/path/to/result.pdf"}
   
   @app.get("/api/download/{filename}")
   async def download(filename: str):
       return FileResponse(f"/tmp/{filename}")
   ```

5. **Statelessness is non-negotiable:**
   - ❌ Do NOT store user session data in memory
   - ❌ Do NOT assume request order or persistence
   - ✅ Treat every request as independent
   - ✅ Use temp files or return data in response

### 1.3 Set up dependencies

**`backend/requirements.txt` template:**
```
fastapi==0.136.1
uvicorn[standard]==0.46.0
pydantic==2.10.5
python-multipart==0.0.9
# Add domain-specific packages:
# python-docx==1.2.0          (if generating Word docs)
# docx2pdf==0.1.8             (if converting to PDF)
# pandas==3.0.2               (if parsing Excel)
# openpyxl==3.1.5             (Excel support)
# pypdf>=6.10.2,<7            (if merging PDFs)
# chamber-19-desktop-toolkit  (if using shared framework)
```

**Lock versions explicitly.** No floating pins like `fastapi>=0.100`. Use `pip freeze` or `pip-audit` to validate.

### 1.4 Add health check endpoint

Every backend service MUST have `/api/health`:

```python
@app.get("/api/health")
def health():
    return {
        "status": "healthy",
        "service": "my-service-backend",
        "version": "1.0.0"
    }
```

This endpoint is called by CI/CD for smoke testing and by `launcher` for service discovery.

### 1.5 Add pytest tests

Minimal test suite:

**`backend/tests/test_endpoints.py`:**
```python
import pytest
from fastapi.testclient import TestClient
from app import app

client = TestClient(app)

def test_health():
    response = client.get("/api/health")
    assert response.status_code == 200
    assert response.json()["status"] == "healthy"

def test_process_valid_input():
    response = client.post("/api/process", json={"input": "test"})
    assert response.status_code == 200
    assert "result" in response.json()

def test_process_invalid_input():
    response = client.post("/api/process", json={"input": ""})
    assert response.status_code == 400
```

Run locally: `python -m pytest backend/tests/ -v`

---

## Part 2: Remove Desktop Code (30 minutes)

### 2.1 Delete frontend build artifacts

```bash
# ❌ DELETE these directories entirely:
rm -rf frontend/node_modules/
rm -rf frontend/src-tauri/target/
rm -rf frontend/src-tauri/.cargo/

# Keep these files for reference only (will deprecate):
# frontend/package.json        → shows old npm deps, read-only
# frontend/src-tauri/          → shows old Tauri config, read-only
```

### 2.2 Create deprecation notice files

**`frontend/README.md` (NEW):**
```markdown
# Frontend — DEPRECATED

This directory contains the legacy Tauri + React desktop shell code.
**This code is not built or deployed.**

As of v1.0.0 (May 2026), this tool is now a stateless backend service.
The desktop shell was consolidated into chamber-19/launcher.

See ../backend/ for the active service code.
```

**`frontend/src-tauri/README.md` (NEW):**
```markdown
# Tauri Shell — DEPRECATED

This directory contains the legacy Tauri configuration.
**This code is not built or deployed.**

See ../backend/ for the active service code.
```

### 2.3 Delete stale build/packaging files

```bash
# ❌ DELETE:
rm -f build.rs              # Tauri build script
rm -f transmittal_backend.spec  # Old PyInstaller config (if exists)
rm -f remove-autocad-complete.ps1  # Old migration scripts
rm -f scripts/sync-installer-assets-local.mjs

# Keep:
# requirements.txt → moved to backend/
# Cargo.toml → deprecation reference only
```

---

## Part 3: Update Release Workflow (30 minutes)

### 3.1 Replace `.github/workflows/release.yml`

**Replace the entire file with backend-only CI:**

```yaml
name: Release Backend Service

on:
  push:
    tags:
      - "v*"

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python 3.13
        uses: actions/setup-python@v5
        with:
          python-version: "3.13"
          cache: pip

      - name: Install dependencies
        run: |
          cd backend
          pip install -r requirements.txt
          pip install -r requirements-build.txt

      - name: Run tests
        run: |
          cd backend
          python -m pytest tests/ -v

      - name: Start service and health check
        run: |
          cd backend
          timeout 10 python -m uvicorn app:app --port 8000 &
          sleep 2
          curl -f http://localhost:8000/api/health || exit 1

      - name: Create GitHub Release
        uses: actions/create-release@v1
        env:
          GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          tag_name: ${{ github.ref }}
          release_name: Release ${{ github.ref }}
          body: |
            See [CHANGELOG.md](../CHANGELOG.md) for release notes.
            
            **Backend-only service**
            Desktop packaging and installer releases are owned by [chamber-19/launcher](https://github.com/chamber-19/launcher).
          draft: false
          prerelease: false
```

**Key changes:**
- Runner: `ubuntu-latest` (not `windows-latest`)
- No NSIS installer, no Tauri build, no PyInstaller sidecar
- Python tests + health check only
- Release notes auto-populated from CHANGELOG.md

### 3.2 Verify workflow syntax

```bash
# Check for YAML errors:
python -m yaml.safe_load .github/workflows/release.yml
# Should output nothing (valid YAML)
```

---

## Part 4: Update Documentation (1 hour)

### 4.1 Update `README.md`

**Keep:**
- Architecture overview (brief)
- Feature list
- API endpoints summary

**Replace:**
```markdown
# Service Name

One-paragraph description of what this service does.

## Quick Start

### Local Development (Conda)

```bash
conda env create -f environment.yml
conda activate service-name
cd backend
python -m uvicorn app:app --port 8000
```

Visit http://localhost:8000/api/docs for interactive API documentation.

### Production Deployment

See `docs/DEPLOYMENT.md` for Kubernetes/Docker/cloud options.

## Architecture

This is a stateless HTTP service written in Python + FastAPI.
No desktop components; all UI logic routes through [chamber-19/launcher](https://github.com/chamber-19/launcher).

**Endpoints:**
- `GET /api/health` — service health
- `POST /api/action` — business logic

See `docs/API.md` for full endpoint reference.
```

### 4.2 Create `docs/API.md`

```markdown
# API Reference

## POST /api/action

**Request:**
```json
{
  "param1": "string",
  "param2": 123
}
```

**Response (200):**
```json
{
  "status": "success",
  "result": { ... }
}
```

**Response (400):**
```json
{
  "status": "error",
  "message": "Invalid input"
}
```

## GET /api/health

Always returns 200:
```json
{
  "status": "healthy",
  "service": "service-name-backend",
  "version": "1.0.0"
}
```
```

### 4.3 Create `docs/DEPLOYMENT.md`

```markdown
# Deployment Options

## Local (Development)

```bash
cd backend && python -m uvicorn app:app --port 8000
```

## Docker

```bash
docker build -t my-service:1.0.0 -f backend/Dockerfile .
docker run -p 8000:8000 my-service:1.0.0
```

## Kubernetes

See chamber-19/desktop-toolkit for shared Helm templates.

## Environment Variables

- `SERVICE_PORT` (default: 8000)
- `LOG_LEVEL` (default: info)
- `TEMP_DIR` (default: /tmp)
```

### 4.4 Update `.github/copilot-instructions.md`

Add or update the "Current Shape" section:

```markdown
## Current Shape

- `backend/` is a Python FastAPI service for [business logic].
- **No frontend**: All UI logic moved to `chamber-19/launcher`.
- **No Tauri**: Desktop shell now lives in `launcher` (shared by all apps).
- Activation logic in `chamber-19/desktop-toolkit`.
- Consumes `desktop-toolkit` Python package only.

## Build and Test

```bash
conda env create -f environment.yml
conda activate service-name

cd backend
python -m pytest
python -m uvicorn app:app --port 8000
```

## Python Environment Policy

- Use Conda as the default local Python environment manager.
- Prefer `environment.yml` over ad-hoc `.venv` setup.
- Backend commands should assume `service-name` environment is active.
```

### 4.5 Update `CHANGELOG.md`

Add release notes under `[Unreleased]` (will move to version section during release):

```markdown
## [Unreleased]

### Changed

- **BREAKING: Architecture refactor (May 2026)**
  - Desktop shell moved to chamber-19/launcher
  - Application is now a stateless HTTP service (Python + FastAPI)
  - No NSIS installer or Tauri build in this repo
  - Release workflow changed to backend-only CI (tests + health check)
  - All HTTP API endpoints unchanged

### Added

- Pytest test suite for backend endpoints
- `/api/health` endpoint for service discovery
- OpenAPI (Swagger) documentation at `/api/docs`
- Dockerfile for containerization

### Removed

- Frontend React UI (moved to launcher)
- Tauri shell code (moved to launcher)
- PyInstaller sidecar build
- Windows installer (NSIS) packaging
```

---

## Part 5: Version Bump & Release (30 minutes)

### 5.1 Bump version number

**In `backend/app.py`:**
```python
app = FastAPI(
    title="Service Name",
    version="1.0.0",  # ← Update this
    description="..."
)

@app.get("/api/health")
def health():
    return {
        "status": "healthy",
        "service": "service-name-backend",
        "version": "1.0.0"  # ← Update this too
    }
```

### 5.2 Commit changes

```bash
git add -A
git commit -m "chore: Bump version to 1.0.0"
```

### 5.3 Create annotated tag

```bash
git tag -a v1.0.0 -m "Release v1.0.0 — Backend-only service with architecture refactor

This is the first release following the May 2026 architecture refactor.

Key changes:
- Desktop shell moved to chamber-19/launcher
- Service now runs as stateless HTTP backend
- No installer packaging in this repo
- All endpoints remain unchanged

See CHANGELOG.md for full details."
```

### 5.4 Push tag (triggers CI)

```bash
git push origin v1.0.0
```

**Monitor:** Check GitHub Actions to verify workflow runs and completes successfully.

---

## Part 6: Integration with Launcher (Future Phase 2)

After backend is released and tested:

1. **Register in launcher config** — Add route in `chamber-19/launcher` app configuration
2. **Test activation + routing** — Verify user activates via PIN → launcher routes to backend
3. **Document API contract** — Ensure launcher knows all endpoint signatures
4. **E2E test** — Activate in launcher, place request, verify response

---

## Part 7: Cross-Repo Documentation Updates

### 7.1 `.github` repo (org-wide source of truth)

**Update `.github/.github/copilot-instructions.md`:**
- [ ] Add repo name to family table if new service
- [ ] Verify hard decisions still apply
- [ ] Add any new architectural patterns

**Update `.github/docs/skills/MARKDOWN.md`:**
- [ ] Ensure markdown standards are current
- [ ] Fix any linting violations in org-wide docs

### 7.2 `launcher` repo (if new backend)

**Update `launcher/.github/copilot-instructions.md`:**
- [ ] Document app routing for new service
- [ ] Specify POST-activation flow

**Update `launcher/src/config/apps.json`:**
- [ ] Add backend service route
- [ ] Specify port/URL for local dev

### 7.3 `desktop-toolkit` repo (if new shared code)

**Update `desktop-toolkit/.github/copilot-instructions.md`:**
- [ ] Document any shared utilities used
- [ ] Verify activation service integration

---

## Validation Checklist

Before marking complete:

- [ ] Backend service runs locally: `python -m uvicorn app:app --port 8000`
- [ ] Health check responds: `curl http://localhost:8000/api/health`
- [ ] All pytest tests pass: `python -m pytest backend/tests/ -v`
- [ ] `/api/docs` (Swagger) is accessible and shows all endpoints
- [ ] CHANGELOG.md reflects breaking changes and new features
- [ ] `.github/copilot-instructions.md` accurately describes new shape
- [ ] `README.md` points to deployment docs
- [ ] Frontend deprecation notices in place
- [ ] No stale build scripts or Tauri artifacts
- [ ] Git history is clean (one commit per logical change)
- [ ] Tag is created and pushed; GitHub Actions workflow triggered
- [ ] GitHub Release created with notes from CHANGELOG.md
- [ ] No secrets in environment; all config is documented

---

## Common Pitfalls

| Issue | Fix |
| --- | --- |
| Health check fails on CI | Ensure uvicorn is backgrounded correctly; add sleep before curl |
| Module not found errors | Verify `backend/requirements.txt` includes all dependencies |
| Multipart form data fails | Add `pip install python-multipart` to requirements |
| CORS errors when testing | Add `CORSMiddleware` to FastAPI app |
| Stale CHANGELOG.md | Move `[Unreleased]` content to new version section at release time |
| Workflow YAML syntax errors | Validate with `python -m yaml.safe_load` before committing |

---

## Reference Implementation

See **`chamber-19/transmittal-builder`** Phase 1 for the complete executed pattern:

- `backend/app.py` — FastAPI service with all endpoints
- `.github/workflows/release.yml` — Backend-only CI
- `CHANGELOG.md` — v1.0.0 release notes with breaking changes
- `.github/copilot-instructions.md` — Repo-specific guidance
- `E2E_CLEANUP_SUMMARY.md` — Documentation of all changes

---

## Summary

This refactor converts a Tauri desktop app into a stateless HTTP backend service aligned with the May 2026 Chamber 19 architecture:

1. **Extract business logic** → Python FastAPI service
2. **Remove desktop code** → Leave deprecation notices
3. **Update CI/CD** → Backend-only release workflow
4. **Document thoroughly** → README, API, deployment, copilot-instructions
5. **Version and release** → Git tag + GitHub Actions + Release notes
6. **Integrate with launcher** → Register backend route (future phase)

**Effort:** 2-4 hours. **Impact:** Breaking change — version bump + CHANGELOG required. **Outcome:** Stateless service deployable anywhere, routes through shared launcher shell.

