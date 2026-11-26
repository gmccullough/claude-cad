# Photo-to-CAD: a 2D-first process for modelling an object from photographs

For replicating an organic or multi-feature object when photos are the main evidence. A part
with a handful of dimensions doesn't need this: the "Measuring from photos" practice in
[AGENTS.md](AGENTS.md) is enough.

It exists because three attempts at modelling one part directly in 3D failed. Every failure was
a misreading of the photos that stayed hidden inside loft code, and would have been obvious as
a line drawn over the photo.

## Principles

1. **One shared artifact: an SVG in millimetres.** The photo sits ghosted underneath, traced
   paths on top, dimensions generated from the paths, and the person's corrections on a
   `feedback` layer in the same frame. Sections cut from the mesh later land in that frame too,
   so the same file is tracing canvas, review sheet, 1:1 print master and 3D check target.
2. **Every interpretation becomes a visible 2D claim drawn on its evidence**, before any 3D.
3. **Tag the evidence:** MEASURED (from a calibrated trace), DERIVED (computed) or GUESSED
   (assumed), colour-coded. Review effort goes to the guesses.
4. **3D is compiled, not designed.** By the time anything lofts there are no free shape
   parameters left, only approved 2D inputs.
5. **Check by round trip.** Each representation regenerates the one before it, and the
   difference is the error. Draw a known object (bolt, coin, bottle) into every artifact to
   catch scale drift.
6. **People review flat, cheap artifacts** (an SVG in a browser, a 1:1 paper print laid under
   the real object, a contact sheet, a turntable GIF), and only after the machine checks pass.

## Scale grades (set in stage 0, carried on every dimension)

| Grade | Requires | Use |
|---|---|---|
| MEASURED scale | two independent anchors in the photo that agree within 5% | dimensions as read |
| DERIVED scale | one anchor | usable, but every downstream dimension carries the ±X% band |
| Reference only | no trustworthy anchor | topology and proportion, never size |

One caliper measurement of the real object, or of a bought or borrowed example, lifts the whole
model to MEASURED. Prefer getting one real dimension over squeezing more out of pixels. Record
mm per pixel as well: if edge noise of 2 to 3 px is larger than a small feature's tolerance,
say so, because the method can't beat the source resolution.

## Stages

Each stage has an output, checks the agent runs itself, and a review by the person. A stage
doesn't start until the one before it has passed.

**0. Calibrate.** A calibration sheet per photo: mask, scale bar, anchors, scale grade.
The person glances at it: right object, right scale?

**1. Primary profiles.** `profile_<view>.svg` for side, front and top, dimensioned and
evidence-tagged. Checks: deviation of the trace from the mask in mm, and agreement between
views on the dimensions they share. With only one good silhouette, go ahead with the shape
locked in proportion and mark the axes it doesn't constrain as unconstrained. Declare the
object contract here (below). **Gate A:** a 1:1 paper print with the real object laid on it;
corrections in pen or on the SVG. Fiducial markers printed on the sheet let a phone photo of
the pen marks be registered back into the mm frame.

**2. Station plan.** `stations.svg`: the cross-sections along a spine, with a key map. Checks:
every station fits inside every silhouette that exists for its axis, and area and centroid run
smoothly along the spine. For a bent object, draw the bent spine by hand and cut stations
perpendicular to it. An open mouth is its own rim outline, not a station. **Gate B:** the
person marks up the sections while they're still flat.

**2.5. Features and recipe (required before any loft).** Split the silhouette into named
features and tag every edge `surface` or `open-rim`. Fit the body one edge at a time (top and
bottom have different features) as a few tangent-continuous curves, and write a declarative
build recipe: sweep, cut, add boss, texture. Solid primitives are for the features; a sculpted
body is described by its curves, not forced into boxes and cones. Checks:
- Every stretch where the raw trace departs from the fit gets classified: noise (smooth it), a
  separate feature (cut it out and model it as its own op) or real texture (defer it).
  Smoothing is never the answer to an unclassified wiggle.
- A connected-component scan of the mask, because a part floating off the body doesn't show
  up as a deviation along one edge.
- The fit added no kinks. Real corners sit between curves at tagged boundaries.
- The section family can express the tags: an oval pinches to a point and can't be opened
  along its top, so an open rim needs a section with a flat, full-width top. Choose the
  section family from the topology first and the silhouette fit second.
- A feature whose attachment no photo shows is marked ATTACHMENT-UNKNOWN and goes to the
  person. Don't invent geometry that appears in no photo.

**Gate B′:** the person reviews the recipe and the edge tags, not a mesh.

**3. Loft.** The mesh is compiled from the recipe and regenerates in seconds. Checks: slice the
mesh at each station and compare with the drawn one (Hausdorff distance in mm); project it and
compare with the profiles (IoU plus a deviation map in mm); watertight, one component, minimum
wall. **Gate C:** a turntable and overlay sheet, for form only.

