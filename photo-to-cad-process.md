# Photo-to-CAD: 2D-first pipeline for modeling objects from photographs

General process for replicating a physical object from photos, designed for
agent-driven execution with cheap human gates. Written after three 3D-first
attempts at replicating one part from photos failed.

## Principles

1. **SVG in millimeters is the lingua franca.** Every artifact is an SVG with
   viewBox in mm: photo embedded as ghosted layer, traced paths on top, dimension
   callouts auto-generated from the paths, human feedback drawn on a `feedback`
   layer in the same frame. One file is simultaneously tracing canvas, review
   surface, database, 1:1 print master, and 3D-verification target
   (trimesh.section() slices land in the same frame as another layer).
2. **Every interpretation becomes a visible 2D claim on its evidence.** Agent
   vision errors are interpretation errors; they die when the interpretation is
   drawn over the photo in mm, and survive when it lives in loft code.
3. **Evidence tags, color-coded:** MEASURED (from calibrated mask) / DERIVED
   (computed) / GUESSED (assumed). Scrutiny goes where the dashes are.
4. **3D is compiled, not designed.** By the time anything lofts, there are no
   free shape parameters — only approved 2D inputs.
5. **Self-assessment = round-tripping.** Each representation must regenerate its
   upstream; the diff is the error metric. Known-object probes (bottle, bolt,
   coin drawn in every artifact) catch calibration drift.
6. **Humans review flat, cheap artifacts** (SVG in browser, 1:1 paper + real
   object, contact sheets, turntable GIF) and only after machine checks pass.
   ArUco fiducials on printed sheets let a phone photo of pen markups
   re-register into the mm frame.

## Stages

| # | Stage | Output artifact | Machine self-check | Human gate |
|---|-------|-----------------|--------------------|------------|
| 0 | Calibrate | per-photo calib sheet (mask, scale bar, anchors) | >=2 independent scale anchors agree <=5%; else photo demoted to vibe-reference | glance: right object, right scale? |
| 1 | Primary profiles | profile_<view>.svg (side/front/top), auto-dimensioned, evidence-tagged | trace-vs-mask deviation (mm); cross-view consistency of shared dims | Gate A: 1:1 paper print + real object laid on it; pen/SVG corrections |
| 2 | Station plan | stations.svg contact sheet: N authored cross-sections + spine keymap | 2D visual-hull test (every station projects inside every silhouette); smooth area/centroid curves | Gate B: annotate sections while still flat |
| 2.5 | Feature decomposition & primitive recipe | recipe sheet: silhouette segmented into named features; every edge tagged `surface` or `open-rim`; body profile refit as sparse continuous curves; declarative build recipe (ops list) | unmodeled-feature detector (contiguous raw-vs-fit deviation must be classified, never silently baked in); curvature-jump detector on fitted curves (no G1 breaks except at tagged feature boundaries); fit residual vs trace | Gate B': review the recipe + edge tags, not the mesh — mark open rims, reassign features |
| 3 | Loft | mesh compiled FROM the recipe (fitted curves -> sections; features as separate ops), <5 s regen | slice-back (mesh cut at each station vs authored, Hausdorff mm); silhouette-back (projection vs profiles, IoU + mm heatmap); watertight/component/wall checks | Gate C: turntable GIF + overlay sheet; form only |
| 4 | Interfaces | parametric features cut into frozen shell | thread/bore dims from measured hardware, never photos | coupon prints before long prints |
| 5 | Physical | draft print (0.3 mm, 2 perim) then final | photo of print in reference pose -> same overlay metric | fit/feel checks the screen can't show |

## Tooling

- python3.9: OpenCV (segment/rectify), svgpathtools + shapely (SVG as geometry),
  trimesh (+ manifold3d if installed) for loft/slice/boolean.
- OpenSCAD/BOSL2 only where it excels: threads, knurls, hardware couplings —
  exported as cutter STLs for boolean recut.
- Pipeline shape: pipeline/{segment,calibrate,trace,stations,build,compare}.py,
  artifacts into gates/; one command per gate.

