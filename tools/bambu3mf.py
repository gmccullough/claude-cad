"""Build Bambu Studio .3mf project files from STLs plus a settings profile.

A Bambu .3mf is just a ZIP of OPC parts. This writes the ones that matter and
leaves the rest to the slicer:

    [Content_Types].xml               OPC boilerplate
    _rels/.rels                       points at the root model
    3D/3dmodel.model                  build items: which object, placed where
    3D/_rels/3dmodel.model.rels       points at each object mesh
    3D/Objects/object_N.model         the mesh, indexed verts + triangles
    Metadata/project_settings.config  JSON, every print/filament/printer key
    Metadata/model_settings.config    per-object name / transform / plate
    Metadata/custom_gcode_per_layer.xml   pauses and colour changes
    Metadata/slice_info.config        client header

Thumbnails are omitted; Bambu regenerates them on open.

Stdlib only. STL reading handles both ASCII and binary and welds duplicate
vertices, which 3MF wants and STL does not give you.
"""

from __future__ import annotations

import json
import struct
import zipfile
from pathlib import Path
from xml.sax.saxutils import escape

CORE_NS = "http://schemas.microsoft.com/3dmanufacturing/core/2015/02"
BBL_NS = "http://schemas.bambulab.com/package/2021"
PROD_NS = "http://schemas.microsoft.com/3dmanufacturing/production/2015/06"

# Bambu writes UUIDs in a fixed shape; mirror it so ids stay stable per build.
def _uuid(prefix: int, tag: str) -> str:
    h = f"{abs(hash((prefix, tag))) & 0xFFFFFFFFFFFF:012x}"
    return f"{prefix:08x}-{h[:4]}-4{h[4:7]}-9{h[7:10]}-{h[:12]}"


# --------------------------------------------------------------------------
# STL
# --------------------------------------------------------------------------

def read_stl(path) -> tuple[list[tuple[float, float, float]], list[tuple[int, int, int]]]:
    """Return (vertices, triangles) with duplicate vertices welded."""
    raw = Path(path).read_bytes()
    tris_xyz: list[tuple] = []

    if raw[:5] == b"solid" and b"facet" in raw[:2048]:
        nums: list[float] = []
        for line in raw.decode("utf-8", "replace").splitlines():
            line = line.strip()
            if line.startswith("vertex "):
                nums.extend(float(v) for v in line.split()[1:4])
        for i in range(0, len(nums), 9):
            tris_xyz.append(tuple(nums[i:i + 9]))
    else:
        (count,) = struct.unpack("<I", raw[80:84])
        off = 84
        for _ in range(count):
            vals = struct.unpack("<12fH", raw[off:off + 50])
            tris_xyz.append(vals[3:12])
            off += 50

    index: dict[tuple, int] = {}
    verts: list[tuple[float, float, float]] = []
    faces: list[tuple[int, int, int]] = []
    for t in tris_xyz:
        idx = []
        for j in range(3):
            # round to 1nm so float noise does not defeat welding
            key = (round(t[j * 3], 6), round(t[j * 3 + 1], 6), round(t[j * 3 + 2], 6))
            got = index.get(key)
            if got is None:
                got = len(verts)
                index[key] = got
                verts.append(key)
            idx.append(got)
        if idx[0] != idx[1] and idx[1] != idx[2] and idx[0] != idx[2]:
            faces.append(tuple(idx))
    return verts, faces


def cylinder_mesh(d: float, h: float, segments: int = 48):
    """Closed cylinder, base at z=0, centred on the origin in X/Y."""
    import math
    r = d / 2.0
    verts = [(0.0, 0.0, 0.0), (0.0, 0.0, h)]          # 0 = bottom hub, 1 = top hub
    for i in range(segments):
        a = 2 * math.pi * i / segments
        verts.append((r * math.cos(a), r * math.sin(a), 0.0))
        verts.append((r * math.cos(a), r * math.sin(a), h))
    faces = []
    for i in range(segments):
        b0, t0 = 2 + 2 * i, 3 + 2 * i
        b1, t1 = 2 + 2 * ((i + 1) % segments), 3 + 2 * ((i + 1) % segments)
        faces += [(0, b1, b0), (1, t0, t1), (b0, b1, t1), (b0, t1, t0)]
    return verts, faces


