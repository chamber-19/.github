---
applyTo: "**/templates/**,**/*.docx,**/docx*"
---

# DOCX — Chamber 19 rules

Read `docs/skills/DOCX.md` in this repo before writing any Word template or render code.

- **MUST** use `python-docx` for all template manipulation in the transmittal-builder Python sidecar.
- **MUST** call `render_docx.py` and visually inspect page PNGs before shipping any DOCX change. Do not trust text extraction — only rendered PNGs confirm layout correctness.
- **MUST** call `print(..., flush=True)` for all sidecar output — same rule as all Python sidecars.
- **NEVER** call COM/Word automation from the Tauri process — all DOCX work lives in the Python sidecar.
- **NEVER** hardcode content strings into the `.docx` template file — treat it as a layout artifact only.
