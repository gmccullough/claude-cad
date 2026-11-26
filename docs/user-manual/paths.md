# OpenSCAD User Manual: Paths

> Source: [https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Paths](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Paths)

OpenSCAD looks for and saves resources to various paths. This is an overview.

This page describes the patterns used for all systems and all platforms. For the paths used on your particular installation, look at "Library info" on the "Help" menu.

## Env variables

- `HOME`
- `XDG_CONFIG_HOME`
- `OPENSCAD_FONT_PATH`
- `OPENSCADPATH`

## Per platform roots

### ResourcesPath

- **UNIX-like:** (system-dependent)
- **Mac OS X:** `OpenSCAD.app/Contents/Resources`
- **Windows:** installation directory, typical default `C:\Program Files\OpenSCAD`

### DocumentsPath

- **UNIX-like:** `$HOME/.local/share`
- **Mac OS X:** `[NSDocumentDirectory]`, typically `$HOME/Documents`
- **Windows:** `[FOLDERID_Documents]\OpenSCAD`, often `C:\Users\username\Documents\OpenSCAD`

### UserConfigPath

- **UNIX-like:** `$XDG_CONFIG_HOME/OpenSCAD` or `$HOME/.config/OpenSCAD`
- **Mac:** `[NSApplicationSupportDirectory]`, typically `$HOME/Library/Application Support/OpenSCAD`
- **Windows:** `[FOLDERID_LocalAppData]\OpenSCAD`, typically `C:\Users\username\AppData\Local\OpenSCAD`

**Note:** the UserConfigPath directory is not created by default; if desired, the user must create it.

**Windows note:** `FOLDERID_Documents` and `FOLDERID_LocalAppData` were formerly known as `CSIDL_PERSONAL` and `CSIDL_LOCAL_APPDATA`.

## Read-only Resources

- **libraries:** `[ResourcesPath]/libraries`
- **fonts:** `[ResourcesPath]/fonts`
- **render color schemes:** `[ResourcesPath]/color-schemes/render`
- **editor color schemes:** `[ResourcesPath]/color-schemes/editor`
- **templates:** `[ResourcesPath]/templates`

## User Resources

- **libraries:** `$OPENSCADPATH`, `[DocumentsPath]/OpenSCAD/libraries`
- **fonts:**
  - `$HOME/.fonts`
  - `$HOME/.local/share/fonts`
- **render color schemes:** `[UserConfigPath]/color-schemes/render`
- **editor color schemes:** `[UserConfigPath]/color-schemes/editor`
- **templates:** `[UserConfigPath]/templates`

## Misc Resources

- **GUI preferences** (Uses QSettings):
  - **UNIX-like:** `$HOME/.config/OpenSCAD.conf`
  - **Windows:** Registry: `HKEY_CURRENT_USER\SOFTWARE\OpenSCAD\OpenSCAD`
  - **Mac OS X:** `$HOME/Library/Preferences/org.openscad.OpenSCAD.plist`
- **backups:** `[DocumentsPath]/OpenSCAD/backups`
