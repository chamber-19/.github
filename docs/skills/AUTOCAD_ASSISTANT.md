# Autodesk Assistant Skill

Use this skill when writing code, documentation, or tooling that involves querying AutoCAD drawings through Autodesk Assistant (the in-product AI chat in AutoCAD 2026/2027). This covers session setup, proven query patterns, operational gotchas, and the architectural boundary between what Assistant can and cannot do.

---

## What Autodesk Assistant is (and isn't)

Assistant is an AI chat panel embedded in AutoCAD 2026/2027. It connects to an in-process MCP (Model Context Protocol) server (`AutoCAD-MCP-Server-2027.bundle`) that exposes a set of tools for querying the active drawing's geometry database. It is **not** a general LLM API — it is a read-mostly geometry query interface with AutoCAD-specific tools.

**What it can do:**

- Count block instances by name
- Sum polyline lengths or closed-polyline areas by layer
- Enumerate text and mtext entities by layer
- Infer spatial relationships (e.g. detect a 3×18 grid arrangement)
- Maintain session context across queries (unit assumptions carry forward)
- Auto-paginate large result sets transparently

**What it cannot do (confirmed limitations):**

- Read block attribute values — MCP schema exposes name/position/rotation/scale/layer only
- Trace wire connectivity in vanilla AutoCAD — plain polylines have no electrical semantics
- Write to the drawing — it is read-only
- Run across multiple open drawings simultaneously — single drawing per session
- Be called programmatically from external tools — the MCP server is in-process and not exposed via a network endpoint accessible to third-party clients

For the confirmed limitations with documented workarounds, see `limitations/` in `autocad-knowledge`.

---

## Session setup — do this before every new session

The single most important step. Copy and paste the priming prompt from `autocad-knowledge/glossary/session-priming-prompt.md` at the start of every new session. Without it:

- Units will be ambiguous (an unprimed session returned 233,847 ft instead of 19,487 ft — a 12× error on a rebar takeoff)
- Domain terms (BESS, IFC, CATL TOP, NANULAK) will not be recognised
- Layer naming patterns will not be applied correctly

**The priming prompt covers:**

- Drawing units (inches by default for R3P substations — always state this explicitly)
- R3P layer conventions (`4-O BARE GROUND - *`, `EQUIP`, `TEXT`, `Foundation`)
- Domain terminology (BESS, IFP/IFC/IFA, MW ratings, TB/TBS/TBR, CATL TOP, GCB, SF6)
- Workflow preferences (report in feet/sq ft/count, group by type/size, flag inconsistencies)

Once primed, session context persists for subsequent queries — you do not need to repeat it every time.

---

## Before querying — ensure AutoCAD is idle

The MCP server is in-process. If AutoCAD is mid-command, mid-dialog, or saving, queries will fail with "AutoCAD is currently busy with another operation."

**Pre-query checklist:**

- No active command (press `ESC` to confirm)
- No open dialogs
- No drawing or save operation in progress
- Bare command line prompt visible

See `autocad-knowledge/gotchas/autocad-busy-state.md` for the full failure pattern and recovery steps.

---

## Proven query patterns

All four patterns below are verified on real R3P drawings (tested 2026-04-25, NANULAK 180 MW BESS substation). Full prompt text and edge cases in `autocad-knowledge/patterns/`.

| Pattern | Example prompt | Use case |
| --- | --- | --- |
| Polyline length by layer | "Sum the total length of all polylines on layer `4-O BARE GROUND - BESS` and report in feet." | Rebar/conduit/cable takeoff |
| Block count by name | "Count all instances of block `CATL TOP`." | BOM verification, layout audit |
| Closed polyline area by layer | "Sum the area of all closed polylines on layer `Foundation`." | Concrete/gravel/fence area takeoff |
| Text enumeration by layer | "Create a table of all text on layer `TEXT`." | Label inventory, annotation audit |

**Tips for reliable results:**

- Give the exact layer name — case may matter, and wildcards are not supported in layer-name prompts
- Ask Assistant to list layers first if you are unsure of exact names: "List all layers in this drawing"
- For large datasets, stage queries: "How many?" first → "Sum them" → "List all" — this manages context and pagination

---

## Handling pagination

Assistant transparently paginates large result sets (cap ~200 items per query). Multiple `queryAutoCADObjects` calls will be visible in the response. This is normal and correct — it just takes longer and consumes more context.

