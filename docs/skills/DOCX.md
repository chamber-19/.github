# DOCX Skill

Use this skill when creating or editing `.docx` files in any Chamber 19 context — Python backends generating transmittals, JavaScript frontends building documents, or direct editing of existing Word files. Verification is always: open the result in Microsoft Word.

---

## Mental model

A `.docx` file is a ZIP archive containing XML files. The two main libraries expose different entry points to the same underlying format:

- **`python-docx`** — Python library for creating documents from scratch. High-level API. Can't do everything (tracked changes, hyperlinks, some table features are missing or broken).
- **`docx` (npm)** — JavaScript/TypeScript library for creating documents from scratch. More complete API than python-docx. Used when generating docs from the frontend or a Node.js script.
- **Document library** (`scripts/document.py` from the docx skill package) — Python library for editing **existing** documents by manipulating the raw XML directly. Use this when python-docx can't do what you need on an existing file.

**Verify everything by opening the output in Word.** There is no automated visual check — Word will show you if something is wrong.

---

## Creating a new document — Python (`python-docx`)

Use this for `transmittal-builder` and any Python FastAPI sidecar that generates `.docx` output.

### Non-negotiable patterns

- **Use styles, not direct formatting.** `paragraph.style = doc.styles['Heading 1']` — never manually set font size and bold on every run.
- **Use the Chamber 19 template.** Open with `Document(template_path)` rather than `Document()`. The template carries all required styles, page size, and margins.
- **Use `pathlib.Path`** for all file paths. Never string-concatenate paths.
- **Do not write to stdout.** The FastAPI sidecar's stdout is the IPC channel. Log to stderr or use `logging`.
- **Call `.save()` before moving the file.** The file is only fully written when `.save()` returns.

### Common patterns

```python
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.section import WD_ORIENT
from pathlib import Path

# Open template (preferred) or blank document
doc = Document(Path("templates/transmittal_template.dotx"))

# Heading and paragraph
doc.add_heading("Transmittal Package", level=1)
p = doc.add_paragraph("All drawings listed below are issued for construction.")
p.style = doc.styles["Body Text"]

# Table
table = doc.add_table(rows=1, cols=4)
table.style = "Table Grid"
hdr = table.rows[0].cells
hdr[0].text = "Drawing No."
hdr[1].text = "Revision"
hdr[2].text = "Title"
hdr[3].text = "Status"
for drawing in drawings:
    row = table.add_row().cells
    row[0].text = drawing.number
    row[1].text = drawing.revision
    row[2].text = drawing.title
    row[3].text = drawing.status

# Page margins (if not using a template)
section = doc.sections[0]
section.page_width    = Inches(11)
section.page_height   = Inches(8.5)
section.orientation   = WD_ORIENT.LANDSCAPE
section.left_margin   = Inches(1)
section.right_margin  = Inches(1)
section.top_margin    = Inches(0.75)
section.bottom_margin = Inches(0.75)

# Header
header = doc.sections[0].header
header.paragraphs[0].text = "Chamber 19 — CONFIDENTIAL"
header.paragraphs[0].style = doc.styles["Header"]

# Save
output = Path("backend/output") / "transmittal_2026-05-10.docx"
output.parent.mkdir(parents=True, exist_ok=True)
doc.save(output)
```

### python-docx failure modes

| Symptom | Likely cause | Fix |
| --- | --- | --- |
| `KeyError: style 'Heading 1'` | Opened blank `Document()` instead of template | Use `Document(template_path)` |
| Table borders missing in Word | Style applied after rows were added | Set `table.style` before adding any rows |
| Header appears blank | `header.is_linked_to_previous` is `True` | Set `section.header.is_linked_to_previous = False` before writing |
| Word shows repair dialog on open | `.save()` called while file is open in Word | Close in Word first, or write to a temp path then rename |
| Font missing on another machine | Non-standard font used | Stick to Calibri or Arial |
| `PackageNotFoundError` | `python-docx` not in virtualenv | Add `python-docx` to `requirements.txt` |

---

## Creating a new document — JavaScript (`docx` npm)

Use this when generating documents from a Node.js script or the frontend. Install: `npm install docx`

```javascript
const { Document, Packer, Paragraph, TextRun, Table, TableRow, TableCell,
        Header, Footer, AlignmentType, PageOrientation, LevelFormat,
        ExternalHyperlink, HeadingLevel, BorderStyle, WidthType,
        ShadingType, VerticalAlign, PageNumber, PageBreak } = require('docx');
const fs = require('fs');

const doc = new Document({ sections: [{ children: [/* content */] }] });
Packer.toBuffer(doc).then(buffer => fs.writeFileSync("output.docx", buffer));
```

### Text and paragraphs

```javascript
// NEVER use \n for line breaks — always use separate Paragraph elements
// ❌ new TextRun("Line 1\nLine 2")
// ✅ separate Paragraph elements

new Paragraph({
  alignment: AlignmentType.CENTER,
  spacing: { before: 200, after: 200 },
  children: [
    new TextRun({ text: "Bold", bold: true }),
    new TextRun({ text: "Italic", italics: true }),
    new TextRun({ text: "Colored", color: "FF0000", size: 28, font: "Arial" }),
  ]
})
```

### Styles

