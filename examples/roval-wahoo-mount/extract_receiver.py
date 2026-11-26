"""Cut the Wahoo quarter-turn receiver out of Wahoo's Bolt 2 cradle STL.

Output ref/wahoo_receiver.stl: ring centre at the origin, device seat at z=0,
cradle long axis (device long axis) along +X. roval_wahoo_mount.scad imports it.
"""
import sys, numpy as np, trimesh, manifold3d as m3d

SRC, DST = "ref/Mount_base-bolt2_v1.stl", "ref/wahoo_receiver.stl"
CTR = np.array([0.01, 35.05, -18.15])   # ring centre (fitted) and top face
R, DEPTH = 15.8, 5.6

mesh = max(trimesh.load(SRC).split(only_watertight=False), key=lambda b: len(b.faces))
assert mesh.is_watertight
mesh.apply_translation(-CTR)
mesh.apply_transform(trimesh.transformations.rotation_matrix(-np.pi / 2, [0, 0, 1]))
src = m3d.Manifold(m3d.Mesh(mesh.vertices.astype(np.float32), mesh.faces.astype(np.uint32)))
cyl = m3d.Manifold.cylinder(DEPTH + 0.01, R, R, 128).translate([0, 0, -DEPTH])
out = (src ^ cyl).to_mesh()
res = trimesh.Trimesh(out.vert_properties[:, :3], out.tri_verts)
print("receiver graft:", res.extents.round(2), "watertight", res.is_watertight, "vol", round(res.volume, 1))
res.export(DST)