def bounds(verts):
    xs, ys, zs = zip(*verts)
    return (min(xs), min(ys), min(zs)), (max(xs), max(ys), max(zs))


# --------------------------------------------------------------------------
# XML parts
# --------------------------------------------------------------------------

_HEAD = (
    '<?xml version="1.0" encoding="UTF-8"?>\n'
    f'<model unit="millimeter" xml:lang="en-US" xmlns="{CORE_NS}" '
    f'xmlns:BambuStudio="{BBL_NS}" xmlns:p="{PROD_NS}" requiredextensions="p">\n'
)


def _mesh_object_xml(verts, faces, inner_id: int, kind: str) -> str:
    out = [f'  <object id="{inner_id}" p:UUID="{_uuid(inner_id, "obj")}" type="{kind}">\n',
           '   <mesh>\n    <vertices>\n']
    out += [f'     <vertex x="{x:.6g}" y="{y:.6g}" z="{z:.6g}"/>\n' for x, y, z in verts]
    out.append('    </vertices>\n    <triangles>\n')
    out += [f'     <triangle v1="{a}" v2="{b}" v3="{c}"/>\n' for a, b, c in faces]
    out.append('    </triangles>\n   </mesh>\n  </object>\n')
    return "".join(out)


def object_model_xml(verts, faces, inner_id: int, helpers=()) -> str:
    # inner_id MUST be unique across the whole package. Bambu resolves a
    # component by its objectid, so two mesh files both declaring id="1"
    # makes the second silently render as the first, and both plates come
    # out identical.
    # The plate is type="model"; helper volumes (enforcers, modifiers) ride in
    # the SAME file as type="other" objects and are referenced by extra
    # components from the root. That is exactly how Bambu writes them.
    out = [_HEAD,
           ' <metadata name="BambuStudio:3mfVersion">1</metadata>\n',
           ' <resources>\n',
           _mesh_object_xml(verts, faces, inner_id, "model")]
    for h in helpers:
        out.append(_mesh_object_xml(h["verts"], h["faces"], h["inner_id"], "other"))
    out.append(' </resources>\n <build/>\n</model>\n')
    return "".join(out)


def root_model_xml(parts, app: str) -> str:
    out = [_HEAD]
    for k, v in (("Application", app), ("BambuStudio:3mfVersion", "1"),
                 ("Copyright", ""), ("CreationDate", ""), ("Description", ""),
                 ("Designer", ""), ("License", ""), ("ModificationDate", ""),
                 ("Origin", ""), ("Title", "")):
        out.append(f' <metadata name="{k}">{escape(v)}</metadata>\n')
    out.append(' <resources>\n')
    for p in parts:
        oid = p["object_id"]
        out.append(f'  <object id="{oid}" p:UUID="{_uuid(oid, "o")}" type="model">\n'
                   '   <components>\n'
                   f'    <component p:path="/3D/Objects/object_{oid}.model" objectid="{p["inner_id"]}" '
                   f'p:UUID="{_uuid(oid, "c")}" transform="1 0 0 0 1 0 0 0 1 0 0 0"/>\n')
        for j, h in enumerate(p.get("helpers", [])):
            hx, hy, hz = h["at"]
            out.append(f'    <component p:path="/3D/Objects/object_{oid}.model" '
                       f'objectid="{h["inner_id"]}" p:UUID="{_uuid(oid, f"h{j}")}" '
                       f'transform="1 0 0 0 1 0 0 0 1 {hx:.6g} {hy:.6g} {hz:.6g}"/>\n')
        out.append('   </components>\n  </object>\n')
    out.append(f' </resources>\n <build p:UUID="{_uuid(0, "build")}">\n')
    for p in parts:
        oid = p["object_id"]
        tx, ty, tz = p["translate"]
        out.append(f'  <item objectid="{oid}" p:UUID="{_uuid(oid, "i")}" '
                   f'transform="1 0 0 0 1 0 0 0 1 {tx:.6g} {ty:.6g} {tz:.6g}" printable="1"/>\n')
    out.append(' </build>\n</model>\n')
    return "".join(out)


