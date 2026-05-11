# Excel Formatting and Advanced Features Skill

Use this skill when building Excel workbooks that need professional formatting, interactive controls (buttons, dropdowns, sliders), conditional formatting, charts, or VBA automation. The goal is workbooks that are clear, robust, and designed to be used by people who did not build them.

---

## Design principles

Good Excel design makes data readable at a glance and workflows impossible to break by accident. Decide on structure before touching formatting.

- **Structure first.** Model the data correctly before applying any formatting.
- **One table per concern.** Do not mix data sources or calculation types in a single block.
- **Named ranges over cell addresses.** `=SUM(Rebar_Lengths)` is maintainable; `=SUM(D4:D203)` is not.
- **Protect by default.** Lock formula cells; leave only intentional input cells unlocked.
- **Avoid merged cells in data ranges.** They break sorting, filtering, and formula references. Use "Centre Across Selection" instead for visual centering.
- **Use Excel Tables (`Ctrl+T`).** They auto-expand, support structured references, and enable consistent formatting with zero extra work.

---

## Color, typography, and visual hierarchy

### Color palette

Use a restrained palette — three or four colors maximum. Stick to the workbook's theme colors so the file looks consistent in any Office version.

| Role | Recommendation |
| --- | --- |
| Header background | Dark solid color from theme (e.g. dark blue, charcoal) |
| Header text | White or near-white, bold |
| Alternating rows | Very light tint of the header color (5–10% opacity) |
| Input cells | Light yellow or unshaded with a visible border |
| Formula cells | Locked, shaded to signal they are not editable |
| Totals / summary rows | Slightly darker shade, top border, bold |
| Alerts / errors | Red background with white text — reserve this for genuine errors |

### Typography

- Body text: Calibri 11 or Arial 10 — default Office fonts render cleanly at all zoom levels.
- Headers: Bold, 1–2pt larger than body.
- Never use more than two font families in a single workbook.
- Row height: 18–22pt feels spacious and is easy to click. Avoid the default cramped 15pt for data users will actually read.

### Borders and whitespace

- Use thin interior borders and a medium outer border to define table boundaries.
- Leave one empty column on the left of any significant table — it gives the sheet breathing room.
- Freeze the top row (and left column if needed) for any table taller than a screen.

---

## Conditional formatting

Use conditional formatting to make patterns visible without extra columns or manual maintenance.

```text
Common patterns:

Data bars        — visualise magnitude in a column (sales, lengths, scores)
Color scales     — 3-color gradient to show high/medium/low across a range
Icon sets        — traffic lights or arrows for status columns
Rule-based       — highlight cells above threshold, duplicate values, or blanks
```

**Rules for conditional formatting rules:**

- Apply to the narrowest range that makes sense — avoid applying to entire columns.
- Name your rules clearly if using formula-based conditions.
- Order rules deliberately — Excel evaluates from top to bottom and stops at the first match (unless "stop if true" is off).
- Test at different zoom levels — icon sets and data bars shrink at low zoom.

---

## Form controls and buttons

Excel has two families of controls: **Form Controls** (simpler, VBA-friendly) and **ActiveX Controls** (more capable, more fragile). Use Form Controls unless you specifically need ActiveX features.

### Inserting a button (Form Control)

1. Developer tab → Insert → Form Controls → Button.
2. Draw on the sheet; the "Assign Macro" dialog appears.
3. Assign an existing macro or click New to create one.
4. Right-click the button → Edit Text to label it clearly.
5. Format the button: right-click → Format Control → Font/Colors.

### Inserting a dropdown (Form Control)

1. Developer tab → Insert → Form Controls → Combo Box.
2. Draw on the sheet.
3. Right-click → Format Control → Control tab:
   - **Input range**: the list of values (use a named range).
   - **Cell link**: the cell that receives the selected index (1-based).
4. Use `INDEX(list, linked_cell)` to convert the index into the selected value.

### Other useful controls

| Control | Use case |
| --- | --- |
| Spin Button | Increment/decrement a numeric input cell |
| Scroll Bar | Adjust a value across a range with a slider |
| Check Box | Toggle a boolean flag linked to a cell (`TRUE`/`FALSE`) |
| Option Button (Radio) | Mutually exclusive selection within a group box |
| List Box | Multi-select from a visible list |

### Sizing and alignment

- Hold `Alt` while drawing a control to snap it to cell grid lines.
- Group related controls (select all → right-click → Group) so they move together.
- Set consistent sizes: select multiple controls → Format Control → Size tab.

---

## VBA for button actions

Keep macros short, focused, and safe. Each button should do one clearly named thing.

```vb
Option Explicit

Sub ExportToPDF()
    ' Validate before acting
    If Not ValidateInputs() Then Exit Sub

    Dim wb As Workbook
    Dim ws As Worksheet
    Set wb = ThisWorkbook
    Set ws = wb.Sheets("Report")

    Dim outputPath As String
    outputPath = wb.Path & "\output\" & Format(Now, "YYYY-MM-DD") & "_Report.pdf"

    On Error GoTo ErrorHandler
    ws.ExportAsFixedFormat Type:=xlTypePDF, Filename:=outputPath, _
        Quality:=xlQualityStandard, IncludeDocProperties:=True, _
        IgnorePrintAreas:=False, OpenAfterPublish:=False

    MsgBox "Exported to: " & outputPath, vbInformation
    Exit Sub

ErrorHandler:
    MsgBox "Export failed: " & Err.Description, vbCritical
End Sub
```

