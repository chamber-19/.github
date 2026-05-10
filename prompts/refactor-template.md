# Desktop-to-Backend Refactor Template

Use this prompt as the basis for refactoring other Tauri desktop apps to backend-only HTTP services.

## For Next Repos (e.g., Drawing-List-Manager)

Copy and adapt this template:

---

**Goal:** Refactor [ServiceName] from desktop-only Tauri app to stateless Python FastAPI backend service, aligned with May 2026 architecture.

**Scope:** 2-4 hours. Affects [this repo] + `.github` + `launcher` + `desktop-toolkit`.

**Reference:** See `transmittal-builder` Phase 1 for complete executed pattern (all files, workflows, docs).

### Key Steps

1. **Extract business logic** from Rust/Tauri code into `backend/app.py` (FastAPI)
2. **Remove frontend build** artifacts (deprecation notices only)
3. **Replace release.yml** with backend-only CI (ubuntu-latest, Python tests, health check)
4. **Update docs**: README, API.md, DEPLOYMENT.md, CHANGELOG.md, copilot-instructions.md
5. **Version bump** and create git tag (triggers CI)
6. **Integration** with launcher (future phase 2)

### Checklist

- [ ] Business logic extracted to `backend/app.py` with endpoints
- [ ] Tests in `backend/tests/test_*.py` pass locally
- [ ] `/api/health` endpoint responds with service version
- [ ] Release workflow is backend-only (no Tauri, NSIS, PyInstaller)
- [ ] CHANGELOG.md has [Unreleased] section with breaking changes
- [ ] `.github/copilot-instructions.md` describes new backend-only shape
- [ ] Frontend has deprecation notices
- [ ] Stale files deleted (Tauri configs, build scripts, etc.)
- [ ] Git tag created and pushed
- [ ] GitHub Release auto-generated with release notes

### Documentation Updates Across Repos

**This Repo:**

- `backend/requirements.txt` — exact version pins
- `backend/app.py` — FastAPI service with all endpoints
- `.github/workflows/release.yml` — replaced (backend-only)
- `README.md` — updated to describe HTTP service
- `docs/API.md` — endpoint reference (NEW)
- `docs/DEPLOYMENT.md` — local/Docker/K8s options (NEW)
- `.github/copilot-instructions.md` — current shape section
- `CHANGELOG.md` — release notes under [Unreleased]
- `frontend/README.md` — deprecation notice (NEW)
- `frontend/src-tauri/README.md` — deprecation notice (NEW)

**`.github` Repo:**

- `.github/.github/copilot-instructions.md` — family table updated if new service
- `.github/docs/skills/MARKDOWN.md` — verify no linting issues

**`launcher` Repo (if new backend)**

- `launcher/.github/copilot-instructions.md` — document new service routing
- `launcher/src/config/apps.json` — register backend service route

**`desktop-toolkit` Repo (if shared code added)**

- `desktop-toolkit/.github/copilot-instructions.md` — document utilities used

### Testing Protocol

```bash
# Local dev
cd backend
python -m pytest tests/ -v
python -m uvicorn app:app --port 8000
# Visit http://localhost:8000/api/docs in browser

# Health check
curl http://localhost:8000/api/health

# CI triggers after tag push (watch GitHub Actions)
```

### Common Pitfalls

- Workflow YAML syntax errors (validate with `python -m yaml.safe_load`)
- Missing `python-multipart` in requirements (needed for form uploads)
- Health check fails because uvicorn isn't backgrounded properly (add sleep)
- Stale Tauri artifacts left behind (delete Cargo.toml, build.rs, target/)
- Missing test suite (CI requires pytest tests to pass)

---

**Done?** Proceed to Phase 2: Backend deployment documentation + launcher integration.