def model_settings_xml(parts) -> str:
    out = ['<?xml version="1.0" encoding="UTF-8"?>\n<config>\n']
    for p in parts:
        oid, name = p["object_id"], escape(p["name"])
        out.append(f'  <object id="{oid}">\n'
                   f'    <metadata key="name" value="{name}"/>\n'
                   '    <metadata key="extruder" value="1"/>\n')
        # per-object overrides (Bambu's "object settings"), e.g. a brim on one part
        for sk, sv in (p.get("settings") or {}).items():
            out.append(f'    <metadata key="{escape(sk)}" value="{escape(str(sv))}"/>\n')
        out.append(f'    <part id="{p["inner_id"]}" subtype="normal_part">\n'
                   f'      <metadata key="name" value="{name}"/>\n'
                   '      <metadata key="matrix" value="1 0 0 0 0 1 0 0 0 0 1 0 0 0 0 1"/>\n'
                   f'      <metadata key="source_file" value="{name}"/>\n'
                   '      <metadata key="source_object_id" value="0"/>\n'
                   '      <metadata key="source_volume_id" value="0"/>\n'
                   f'      <mesh_stat face_count="{p["face_count"]}" edges_fixed="0" '
                   'degenerate_facets="0" facets_removed="0" facets_reversed="0" '
                   'backwards_edges="0"/>\n    </part>\n')
        for j, h in enumerate(p.get("helpers", [])):
            hx, hy, hz = h["at"]
            out.append(f'    <part id="{h["inner_id"]}" subtype="{h["subtype"]}">\n'
                       f'      <metadata key="name" value="{escape(h.get("name", "enforcer"))}"/>\n'
                       '      <metadata key="matrix" value="'
                       f'1 0 0 {hx:.10g} 0 1 0 {hy:.10g} 0 0 1 {hz:.10g} 0 0 0 1"/>\n'
                       '      <metadata key="extruder" value="0"/>\n')
            for sk, sv in (h.get("settings") or {}).items():
                out.append(f'      <metadata key="{escape(sk)}" value="{escape(str(sv))}"/>\n')
            out.append(
                       f'      <mesh_stat face_count="{len(h["faces"])}" edges_fixed="0" '
                       'degenerate_facets="0" facets_removed="0" facets_reversed="0" '
                       'backwards_edges="0"/>\n    </part>\n')
        out.append('  </object>\n')
    out.append('  <plate>\n    <metadata key="plater_id" value="1"/>\n'
               '    <metadata key="plater_name" value=""/>\n'
               '    <metadata key="locked" value="false"/>\n')
    for p in parts:
        out.append(f'    <model_instance>\n'
                   f'      <metadata key="object_id" value="{p["object_id"]}"/>\n'
                   '      <metadata key="instance_id" value="0"/>\n'
                   '      <metadata key="identify_id" value="'
                   f'{100 + p["object_id"]}"/>\n    </model_instance>\n')
    out.append('  </plate>\n</config>\n')
    return "".join(out)


def custom_gcode_xml(pauses) -> str:
    """pauses: iterable of (top_z, gcode). M400 U1 is Bambu's pause.

    Bambu runs the gcode BEFORE it prints the layer whose top is top_z, so the print is one
    layer short of top_z when it stops. To stop with a pocket complete to height h, pass
    h + layer_height."""
    out = ['<?xml version="1.0" encoding="utf-8"?>\n<custom_gcodes_per_layer>\n'
           '<plate>\n<plate_info id="1"/>\n']
    for top_z, gcode in pauses:
        out.append(f'<layer top_z="{top_z:.10g}" type="1" extruder="1" color="" '
                   f'extra="" gcode="{escape(gcode, {chr(34): "&quot;"})}"/>\n')
    out.append('<mode value="SingleExtruder"/>\n</plate>\n</custom_gcodes_per_layer>\n')
    return "".join(out)