**VBA non-negotiables:**

- `Option Explicit` at the top of every module.
- `On Error GoTo ErrorHandler` at the top of every procedure that touches files, external data, or protected sheets.
- Never use `On Error Resume Next` to suppress errors.
- Always call `Application.EnableEvents = True` in the error handler if you disabled it.
- Save a timestamped backup before any bulk operation that modifies cell data.

---

## Data validation

Data validation prevents bad input at the cell level without requiring VBA.

```text
Types:
  Whole Number     — restrict to integers within a range
  Decimal          — restrict to numeric values with precision
  List             — dropdown from a range or comma-separated values
  Date / Time      — restrict to valid dates or times
  Text Length      — enforce minimum/maximum character count
  Custom           — formula-based rule (e.g. must start with "R3P-")
```

Best practices:

- Source dropdown lists from named ranges on a dedicated `_Lists` sheet.
- Always add an Input Message (tooltip) explaining what is expected.
- Set Error Alert to Stop for critical fields; Warning for advisory constraints.
- Use `IFERROR` in formulas that depend on validated cells to handle out-of-range edge cases gracefully.

---

## Charts and sparklines

### Chart design rules

- Title every chart with a statement, not a label. "Rebar length by layer (ft)" is a label; "Foundation layer accounts for 42% of total rebar" is a statement.
- Remove chart junk: gridlines at low opacity only, no border, no background fill.
- Use consistent colors between charts in the same workbook — match the palette defined above.
- Place charts on the same sheet as their source data unless the workbook has a dedicated dashboard sheet.

### Sparklines

Sparklines (Insert → Sparklines) are mini charts inside a single cell — useful for trend columns in summary tables.

- Use Line sparklines for trends over time.
- Use Column sparklines for comparisons.
- Set consistent axis min/max across a group so sparklines are comparable.
- Show the high/low point markers for context.

---

## Named ranges and structured references

```vb
' Create a named range via VBA
ThisWorkbook.Names.Add Name:="Rebar_Lengths", _
    RefersTo:=Sheets("Data").Range("D4:D203")

' Reference it in a formula
' =SUM(Rebar_Lengths)
' =AVERAGE(Rebar_Lengths)
' =COUNTIF(Rebar_Lengths, ">0")
```

Use Excel Tables for any data that will grow:

```text
Ctrl+T              — convert range to Table
Table[Column]       — structured reference, auto-expands
Table[@Column]      — reference to current row only (useful in calculated columns)
```

---

## Sheet protection

Protect sheets to separate input areas from formula areas.

```vb
Sub ProtectInputSheet()
    Dim ws As Worksheet
    Set ws = ThisWorkbook.Sheets("Input")

    ' Unlock input cells before protecting
    ws.Range("InputCells").Locked = False

    ws.Protect Password:="", _
        UserInterfaceOnly:=True, _   ' allows VBA to still write to protected cells
        AllowSorting:=True, _
        AllowFiltering:=True, _
        DrawingObjects:=True, _
        Contents:=True
End Sub
```

`UserInterfaceOnly:=True` is essential if macros need to write to protected sheets — without it, you must unprotect and re-protect around every write operation.

---

## Print setup

```vb
Sub ConfigurePrintArea()
    With ActiveSheet.PageSetup
        .PrintArea = "$A$1:$P$50"
        .Orientation = xlLandscape
        .FitToPagesWide = 1
        .FitToPagesTall = False
        .PaperSize = xlPaperA4
        .LeftMargin = Application.InchesToPoints(0.5)
        .RightMargin = Application.InchesToPoints(0.5)
        .TopMargin = Application.InchesToPoints(0.75)
        .BottomMargin = Application.InchesToPoints(0.75)
        .CenterHorizontally = True
        .PrintTitleRows = "$1:$2"   ' repeat header rows on each page
    End With
End Sub
```

---

## Failure modes

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| Duplicate buttons appear after running macros | Controls added on each macro run without cleanup | Remove or hide existing controls before creating new ones |
| Macro silently fails | `On Error Resume Next` swallowing errors | Replace with `On Error GoTo ErrorHandler`; inspect `Err.Description` |
| Conditional formatting stops applying | Range shifted after row inserts | Redefine the rule range; use Table-relative references |
| Dropdown shows index number, not value | Cell link returns index, not the list item | Use `=INDEX(ListRange, LinkedCell)` to convert |
| Merged cells break sort/filter | Data range contains merged cells | Replace merges with "Centre Across Selection" |
| VBA can't write to protected sheet | `UserInterfaceOnly` not set | Add `UserInterfaceOnly:=True` to the `Protect` call |

---

## Quick reference

```text
Ctrl+T              — create a Table from a range
Ctrl+Shift+F3       — create named ranges from selection labels
Alt+F11             — open VBA editor
F5 (in VBA editor)  — run macro
F8 (in VBA editor)  — step through code line by line
Ctrl+G (in VBA)     — open Immediate window for quick evaluation
Alt (while drawing) — snap control to cell grid
```