## v1.1 amendments (from a clean-room pilot run)

The process was piloted end-to-end (Stages 0-2) by a context-free agent; these
fixes come from its friction report:

1. **Scale grades need a middle tier.** Found photos rarely contain 2 clean
   anchors; the binary >=2-anchors-or-vibe rule stalls the pipeline. New tier:
   **DERIVED-scale (single-anchor, +/-X% propagated)** — usable, but every
   downstream dimension carries the +/-X% band explicitly until one real caliper
   measurement collapses it to MEASURED-scaled.
2. **Single-silhouette path.** When the source lacks orthogonal views, proceed
   with proportion-locked shape from the one good silhouette; the artifact MUST
   mark unconstrained axes as such (the visual-hull check only constrains axes
   for which a silhouette exists — with one view it is one-axis, not pass/fail).
3. **Bent-axis / open-mouth objects:** a swept centerline mis-fits them. Use a
   hand-authored bent spine with perpendicular station cuts, and author the open
   mouth as a separate rim-outline artifact, not a station.
4. **Emit SVG and PNG from ONE mm-space scene object** (single source of truth)
   instead of rendering SVG->PNG with an external tool — nothing to install and
   the two views cannot drift.
5. **Resolution adequacy is a Stage-0 check:** record mm-per-pixel; if edge noise
   (+/-2-3 px) exceeds the target tolerance on small features, say so in the
   calibration sheet — method cannot beat source resolution.
6. **Physical-anchor escape hatch:** one caliper measurement of the real object
   (or a purchased/borrowed example) upgrades the whole model's scale grade;
   prefer acquiring one real dimension over squeezing more out of pixels.

## v1.2 amendments (from Gate C review of the pilot's Stage-3 loft)

7. **Stage 2.5 is mandatory before any loft** (see table). Root causes it fixes,
   observed in practice: an appendage (pivot boss) leaked into the body profile
   and swept into a full-width ridge; an open raked mouth was sealed into a
   solid ceiling; raw column data drove the surface and printed its noise.
8. **Silhouette IoU validates outline, never topology.** A mesh can score 0.97
   while closing a real opening. Openness is human knowledge: every silhouette
   edge must carry a `surface` / `open-rim` tag from Gate B' before lofting.
9. **Primitives live in profile space for organic bodies.** Do not force
   box/cone/cylinder decompositions onto sculpted forms; the reviewable
   "simple" representation is a handful of few-knot tangency-continuous curves
   plus a declarative op list (sweep, cut, add-boss, texture). Solid primitives
   are for the features, not the body.
10. **Smoothing is not the fix for wiggles — classification is.** Deviations
    from a smooth fit are (a) noise -> smooth, (b) separate features -> excise
    and model as ops, or (c) real texture -> defer to a texture stage. The
    unmodeled-feature detector forces the choice explicitly.

## v1.3 amendments (from the Stage 2.5 pilot rebuild)

11. **De-feature and fit PER EDGE, not per profile.** A body silhouette has
    independent edges (top/bottom) with different tags and different features;
    a single depth/center curve conflates them.
12. **Separate parts evade the residual detector.** A part floating off the body
    (gap between mask runs) is invisible to raw-vs-fit deviation on one edge;
    the machine-check spec includes a run-count / connected-component scan.
13. **The section family must ADMIT the open-rim tag** (construction-side twin
    of "IoU validates outline, not topology"). An oval section pinches to a
    point and cannot be opened along its top without eating the skin; an
    openable rim needs a section with a flat/full-width top there. Choose the
    section family from the topology tags first, silhouette fit second.
14. **Flag features whose attachment is unconstrained by the silhouette.** If a
    re-added feature has no evidenced attachment (e.g. a lateral pivot on an
    open rim), the recipe must mark it ATTACHMENT-UNKNOWN and route it to the
    human gate rather than inventing geometry that appears in no photo.
15. The curvature-jump check is a "did the fit add a kink" guard only; real
    corners live between curves at tagged boundaries, and it will not find them.

