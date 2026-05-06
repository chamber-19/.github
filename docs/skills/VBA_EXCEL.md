VBA/EXCEL SKILL
Mental model

VBA (Visual Basic for Applications) scripts run inside the context of Microsoft Excel. Code is organised into modules (standard, class or form), and macros are executed by user interactions such as button clicks or workbook events. Excel exposes an object model where Workbooks contain Worksheets, which contain Ranges (cells). Macros can manipulate these objects to automate repetitive tasks.

In Chamber 19, the IFA‑IFC‑Checklist workbook implements stage‑based checklists for engineering submittals. Macros validate the completion of checklist items, manage stage transitions (30 %, 60 %, 90 % IFA and IFC), export the workbook to PDF, and update status fields. Because these macros modify documents used in production, safety and backup discipline are paramount.

Non‑negotiable patterns
Implement a stage submit validation sequence for each stage (30 %, 60 %, 90 %, IFC). Before marking a stage as submitted, confirm that all required checklist rows have Status = "Complete", prompt the user, save a timestamped backup copy, and then write the submission metadata (date, initials) into the workbook.
Use structured error handling: at the top of each procedure, add On Error GoTo ErrorHandler, and implement an ErrorHandler: section at the end of the procedure. In the error handler, log the error (e.g. write to a hidden sheet), reset Application.EnableEvents = True, display a message to the user and exit gracefully.
When dynamically creating ribbon buttons or form controls, always remove or hide them when they are no longer needed. Rebuilding the UI without cleanup leads to duplicate controls.
Save a working copy before performing bulk operations such as PDF export or bulk status updates. Do not operate directly on the master workbook—always duplicate it with a _workcopy suffix and run the macro on that copy.
Never use On Error Resume Next to suppress errors. Always handle specific errors or fail loudly so that mistakes are caught early.
Use Option Explicit at the top of every module to force explicit variable declarations.
Common objects and functions
Purpose	Object/Function	Notes
Workbook events	Workbook_Open, Workbook_BeforeClose	Initialise ribbon and perform cleanup when opening/closing
Range manipulation	Range, Cells, Offset	Read/write cell values and iterate over rows
Dialogs	Application.FileDialog, MsgBox, InputBox	Prompt users for files and confirmations
PDF export	Worksheet.ExportAsFixedFormat	Save a worksheet or workbook as PDF
Date/time	Now(), Format()	Record submission timestamps
Failure modes
Symptom	Likely cause	Fix
Duplicate buttons appear after running macros	Buttons are added on each macro run without removal	Remove existing buttons before adding new ones or toggle visibility instead of creating new controls
Macro silently fails with no output	On Error Resume Next swallows errors	Replace with structured error handling and inspect the error in Err.Description
Workbook becomes read‑only after macro run	Macro opened a file without closing or saved over the original	Ensure all workbooks are closed (Workbook.Close SaveChanges:=True) and write operations occur on working copies
Checklist rows remain incomplete but stage submitted	Validation omitted or incorrectly implemented	Double‑check that the validation loop iterates over all rows and checks each required column
Quick reference commands
Open the VBA editor: Press Alt + F11.
Run a macro: Press F5 inside the module or assign the macro to a button in the Ribbon.
Toggle breakpoints: Click in the left margin or press F9.
Step through code: Use F8 to step into lines and inspect variables in the Immediate window (Ctrl + G).
Save and rebuild: After modifying code, save the workbook and ensure macros are enabled. To rebuild the unified workbook programmatically, run the build scripts in the repository (see the repository README).
Chamber 19 specifics
The workbook uses dedicated sheets for 30 %, 60 %, 90 % IFA and IFC checklists with defined columns (Discipline, Item Description, Responsible Party, Priority, Status, Due Date, Remarks, Document Reference, Verified By). Do not modify the schema without updating the macros.
The ribbon adds buttons for stage submission, export and filtering. If you extend the ribbon, follow the existing patterns for cleanup and event wiring.
Macros must never run on production drawings without creating a backup; this rule exists because previous versions inadvertently overwrote client deliverables.