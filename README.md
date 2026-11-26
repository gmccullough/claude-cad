# claude-cad

A working setup for designing 3D-printable parts with Claude: you describe a part or send
photos, and Claude writes parametric OpenSCAD, builds it, looks at the result, and hands back a
ready-to-slice Bambu Studio `.3mf`.

It isn't a library or an app. It's the docs and small tools that make a coding agent good at
CAD, pulled out of a year of printing real parts (bike mounts, fidget toys, repair parts). Most
of the value is in [AGENTS.md](AGENTS.md): the rules Claude follows, and the lessons behind
them, so it doesn't relearn them on your tokens.

## What's in it

| Path | What |
|---|---|
| [AGENTS.md](AGENTS.md) | The agent's standing guide: workflow, measuring from photos, which tool to use when, tolerances, magnet pause-and-insert, hardware rules, print settings. `CLAUDE.md` imports it so Claude Code always loads it. |
| [OPENSCAD_DOCS.md](OPENSCAD_DOCS.md), [docs/](docs/) | Which OpenSCAD build runs where, what each one supports, and pitfalls checked against them, plus a local copy of the language reference to look things up in |
| [photo-to-cad-process.md](photo-to-cad-process.md) | 2D-first pipeline for replicating a shape from photos |
| [tools/](tools/README.md) | `openscad` (runs anywhere, incl. wasm in the cloud), `render` (lets the agent *see* its model), `bambu3mf.py` (STL → ready-to-slice `.3mf` with settings and magnet pauses), `cloud/check_slice.py` (slice headless and report what Bambu really did), `cloud/build_artifact.py` (phone-viewable 3D page), `view` (local viewer server) |
| [viewer/](viewer/README.md) | three.js STL/3MF viewer shared by `render`, `view` and the phone page: Bambu bed positions, modifiers, pause layers, Z cut |
| [examples/](examples/) | Two real projects with their full design logs |

## Getting started

1. Use this repo as a template (or fork it) so you have your own copy on GitHub, then open it
   in [Claude Code](https://claude.com/claude-code): on your computer, or as a cloud session
   from claude.ai/code or the Claude mobile app.
2. Make a directory for your part and ask for it: *"Make a mount that holds a 22 mm tube to a
   flat panel with two M4 screws."* Or send photos with a ruler in the shot: the agent
   estimates every dimension with a range, says what it's unsure of, and builds anyway.
3. Claude builds the STL and `.3mf` and renders it to check its own work, then shows you the
   model.
4. Print it, then tell Claude how it went ("the slot is sloppy", "pocket too tight"). Each
   round gets logged in the project's `AGENTS.md`, so the next session picks up where you
   left off.

## From your phone, in the cloud

Everything here runs in a Claude Code cloud session, so you don't need a computer at all. The
whole loop works from the Claude app on a phone:

- **Start a session** on your copy of this repo from the Claude mobile app (or claude.ai/code
  in any browser). Claude works in a Linux container in the cloud, not on your phone.
- **Send photos straight from the camera roll.** Put a ruler in the shot, square to the part.
  Claude saves them into the project's `ref/photos/` and measures from them.
- **See the model on your phone.** Claude builds a 3D viewer page and publishes it as a private
  claude.ai link: orbit, pinch to zoom, cut through it at any height, read sizes and volume.
  When the design changes, the same link updates.
- **Get the `.3mf`.** Claude builds the ready-to-slice file in the session and can hand it to you
  in the chat. Claude also commits the design itself (the `.scad`, scripts and notes) to your
  repo, so the next session, on any device, starts where this one stopped.

Nothing needs installing, on the phone or in the cloud. Each tool installs what it needs the
first time it runs (`tools/cloud/need`): OpenSCAD compiled to WebAssembly, Python mesh
libraries, and a headless browser for renders. Slicing a `.3mf` with the real Bambu Studio CLI
to check its settings (`tools/cloud/check_slice.py`) needs the cloud environment to allow
`github.com` and `release-assets.githubusercontent.com` (see
[tools/cloud/BAMBU.md](tools/cloud/BAMBU.md)).

**On a computer** the same tools prefer the desktop apps: OpenSCAD, Bambu Studio and Blender
from `/Applications` on a Mac when they're there. `tools/render` needs Playwright once
(`npm i -g playwright && npx playwright install chromium`), and `tools/view` serves an
interactive viewer of every model in the repo at `localhost:8000`.

The slicer tooling targets a Bambu P2S with PLA (`tools/profiles/`). Other Bambu printers work
with their own profile; other slicers can use the STLs.

## The examples

- **[triangular-elipsoid](examples/triangular-elipsoid/)**: a fidget spinner on a 608 bearing.
  Two different plates, a terraced dome tuned for layer lines, and a `build_3mf.py` that reads
  the magnet pause height out of the model so the pause can't drift from the pocket.
  `python3 examples/triangular-elipsoid/build_3mf.py` builds it.
- **[roval-wahoo-mount](examples/roval-wahoo-mount/)**: an out-front bike computer mount. The
  bar section was traced from photos and a contour gauge, and the Wahoo quarter-turn receiver
  is cut out of Wahoo's own published mount design rather than re-modelled. Its `AGENTS.md`
  is 20+ versions of real print-and-report iteration. The receiver graft comes from Wahoo's
  MIT-licensed [ELEMNT-Mount](https://github.com/WahooFitness/ELEMNT-Mount) files; its notice
  is in `ref/WAHOO-LICENSE.txt`.

## Keeping knowledge in the repo

The agent writes what it learns (measurements, print results, tool gotchas) into the repo's
docs, not into its own private memory, and `.claude/settings.json` turns Claude Code's
auto-memory off here. That way every clone, every collaborator and every cloud session starts
from the same knowledge. The table at the top of [AGENTS.md](AGENTS.md) says where each kind of
lesson goes.

## License

MIT, see [LICENSE](LICENSE). `docs/` is from the OpenSCAD manual (CC BY-SA) and
`viewer/vendor/` is three.js (MIT). The Wahoo receiver in the mount example is Wahoo Fitness's design (MIT,
notice in `examples/roval-wahoo-mount/ref/WAHOO-LICENSE.txt`).
