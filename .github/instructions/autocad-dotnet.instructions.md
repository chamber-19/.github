applyTo:

"**/*.cs"
"**/*.csproj"
"**/*.props"
AutoCAD .NET plugin rules

Our .NET plugins extend AutoCAD and are loaded into the AutoCAD process. Conformance to the following rules prevents crashes and corruption:

MUST wrap all database operations in TransactionManager.StartTransaction(). Open entities ForRead and call .UpgradeOpen() only when you actually need to write. Failing to do so can leave the drawing database locked.
MUST set Copy Local to False for all Autodesk assemblies. Referencing AutoCAD assemblies with Copy Local enabled will copy them to the output directory, leading to version mismatches at runtime.
MUST register commands with bare names (e.g. [CommandMethod("TOTAL")]). Do not prefix command names with organisation identifiers (CH19TOTAL); the command identity lives in the attribute metadata.
MUST use new Database(false, true) and call ReadDwgFile() when performing batch operations without a UI. NEVER open AutoCAD’s UI for batch processing.
MUST release unmanaged resources deterministically. Dispose of transactions, editors and COM objects promptly.
NEVER call COM APIs inside a .NET plugin for anything beyond trivial attribute reads. Use COM through Python sidecars instead. Embedding COM in plugins has previously caused deadlocks and memory leaks.

For deeper reference, consult AUTOCAD_DOTNET.md in docs/skills/.