```javascript
const doc = new Document({
  styles: {
    default: { document: { run: { font: "Arial", size: 24 } } }, // 12pt default
    paragraphStyles: [
      { id: "Heading1", name: "Heading 1", basedOn: "Normal", next: "Normal",
        run: { size: 32, bold: true, color: "000000", font: "Arial" },
        paragraph: { spacing: { before: 240, after: 240 }, outlineLevel: 0 } },
      { id: "Heading2", name: "Heading 2", basedOn: "Normal", next: "Normal",
        run: { size: 28, bold: true, color: "000000", font: "Arial" },
        paragraph: { spacing: { before: 180, after: 180 }, outlineLevel: 1 } },
    ]
  },
  sections: [{ children: [
    new Paragraph({ heading: HeadingLevel.HEADING_1, children: [new TextRun("Title")] })
  ]}]
});
```

### Lists

```javascript
// ALWAYS use numbering config — NEVER use unicode bullet characters
// ❌ new TextRun("• Item")
// ✅ use LevelFormat.BULLET constant (NOT the string "bullet")

const doc = new Document({
  numbering: {
    config: [
      { reference: "bullet-list",
        levels: [{ level: 0, format: LevelFormat.BULLET, text: "•",
          alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] },
      { reference: "numbered-list",
        levels: [{ level: 0, format: LevelFormat.DECIMAL, text: "%1.",
          alignment: AlignmentType.LEFT,
          style: { paragraph: { indent: { left: 720, hanging: 360 } } } }] }
    ]
  },
  sections: [{ children: [
    new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
      children: [new TextRun("First bullet")] }),
    new Paragraph({ numbering: { reference: "bullet-list", level: 0 },
      children: [new TextRun("Second bullet")] }),
  ]}]
});

// Each unique reference = independent list that restarts at 1
// Same reference = continues numbering
```

### Tables

```javascript
// Set columnWidths at table level AND width on each cell — both required
// DXA units: 1440 = 1 inch, Letter usable width with 1" margins = 9360 DXA
// 2 equal columns: [4680, 4680] | 3 equal columns: [3120, 3120, 3120]

const border = { style: BorderStyle.SINGLE, size: 1, color: "CCCCCC" };
const cellBorders = { top: border, bottom: border, left: border, right: border };

new Table({
  columnWidths: [4680, 4680],
  margins: { top: 100, bottom: 100, left: 180, right: 180 },
  rows: [
    new TableRow({
      tableHeader: true,
      children: [
        new TableCell({
          borders: cellBorders,
          width: { size: 4680, type: WidthType.DXA },
          // ALWAYS ShadingType.CLEAR — ShadingType.SOLID causes black backgrounds
          shading: { fill: "D5E8F0", type: ShadingType.CLEAR },
          children: [new Paragraph({ children: [new TextRun({ text: "Header", bold: true })] })]
        }),
      ]
    }),
  ]
})
```

### Headers, footers, page numbers, and breaks

```javascript
const doc = new Document({
  sections: [{
    properties: {
      page: {
        margin: { top: 1440, right: 1440, bottom: 1440, left: 1440 },
        size: { orientation: PageOrientation.LANDSCAPE },
      }
    },
    headers: {
      default: new Header({ children: [new Paragraph({ children: [new TextRun("Header")] })] })
    },
    footers: {
      default: new Footer({ children: [new Paragraph({
        alignment: AlignmentType.CENTER,
        children: [
          new TextRun("Page "),
          new TextRun({ children: [PageNumber.CURRENT] }),
          new TextRun(" of "),
          new TextRun({ children: [PageNumber.TOTAL_PAGES] }),
        ]
      })] })
    },
    children: [
      new Paragraph({ children: [new TextRun("Page 1 content")] }),
      // Page break — MUST be inside a Paragraph, never standalone
      new Paragraph({ children: [new PageBreak()] }),
      new Paragraph({ children: [new TextRun("Page 2 content")] }),
    ]
  }]
});
```

### Images

```javascript
// type parameter is REQUIRED — always specify it
new Paragraph({
  children: [new ImageRun({
    type: "png",                // required: "png", "jpg", "jpeg", "gif", "bmp", "svg"
    data: fs.readFileSync("image.png"),
    transformation: { width: 200, height: 150 },
    altText: { title: "Logo", description: "Company logo", name: "Logo" } // all three required
  })]
})
```

### docx-js critical rules (will corrupt the file if violated)

- `PageBreak` **must** be inside a `Paragraph` — standalone `new PageBreak()` creates invalid XML Word cannot open
- **Never** `\n` inside `TextRun` — use separate `Paragraph` elements
- **Always** `ShadingType.CLEAR` for cell shading — `ShadingType.SOLID` = black background
- **Always** `LevelFormat.BULLET` constant for bullets — not the string `"bullet"`
- **Always** specify `type` on `ImageRun`
- **Always** `columnWidths` on the `Table` AND `width` on each `TableCell`
- TOC requires `HeadingLevel` styles only — do not mix custom styles on heading paragraphs or TOC breaks

---

## Chamber 19 specifics

- `transmittal-builder` output goes in `backend/output/` — use `pathlib.Path` relative to the project root.
- Transmittal documents use the template at `templates/transmittal_template.dotx`. Do not define styles from scratch.
- The FastAPI endpoint returns the output file path to the Tauri frontend; the frontend opens or saves it via the Tauri `fs` API. Do not stream the binary over the REST response.
- Drawing metadata comes from the SQLite register — never read state back from the `.docx` file itself.

---

## Quick reference

```bash
# python-docx
pip install python-docx

from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.section import WD_ORIENT

# docx (JavaScript)
npm install docx

# Document library (editing existing files)
pip install defusedxml
python ooxml/scripts/unpack.py input.docx unpacked/
python ooxml/scripts/pack.py unpacked/ output.docx
```
