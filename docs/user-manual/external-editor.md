# OpenSCAD User Manual: Using an external Editor with OpenSCAD

> Source: [https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_an_external_Editor_with_OpenSCAD](https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Using_an_external_Editor_with_OpenSCAD)

## Why use an external editor

Many people prefer to use a certain editor. They are used to the feature set and know the keybindings. OpenSCAD's editor is functional and simple but might lack features people know from other editors.

A relatively recent benefit is that many of the more powerful external editors can act as a client for an OpenSCAD language server, permitting IDE-style functionality such as inline error/warning displays, module/function documentation on hover, jump to module/function definition, find module/function references, code reformatting, etc. There are a handful of OpenSCAD language servers in various levels of development, currently the **openscad-lsp** language server provides the most features.

## How to use an external editor

OpenSCAD is able to check for changes of files and automatically recompile if a file change occurs. To use this feature enable **"Design->Automatic Reload and Preview"**.

Once the feature is activated, just load the scad file within OpenSCAD as usual ("File->Open.."). After that, open the scad file in your favorite editor too. Edit and work on the scad file within the external editor. Whenever the file is saved to disk (from within the external editor), OpenSCAD recognizes the file change and automatically recompiles accordingly.

The internal editor can be hidden by minimizing the frame with the mouse or by selecting **"Window->Hide editor"**.

## Support of external editors

In principle all editors can be used. Some even have extensions/modes to provide features for OpenSCAD.

- **Atom:** There is a Language OpenSCAD package for Atom that provides highlighting and snippets.
- **Emacs:** OpenSCAD provides an emacs mode for OpenSCAD files. Use the link or install `scad-mode` via emacs package management (ELPA) with the MELPA repository.
- **Geany:** cobra18t provides a Geany syntax file for OpenSCAD. See Instructions tab in Thingiverse to install it.
- **Gedit:** Andy Turner provides a Gedit syntax file for OpenSCAD.
- **IntelliJ:** has an 'OpenSCAD Language Support' plugin.
- **Kate:** nerd256 provides a kate syntax file for OpenSCAD. See Instructions tab in Thingiverse to install it. You could create also a kate External tool to open OpenSCAD with the current file with script `openscad %directory/%filename`.
- **Neovim:** An example configuration including basic linting and formatting is available via OpenSCAD in Neovim.
- **Notepad++:** TheHeadlessSourceMan provides a Notepad++ syntax file for OpenSCAD. See Instructions tab in Thingiverse to install it.
- **OpenSCADitor:** OpenSCAD-dedicated editor.
- **Pulsar:** Pulsar has the `language-openscad` package to provide highlighting and snippets.
- **Sublime:** Syntax highlighting and Customizer support.
- **Textmate:** Syntax highlighting and Customizer support.
- **VIM:** vim.org provides a VIM syntax file for OpenSCAD.
- **Visual Studio Code** and its FOSS build, **VSCodium**, have multiple OpenSCAD extensions available, providing highlighting, autocomplete, go to definition, code formatting, preview and more. Type "OpenSCAD" into the View > Extensions panel search box to find and install.