**4. Interfaces.** Threads, bores and mating features are cut parametrically into the frozen
shell, sized from measured hardware and never from photos. Print a coupon before a long print.

**5. Physical.** A draft print (0.3 mm layers, 2 perimeters), then the final. Photograph the
print in the reference pose and run the same overlay metric. Fit and feel are checked here.

## The object contract

At stage 1, write down what the object has to do as a short list of predicates, each with a
purely geometric check. The person ratifies it at Gate A and it is checked at every stage
after: first on the recipe (are the apertures declared, the keep-outs reserved, every feature
traced to a purpose?), then on the mesh. Counterparts (the bottle, tube, cap or bolt it works
with) are modelled as simple solids posed from the photos and are inputs to the contract.

Draw on these, and add others the part needs:

| Predicate | Meaning | Geometric check |
|---|---|---|
| CHANNELS(A → B) | a flow path from aperture A to B | voxel flood fill of the interior void from A reaches B |
| SEALED | no leaks except the declared apertures | the same flood fill escapes through no other boundary |
| ADMITS(counterpart, via A) | the counterpart goes in | swept-volume collision test along the entry path with clearance; the sweep becomes a keep-out |
| HOLDS(counterpart, pose) | it stays put hands-free | translate until touching; contact normals bound sideways movement |
| MOUNTS-ON(support) | carried by its support | unbroken contact chain from object to support in the mounted pose |
| ARTICULATES(part, axis, range) | a moving part | colinear bores; the swing sweep is collision-free over the range |
| FASTENS(part, feature) | a mate engages | coaxial mating features with engagement length above zero |
| APPEARS-AS(photos) | it looks like the object | renders from a fixed set of views compared with the photos, differences written as claims |
| MIN-STRUCTURE | printable strength | walls and feature sections above lookup minimums |
| NO-ORPHANS | no invented geometry | every feature traces to a predicate; one that doesn't goes to the person |

Rules that keep the contract honest:
- **A deferred predicate reserves its geometry now.** "The bore is stage 4" is acceptable only
  with a keep-in corridor proven to fit inside the present solid without breaking a wall.
- **No check hardcodes a pass**, and a checker's threshold equals the contract's number. A
  2.0 mm gate doesn't verify a 2.4 mm wall promise.
- **Don't trust `euler_number` or genus on boolean output.** Booleans routinely corrupt the
  count. Verify topology by section and flood fill.

## Independent review

A silhouette match proves the outline and nothing about topology: the builder's own metrics
once scored 0.97 IoU on a mesh that had sealed a real opening shut. Whether an edge is open is
knowledge the person has, which is why the edge tags come from Gate B′ and not from the fit.

So before claiming a match (at Gate C at the latest, and at Gate B′ if the recipe is
contested), hand the work to one reviewer with a fresh context that has not seen the builder's
reasoning. Give it the contract, the stage's artifacts and the reference photos, including
photos that weren't used for fitting. It renders the comparison views itself, checks each
predicate that applies, and returns PASS, REVISE (findings tied to predicates) or ESCALATE (an
ambiguity, a gap in the contract, an unconstrained attachment). When its numbers disagree with
the builder's, that disagreement is a finding to reconcile on the same inputs, pose and
exclusions, not something to settle by eye. The person then reviews escalations and taste, not
regressions.

## Tooling

- Python does the 2D and mesh work: OpenCV to segment and rectify, shapely for geometry,
  trimesh and manifold3d to loft, slice and cut (`tools/cloud/need python` installs them).
  Emit the SVG and any PNG from one scene object in mm, so the two can't drift apart.
- OpenSCAD and BOSL2 where they are strongest: threads, knurls and hardware couplings, exported
  as cutter STLs.
- The kit ships no pipeline code, because the scripts are specific to each object. Keep one
  script per stage and one command per gate, with the artifacts in a `gates/` directory.
  [examples/roval-wahoo-mount/section/](examples/roval-wahoo-mount/section/) is a small working
  instance for a single cross-section: a trace from one photo, a second photo held out as a
  check, a contour gauge for the stretch the photo couldn't see, evidence tags per stretch, and
  a 2D gate against the model's own profile before anything was built in 3D.

## What this prevents

- Dimensions eyeballed from perspective photos, with no check that two anchors agree.
- Comparing a render with a photo from memory, with no overlay and no number.
- Shape encoded as interacting loft parameters that nobody can steer ("the curve is wrong
  here" has no knob).
- A misread orientation surviving several iterations because nothing flat was ever reviewed.
- A slow, expensive artifact as the iteration loop.

*History: this page folds in the amendments once listed as v1.1 to v1.3 (pilot run, Gate C
review, the stage 2.5 rebuild) and v2.0 to v2.1 (object contract, critic round). Stage numbers
and gate names are unchanged, so older project notes that cite them still apply; the originals
are in the git log.*
