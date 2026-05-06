AUTOCAD . NET SKILL
Mental model

AutoCAD exposes a managed API through the Autodesk.AutoCAD.* namespaces. When writing a plugin, your code is loaded into the AutoCAD process (acad.exe) and must respect its threading and reentrancy constraints. The primary object model includes:

Application – represents the running AutoCAD instance and gives access to documents.
Document – represents an open drawing (.dwg). Each document has its own Editor and Database.
Database – the persistent storage for entities. To modify entities, you start a Transaction via the TransactionManager.

Plugins typically define commands using the [CommandMethod] attribute. When a user runs your command in AutoCAD, the method executes.

Non‑negotiable patterns
Always start a transaction: using (Transaction tr = db.TransactionManager.StartTransaction()) { ... }. Open objects ForRead (OpenMode.ForRead) first and call .UpgradeOpen() when you need to write.
Set Copy Local to False on all Autodesk assembly references. The AutoCAD loader will locate the assemblies at runtime; copying them can lead to loading the wrong version.
Register commands with clean names, e.g. [CommandMethod("TOTAL")]. Avoid prefixing names with CH19. The command identity is stored in the attribute metadata, not the visible name.
For headless batch processing, use new Database(false, true) to create a temporary database and call ReadDwgFile() to load drawings. Never open the AutoCAD UI for batch tasks.
Dispose of unmanaged resources deterministically. Use using blocks or call .Dispose() on transactions and database objects.
Do not call COM APIs from .NET plugins. COM calls can block the AutoCAD message loop. If you need COM, use a Python sidecar instead.
Common namespaces and classes
Purpose	Namespace/Class	Notes
Application entry point	Autodesk.AutoCAD.Runtime	Contains CommandMethodAttribute and IExtensionApplication
Documents and editors	Autodesk.AutoCAD.ApplicationServices.Application, Document, Editor	Use Application.DocumentManager.MdiActiveDocument to get the current document
Database access	Autodesk.AutoCAD.DatabaseServices.Database, Transaction, BlockTable, BlockTableRecord	Core classes for reading/writing drawings
Geometry	Autodesk.AutoCAD.Geometry	Types like Point3d, Vector3d
User input	Autodesk.AutoCAD.EditorInput	Prompt the user for points, numbers or options
Failure modes
Symptom	Likely cause	Fix
AutoCAD crashes upon loading plugin	Copying Autodesk assemblies into the plugin’s output directory	Set Copy Local to False for all Autodesk references
Command runs but does nothing	Forgot to mark the method with [CommandMethod] or the name is misspelled	Add [CommandMethod("NAME")] with the exact name
Changes do not persist	Opening entities ForWrite incorrectly or not committing the transaction	Open entities ForRead, call .UpgradeOpen() before editing, and call tr.Commit()
Plugin deadlocks or hangs	Calling COM APIs or running long loops on the UI thread	Offload heavy work to Python sidecars or separate threads, and avoid COM inside plugins
Quick reference commands
Build plugin: dotnet build or msbuild Plugin.sln.
Load plugin into AutoCAD: Use the NETLOAD command and select the compiled DLL.
Reload plugin after rebuilding: Use RELOAD (if available) or unload via NETUNLOAD and then NETLOAD again.
Debugging: Attach Visual Studio to acad.exe, set breakpoints in your plugin code, and run the command in AutoCAD.
Chamber 19 specifics
Keep command names bare; we rely on metadata to identify them.
Use the transaction patterns documented here for all drawing modifications. Failing to do so has historically corrupted drawings.
Python sidecars may read attributes via COM, but never write. All write operations should be performed by the .NET plugin using AutoCAD APIs.
For deterministic batch operations, avoid launching AutoCAD’s UI and instead load drawings into a new Database instance.