For very large drawings, prefer aggregate queries ("Sum the length of…") over list queries ("List all…") to avoid pagination overhead. See `autocad-knowledge/gotchas/pagination-is-automatic.md`.

---

## Unit handling — always sanity-check magnitude

AutoCAD does not expose definitive unit metadata via MCP. The session priming prompt provides context, but always sanity-check results against engineering reality:

| Drawing type | Typical rebar/cable quantity | Flag if... |
| --- | --- | --- |
| BESS substation (5–20 acres) | 15,000–25,000 ft grounding rebar | Result > 100,000 ft or < 5,000 ft |
| Foundation area | 8,000–15,000 sq ft | Result > 100,000 sq ft |
| Site plan text labels | 10–50 labels | Result > 500 |

If the number looks wrong, tell Assistant the correct unit and ask it to re-convert. The corrected assumption will persist for subsequent queries in the session.

---

## Architecture boundary — where Assistant ends and other tools begin

| Task | Tool |
| --- | --- |
| Read geometry (lengths, areas, positions, counts) | Autodesk Assistant |
| Read/write block attribute values | `batch-fnr` |
| Apply edits to the drawing at scale | `batch-fnr` or a custom .NET plugin |
| Process many drawings without opening AutoCAD UI | Custom .NET headless processor (see `autocad-knowledge/headless-processing.md`) |
| View a drawing in a browser | APS Viewer |
| Run cloud-side batch jobs | APS Design Automation |

The hybrid workflow (Assistant reasoning → batch-fnr execution) is documented as a future investigation in `autocad-knowledge/future-work/hybrid-assistant-plus-batch-fnr.md`.

---

## Programmatic access — what the decompile revealed

**Decompile date:** 2026-05-07, build 26.0.386.3319 (`acmcp.dll`, `acmcpcommon.dll`, `aeccmcp.dll`)

The MCP bundle ships two servers:

| Server | Class | Transport | Status |
| --- | --- | --- | --- |
| In-process | `InProcessMcpServer` | Named pipe (stdin/stdout streams) | Always running when AutoCAD is open |
| HTTP | `HttpMcpServer` | ASP.NET Core + `ModelContextProtocol.AspNetCore` | **Disabled by default** |

### The HTTP server

The HTTP server is real and fully implemented. When enabled:

- Binds to `http://localhost:{PORT}/mcp` — port auto-selected from range **5001–5050**
- Uses the official `ModelContextProtocol` .NET library for the MCP protocol
- CORS is configured to **only** allow `https://cfp-mfe-*.autodesk.com` (Autodesk's cloud AI frontend) — this is a browser security constraint only; native `HttpClient` is not subject to CORS

**Exposed tools (confirmed from decompile):**

- `discoverAutoCADTypes` — enumerate drawing object types and schema
- `queryAutoCADObjects` — read object properties, filter by type/layer/handle
- `checkAutoCADObjects` — validate object states
- `manipulateDrawingCanvas` — zoom, select, unselect, showme operations
- `UpdateObjects` method exists in `acmcpcommon` — write capability present

### Enabling the HTTP server

The HTTP server is controlled by the `ACMCP_TOOLS_CONFIG_FILE` environment variable and a JSON config file:

```json
{
  "toolsConfiguration": {
    "enableHttpServer": true,
    "enableAllToolsByDefault": true,
    "enableExperimentalFeatures": false,
    "enableDebugLogging": false
  }
}
```

Steps:

1. Write the config JSON to a file (e.g. `C:\temp\acmcp-config.json`)
2. Set `ACMCP_TOOLS_CONFIG_FILE=C:\temp\acmcp-config.json` in the environment before launching AutoCAD
3. AutoCAD will start the HTTP server automatically; the command line will print `AutoCAD MCP Server started on http://localhost:PORT/mcp`
4. Connect from a .NET app using `ModelContextProtocol.Client` (same library AutoCAD itself ships)

### Caveats

- Autodesk does not publicly document this endpoint — it exists to support their own cloud AI frontend
- The CORS whitelist is intentional: they intend programmatic access only through their own product
- Write capability (`UpdateObjects`) exists in the library but may require `enableExperimentalFeatures: true` — untested
- Port is dynamic (5001–5050) — poll or read from AutoCAD command line output to discover

See `autocad-knowledge/future-work/programmatic-mcp-access.md` for the full investigation plan.
