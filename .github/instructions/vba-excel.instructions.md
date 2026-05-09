---
applyTo: "**/*.bas,**/*.cls,**/*.frm,**/*.xlsm,**/*.xls"
---

# VBA/Excel automation rules

The IFA‑IFC‑Checklist workbook uses VBA macros to validate engineering submittals. The following rules ensure safe automation:

MUST implement a stage submit validation sequence. Before submitting 30 %, 60 %, 90 % IFA or IFC stages, the macro must validate that all required checklist items are completed, prompt the user to confirm, create a timestamped backup copy of the workbook, and only then mark the stage as submitted. Never skip the backup.
MUST use structured error handling. Wrap risky operations in On Error GoTo blocks with named labels. At the start of each procedure, set On Error GoTo ErrorHandler and implement a corresponding ErrorHandler: label that logs the error, restores application state and resets Application.EnableEvents before exiting.
MUST clean up ribbon buttons and dynamically generated controls when unloading or rebuilding the UI. Failure to remove old buttons leads to duplicate controls in subsequent sessions.
MUST avoid mutating production files directly. Macros should operate on a working copy saved alongside the original. For example, before exporting PDFs or bulk updating statuses, save the workbook as *_workcopy.xlsm and perform operations on that copy.
NEVER use On Error Resume Next. Silent failures hide bugs and can lead to inaccurate submittal packages.
NEVER reference hidden sheets or range names without checking their existence. Hidden or missing ranges should trigger a clear error message to the user.

Further guidance on VBA patterns and integration with engineering workflows can be found in VBA_EXCEL.md under docs/skills/.