## v2.0 — The object contract (success criteria, not failure catalogs)

Declared at Stage 1 from the brief + photos, ratified by the human at Gate A,
verified at every stage after. A small vocabulary of functional predicates, each
with a purely geometric/visual verification — no physics engine, no history of
past bugs. New projects declare their own contract from the same vocabulary.

| predicate | meaning | geometric verification |
|---|---|---|
| CHANNELS(fluid, A->B) | flow path from aperture A to B | voxel flood-fill of interior void from A must reach B |
| SEALED(except apertures) | no unintended leaks | same flood-fill must NOT escape through any undeclared boundary |
| ADMITS(counterpart, via A) | counterpart inserts | swept-volume collision test along entry path, clearance >= g; sweep volume becomes a KEEP-OUT the recipe reserves |
| HOLDS(counterpart, pose) | stays put hands-free | translate-until-touch settles into contact; lateral movement bounded by contact normals |
| MOUNTS-ON(support) | carried by support | unbroken contact chain object->support in mounted pose |
| ARTICULATES(part, axis, range) | moving part | colinear bores; swing sweep collision-free over range |
| FASTENS(part, feature) | mate engages | coaxial mating features, engagement length > 0 |
| APPEARS-AS(photo set) | looks like the object | canonical view battery render-vs-photo diff, written as claims (VISUAL_DIFF) |
| MIN-STRUCTURE | printable strength | wall >= t, feature sections >= s (lookup minimums, not analysis) |
| NO-ORPHANS | no invented geometry | every feature traces to a predicate it serves; untraceable features escalate to the human |

Counterparts (bottle, tube, cap, bolt...) are modeled as trivial solids with
poses derived from the photos; they are contract INPUTS, part of the recipe.
Contract checks run as early as each stage allows: symbolically on the recipe
(apertures declared? keep-outs reserved? features traced?), then on the mesh.

### v2.1 amendments (from the first critic round)

- **Deferred predicates must reserve + validate their geometry now.** "Bore is
  Stage 4" is acceptable only with a keep-in corridor (e.g. the Ø24 bore path
  from tip to cup floor) proven to fit inside the present solid without wall
  break-out. A deferral without reserved geometry is a hiding place.
- **No check may hardcode PASS**, and checker thresholds must equal the
  contract's numbers (a 2.0mm gate does not verify a 2.4mm wall promise).
- **Builder/critic metric disagreements are findings** to reconcile (same
  inputs, same pose, same exclusions), never for the orchestrator to pick a
  winner by eye.
- **Never trust euler_number/genus on boolean outputs** — verify topology by
  section + flood-fill (boolean artifacts routinely corrupt the euler count).

## v2.0 — Execution model: builder/critic loop per stage

- **Builder** sub-agent executes the stage and runs its own machine checks.
- **Critic** sub-agent — fresh context, does NOT see the builder's reasoning —
  receives: the contract, the stage spec, the artifacts, reference photos. It
  re-renders the canonical view battery itself, verifies the applicable contract
  predicates, and writes a verdict: PASS / REVISE (findings tied to predicates)
  / ESCALATE (ambiguity, contract gap, unconstrained attachment).
- Builder and critic iterate (cap ~3 rounds) until PASS or ESCALATE. A phase
  may not begin until the previous phase PASSED.
- Human gates remain, but now receive pre-passed work + the critic's report;
  the human reviews escalations and taste, not regressions.
- The orchestrating agent holds the contract, spawns the pairs, and owns
  escalations. Critic independence is the point: the builder's own metrics
  once scored 0.97 on a topologically wrong mesh.

## Failure modes this prevents (learned the hard way)

- Eyeballed dimensions from perspective photos (no anchor agreement check).
- Render-vs-photo comparison from memory (no overlay, no metric).
- Shape encoded as interacting loft parameters no one can steer ("the curve is
  wrong HERE" has no corresponding knob).
- Orientation-class misreadings surviving multiple iterations (no station-plan
  gate with known-object overlays).
- Expensive artifact first: 1-2 min blind renders as the iteration loop.
