# Viewer

three.js viewer for the repo's STL and Bambu 3MF output. It reads the files
the slicer will actually get. It does not re-evaluate `.scad` (use
`tools/openscad` or `tools/render part.scad` for that).

```bash
tools/view            # http://localhost:8000/viewer/  (live list of every .stl/.3mf)
tools/render x.3mf    # same scene code, headless -> PNG (see tools/cloud/README.md)
```

- **3MF**: objects sit at their bed positions with the printable-area outline.
  Modifier parts show translucent blue, negative parts red. Pause and
  colour-change layers show as orange planes. The info panel lists parts,
  layer G-code and the headline print settings.
- **Cut Z** slider: clips the model at a height and shows the cut faces red.
  It starts at the first pause, so magnet pockets are visible straight away.
- Orbit, pinch and pan on touch devices. Keys: `F` fit, `E` edges, `W` wireframe, `R` spin,
  `G` grid, `O` ortho, `M` modifiers, `P` pauses.
- Drag and drop any local `.stl` / `.3mf`.
- Fully offline: three.js r160 is vendored under `vendor/`.

| File | Purpose |
|---|---|
| `index.html` | Interactive page |
| `render.html` | Headless page driven by `tools/cloud/render.mjs` |
| `lib/loaders.js` | STL + 3MF (core + production extension, Bambu metadata) parsing; zip via `DecompressionStream` |
| `lib/viewer.js` | Scene, cameras (persp + fitted ortho), section clipping, stats, snapshots |
| `serve.mjs` | Zero-dependency server (`tools/view`), live `/__manifest` |
| `generate-manifest.mjs` | Writes a static `manifest.json` for other static hosts |
| `build-standalone.mjs` | Builds a single-file HTML with one STL embedded (opens from `file://`, iOS Quick Look) |