CONTENT_TYPES = ('<?xml version="1.0" encoding="UTF-8"?>\n'
                 '<Types xmlns="http://schemas.openxmlformats.org/package/2006/content-types">\n'
                 ' <Default Extension="rels" ContentType="application/vnd.openxmlformats-package.relationships+xml"/>\n'
                 ' <Default Extension="model" ContentType="application/vnd.ms-package.3dmanufacturing-3dmodel+xml"/>\n'
                 ' <Default Extension="png" ContentType="image/png"/>\n'
                 ' <Default Extension="gcode" ContentType="text/x.gcode"/>\n'
                 '</Types>\n')

SLICE_INFO = ('<?xml version="1.0" encoding="UTF-8"?>\n<config>\n  <header>\n'
              '    <header_item key="X-BBL-Client-Type" value="slicer"/>\n'
              '    <header_item key="X-BBL-Client-Version" value="02.05.00.66"/>\n'
              '  </header>\n</config>\n')


# --------------------------------------------------------------------------
# Build
# --------------------------------------------------------------------------

def build(out_path, stls, profile, overrides=None, pauses=(), volumes=(),
          bed_center=(128.0, 128.0), spacing=6.0,
          app="BambuStudio-02.05.00.66", places=None, object_settings=None):
    """Write a .3mf.

    stls      : list of STL paths, one object each, laid out along X
    profile   : path to a base project_settings.config (JSON)
    overrides : dict merged over the profile
    pauses    : iterable of (top_z_mm, gcode)
    places    : optional list of (x, y) bed positions, one per STL: each
                object's bounding-box centre goes there instead of the X row.
                Raises if any object would leave the printable area.
    object_settings : optional {stl index: {key: value}} per-object overrides,
                written into model_settings.config (e.g. a brim on one part only).
    """
    settings = json.loads(Path(profile).read_text())
    # Bambu's project_settings.config is ALL strings ("2", "0.2", "15%"). An int
    # or float here is silently ignored and the stock default is used instead -
    # that is how wall_loops=3 came out of the slicer as 2. Coerce to str, and
    # refuse unknown keys so a typo fails loudly instead of doing nothing.
    for k, v in (overrides or {}).items():
        if k not in settings:
            raise KeyError(f"unknown setting {k!r}: not present in the base profile")
        if isinstance(settings[k], list):
            settings[k] = [str(x) for x in (v if isinstance(v, list) else [v])]
        else:
            settings[k] = str(v)

    # ...and writing the value is only half the job. Bambu does not read these
    # as-is: it loads the named SYSTEM preset (print_settings_id etc.) and then
    # applies ONLY the keys named in different_settings_to_system, resetting
    # every other key to the preset's own value. A key changed above but absent
    # from that list is silently reverted -- which is exactly why wall_loops=3
    # kept coming back as 2 in the slicer while enable_support=0 worked (it
    # happened to already be in the list). The field is three ";"-joined
    # buckets: [print, filament, printer].
    diffs = settings.get("different_settings_to_system")
    if not isinstance(diffs, list) or len(diffs) < 3:
        diffs = ["", "", ""]
    buckets = [set(x.split(";")) - {""} for x in diffs[:3]]
    for k in (overrides or {}):
        if k.startswith("filament_"):
            buckets[1].add(k)
        elif k.startswith(("printer_", "machine_")):
            buckets[2].add(k)
        else:
            buckets[0].add(k)
    settings["different_settings_to_system"] = [";".join(sorted(b)) for b in buckets]

    # volumes: helper cylinders welded into an object as extra parts.
    #   {object: index into stls, d, h, x, y, z,
    #    subtype: "support_enforcer" | "support_blocker" | "modifier_part"
    #             | "negative_part",
    #    settings: {...}}   settings only mean anything for modifier_part
    by_obj = {}
    for e in volumes:
        by_obj.setdefault(e.get("object", 0), []).append(e)

    parts, meshes = [], []
    widths = []
    for path in stls:
        verts, faces = read_stl(path)
        lo, hi = bounds(verts)
        widths.append(hi[0] - lo[0])
        meshes.append((verts, faces, lo, hi))

    total = sum(widths) + spacing * (len(widths) - 1)
    cursor = bed_center[0] - total / 2.0
    for i, ((verts, faces, lo, hi), path) in enumerate(zip(meshes, stls)):
        parts.append({
            "object_id": i + 2,          # Bambu starts object ids at 2
            "inner_id": 1000 + i,        # unique across the package
            "helpers": [
                {"inner_id": 2000 + i * 20 + j,
                 "verts": cylinder_mesh(e["d"], e["h"])[0],
                 "faces": cylinder_mesh(e["d"], e["h"])[1],
                 "at": (e.get("x", 0.0), e.get("y", 0.0), e.get("z", 0.0)),
                 "subtype": e.get("subtype", "support_enforcer"),
                 "settings": e.get("settings"),
                 "name": e.get("name", "enforcer")}
                for j, e in enumerate(by_obj.get(i, []))
            ],
            "name": Path(path).name,
            "face_count": len(faces),
            "settings": {k: str(v) for k, v in (object_settings or {}).get(i, {}).items()},
            # translate so the part sits on the bed and lands where we want in X/Y
            "translate": (cursor - lo[0],
                          bed_center[1] - (lo[1] + hi[1]) / 2.0,
                          -lo[2]),
        })
        cursor += widths[i] + spacing

    if places is not None:
        if len(places) != len(stls):
            raise ValueError("places needs one (x, y) per STL")
        area = [tuple(float(v) for v in p.split("x")) for p in settings.get("printable_area", [])]
        bx = [a[0] for a in area] or [0.0, 2 * bed_center[0]]
        by = [a[1] for a in area] or [0.0, 2 * bed_center[1]]
        for p, (verts, faces, lo, hi), (cx, cy), path in zip(parts, meshes, places, stls):
            p["translate"] = (cx - (lo[0] + hi[0]) / 2.0, cy - (lo[1] + hi[1]) / 2.0, -lo[2])
            x0, x1 = cx - (hi[0] - lo[0]) / 2.0, cx + (hi[0] - lo[0]) / 2.0
            y0, y1 = cy - (hi[1] - lo[1]) / 2.0, cy + (hi[1] - lo[1]) / 2.0
            if x0 < min(bx) or x1 > max(bx) or y0 < min(by) or y1 > max(by):
                raise ValueError(f"{Path(path).name} at ({cx}, {cy}) spans x {x0:.1f}..{x1:.1f}, "
                                 f"y {y0:.1f}..{y1:.1f}: outside the printable area")

    rels = ['<?xml version="1.0" encoding="UTF-8"?>\n'
            '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n']
    for i, p in enumerate(parts):
        rels.append(f' <Relationship Target="/3D/Objects/object_{p["object_id"]}.model" '
                    f'Id="rel-{i + 1}" Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>\n')
    rels.append('</Relationships>\n')

    out_path = Path(out_path)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with zipfile.ZipFile(out_path, "w", zipfile.ZIP_DEFLATED, compresslevel=6) as z:
        z.writestr("[Content_Types].xml", CONTENT_TYPES)   # must come first
        z.writestr("_rels/.rels",
                   '<?xml version="1.0" encoding="UTF-8"?>\n'
                   '<Relationships xmlns="http://schemas.openxmlformats.org/package/2006/relationships">\n'
                   ' <Relationship Target="/3D/3dmodel.model" Id="rel-1" '
                   'Type="http://schemas.microsoft.com/3dmanufacturing/2013/01/3dmodel"/>\n'
                   '</Relationships>\n')
        z.writestr("3D/3dmodel.model", root_model_xml(parts, app))
        z.writestr("3D/_rels/3dmodel.model.rels", "".join(rels))
        for p, (verts, faces, _, _) in zip(parts, meshes):
            z.writestr(f'3D/Objects/object_{p["object_id"]}.model',
                       object_model_xml(verts, faces, p["inner_id"], p["helpers"]))
        z.writestr("Metadata/project_settings.config",
                   json.dumps(settings, indent=4, sort_keys=True))
        z.writestr("Metadata/model_settings.config", model_settings_xml(parts))
        if pauses:
            z.writestr("Metadata/custom_gcode_per_layer.xml", custom_gcode_xml(pauses))
        z.writestr("Metadata/slice_info.config", SLICE_INFO)
    return out_path, parts, settings
