// Scene core shared by index.html (interactive) and render.html (headless).
//
//   const v = createViewer(containerEl, { preserveDrawingBuffer })
//   v.show(model)                 model from loaders.parseModel()
//   v.setView("iso"|"front"|...)  v.setOrtho(bool)  v.setScheme(name)
//   v.set({ edges, wireframe, helpers, pauses, modifiers, bed, rotate })
//   v.setSection("z", 2.4) / v.setSection(null)   cut away everything above
//   v.stats()                     { size, tris, volume, parts, pauses, ... }
//   v.snapshot({ view, ortho, w, h, azimuth }) -> PNG data URL (headless)
//
// Z-up, like OpenSCAD. The whole model is centred in XY and Z for orbiting;
// stats() reports the original coordinates.
import * as THREE from "three";
import { OrbitControls } from "three/addons/controls/OrbitControls.js";

export const SCHEMES = {
  cornfield: { bgTop: 0xfdfcdf, bgBot: 0xf4eeb6, model: 0xf9d72c, edge: 0x4d4422, grid: 0xcabf73 },
  tomorrow:  { bgTop: 0x2b303b, bgBot: 0x1d2026, model: 0xc7d0e0, edge: 0x10121a, grid: 0x3a414f },
  sunset:    { bgTop: 0x3a2740, bgBot: 0x20141f, model: 0xff9d5c, edge: 0x3a1f10, grid: 0x5a3a52 },
  metal:     { bgTop: 0x404652, bgBot: 0x21252c, model: 0xc9ccd1, edge: 0x15171b, grid: 0x4a515c },
  paper:     { bgTop: 0xffffff, bgBot: 0xeef0f3, model: 0x8fb3d9, edge: 0x1c2733, grid: 0xc5ccd6 },
};
// distinct tints for multi-object files (first one uses the scheme colour)
const PART_TINTS = [null, 0x8fd18a, 0xc69be0, 0xe0cf6f, 0x6fe0cf, 0xe06fa8, 0xa8a8a8, 0x6f8fe0];
const KIND_COLOR = { modifier_part: 0x3fa7ff, negative_part: 0xff4040, support_blocker: 0xff9f1a, support_enforcer: 0x2ecc71 };
const CUT_COLOR = 0xd0342c;
const DIRS = {
  iso: [1, -1, 0.8], iso2: [-1, -1, 0.8], iso_back: [-1, 1, 0.8], front: [0, -1, 0], back: [0, 1, 0],
  left: [-1, 0, 0], right: [1, 0, 0], top: [0, -1e-4, 1], bottom: [0, -1e-4, -1],   // nudged off the pole: up stays +Z
};
export const VIEWS = Object.keys(DIRS);

export function createViewer(container, opts = {}) {
  const renderer = new THREE.WebGLRenderer({ antialias: true, preserveDrawingBuffer: !!opts.preserveDrawingBuffer });
  renderer.setPixelRatio(opts.pixelRatio ?? Math.min(devicePixelRatio, 2));
  renderer.localClippingEnabled = true;
  container.appendChild(renderer.domElement);

  const scene = new THREE.Scene();
  const persp = new THREE.PerspectiveCamera(40, 1, 0.01, 100000);
  const ortho = new THREE.OrthographicCamera(-1, 1, 1, -1, 0.01, 100000);
  let camera = persp;
  // Z-up (OpenSCAD). OrbitControls reads camera.up once, in its constructor, to
  // build its orbit frame, so this must happen before the controls exist and
  // never change afterwards. Otherwise drags orbit about the wrong axis.
  persp.up.set(0, 0, 1); ortho.up.set(0, 0, 1);
  const controls = new OrbitControls(persp, renderer.domElement);
  controls.enableDamping = !opts.preserveDrawingBuffer;
  controls.dampingFactor = 0.08;
  controls.autoRotateSpeed = 2.0;

  const key = new THREE.DirectionalLight(0xffffff, 2.0);
  const fill = new THREE.DirectionalLight(0xffffff, 0.7);
  const back = new THREE.DirectionalLight(0xffffff, 0.5);
  scene.add(key, fill, back, new THREE.AmbientLight(0xffffff, 0.45));

  const bg = new THREE.Mesh(new THREE.PlaneGeometry(2, 2), new THREE.ShaderMaterial({
    uniforms: { top: { value: new THREE.Color() }, bot: { value: new THREE.Color() } },
    vertexShader: "varying vec2 vUv; void main(){ vUv = uv; gl_Position = vec4(position.xy, 1.0, 1.0); }",
    fragmentShader: "varying vec2 vUv; uniform vec3 top; uniform vec3 bot; void main(){ gl_FragColor = vec4(mix(bot, top, vUv.y), 1.0); }",
    depthWrite: false, depthTest: false,
  }));
  bg.frustumCulled = false; bg.renderOrder = -1;
  scene.add(bg);

  const root = new THREE.Group();      // recentred model + overlays
  const helpers = new THREE.Group();   // grid + axes
  const overlays = new THREE.Group();  // bed outline, pause planes
  scene.add(root, helpers);
  root.add(overlays);

  const clip = new THREE.Plane(new THREE.Vector3(0, 0, -1), 1e9);
  const state = { edges: false, wireframe: false, helpers: true, pauses: true, modifiers: true, bed: true, rotate: false };
  let scheme = "cornfield", view = "iso", useOrtho = false, section = null;
  let model = null, meshes = [], offset = new THREE.Vector3(), bbox = new THREE.Box3(), radius = 50, grid = null;

  function clear() {
    for (const m of meshes) { m.traverse(o => { o.geometry?.dispose(); o.material?.dispose?.(); }); root.remove(m); }
    meshes = [];
    overlays.clear();
  }

  function show(m) {
    clear();
    model = m;
    bbox = new THREE.Box3();
    const solid = m.parts.filter(p => p.kind === "normal");
    for (const p of (solid.length ? solid : m.parts)) { p.geometry.computeBoundingBox(); bbox.union(p.geometry.boundingBox); }
    const size = bbox.getSize(new THREE.Vector3());
    bbox.getCenter(offset);
    root.position.copy(offset).negate();
    radius = Math.max(size.x, size.y, size.z, 1) * 0.5;

    const objects = [...new Set(m.parts.map(p => p.object))];
    for (const p of m.parts) {
      p.geometry.computeVertexNormals();
      const isNormal = p.kind === "normal";
      const tint = isNormal ? PART_TINTS[objects.indexOf(p.object) % PART_TINTS.length] : KIND_COLOR[p.kind] ?? 0x999999;
      const mat = new THREE.MeshStandardMaterial({
        color: tint ?? SCHEMES[scheme].model, roughness: 0.55, metalness: 0, side: THREE.FrontSide,
        transparent: !isNormal, opacity: isNormal ? 1 : 0.35, depthWrite: isNormal, clippingPlanes: [clip],
        polygonOffset: true, polygonOffsetFactor: 1, polygonOffsetUnits: 1,
      });
      const mesh = new THREE.Mesh(p.geometry, mat);
      mesh.userData = { part: p, tint };
      if (isNormal) {
        // back faces show through a section cut as solid red "cut material"
        const inside = new THREE.Mesh(p.geometry, new THREE.MeshBasicMaterial({ color: CUT_COLOR, side: THREE.BackSide, clippingPlanes: [clip],
          polygonOffset: true, polygonOffsetFactor: 6, polygonOffsetUnits: 6 }));
        mesh.add(inside);
        const edges = new THREE.LineSegments(new THREE.EdgesGeometry(p.geometry, 25),
          new THREE.LineBasicMaterial({ color: SCHEMES[scheme].edge, clippingPlanes: [clip] }));
        edges.userData.isEdges = true;
        mesh.add(edges);
      }
      root.add(mesh);
      meshes.push(mesh);
    }

    // bed outline (3MF): drawn at bed coordinates so the part sits where it will print
    if (m.bed) {
      const b = m.bed, z = bbox.min.z;
      const pts = [[0, 0], [b.w, 0], [b.w, b.h], [0, b.h], [0, 0]].map(([x, y]) => new THREE.Vector3(x, y, z));
      const line = new THREE.Line(new THREE.BufferGeometry().setFromPoints(pts), new THREE.LineBasicMaterial({ color: 0x555555 }));
      line.userData.overlay = "bed";
      overlays.add(line);
    }
    // pause / colour-change planes
    for (const p of m.pauses || []) {
      const w = size.x * 1.3 + 4, h = size.y * 1.3 + 4;
      const plane = new THREE.Mesh(new THREE.PlaneGeometry(w, h), new THREE.MeshBasicMaterial({
        color: 0xff7a00, transparent: true, opacity: 0.12, side: THREE.DoubleSide, depthWrite: false }));
      plane.position.set(offset.x, offset.y, p.z);
      plane.add(new THREE.LineSegments(new THREE.EdgesGeometry(plane.geometry), new THREE.LineBasicMaterial({ color: 0xff7a00 })));
      plane.userData.overlay = "pause";
      overlays.add(plane);
    }
    rebuildGrid(size);
    if (section) setSection(section.axis, section.value);
    applyScheme(scheme);
    apply();
    frame();
  }

  function rebuildGrid(size) {
    if (grid) { helpers.remove(grid); grid.geometry.dispose(); grid.material.dispose(); }
    const span = Math.max(size.x, size.y, 1);
    const step = [1, 2, 5, 10, 20, 50, 100].find(s => span * 2.2 / s <= 30) || 100;
    const n = Math.ceil(span * 2.2 / step);
    grid = new THREE.GridHelper(n * step, n);
    grid.rotation.x = Math.PI / 2;
    grid.position.z = -size.z / 2 - 0.01;
    grid.material.transparent = true; grid.material.opacity = 0.6;
    helpers.clear();
    const axes = new THREE.AxesHelper(Math.max(span * 0.25, 5));
    axes.position.set(-span * 0.6, -span * 0.6, -size.z / 2);
    helpers.add(grid, axes);
  }

  function applyScheme(name) {
    scheme = SCHEMES[name] ? name : "cornfield";
    const s = SCHEMES[scheme];
    bg.material.uniforms.top.value.setHex(s.bgTop);
    bg.material.uniforms.bot.value.setHex(s.bgBot);
    for (const m of meshes) {
      if (m.userData.part.kind === "normal" && m.userData.tint == null) m.material.color.setHex(s.model);
      m.material.metalness = scheme === "metal" ? 0.85 : 0;
      m.material.roughness = scheme === "metal" ? 0.35 : 0.55;
      m.children.forEach(c => c.userData.isEdges && c.material.color.setHex(s.edge));
    }
    if (grid) grid.material.color.setHex(s.grid);
  }

  function apply() {
    for (const m of meshes) {
      const normal = m.userData.part.kind === "normal";
      m.visible = normal || state.modifiers;
      m.material.wireframe = state.wireframe;
      m.children.forEach(c => { if (c.userData.isEdges) c.visible = state.edges && !state.wireframe; });
    }
    for (const o of overlays.children) o.visible = o.userData.overlay === "bed" ? state.bed : state.pauses;
    helpers.visible = state.helpers;
    controls.autoRotate = state.rotate;
  }

  function setSection(axis, value) {
    // keep the part on the low side of the plane (in model coordinates)
    if (!axis) { section = null; clip.set(new THREE.Vector3(0, 0, -1), 1e9); return; }
    section = { axis, value };
    const n = { x: [-1, 0, 0], y: [0, -1, 0], z: [0, 0, -1] }[axis];
    clip.normal.set(...n);
    clip.constant = value - offset[axis];   // world = model - offset
  }

  function frame(dir = view) {
    view = dir;
    const w = container.clientWidth, h = container.clientHeight;
    if (w && h) persp.aspect = w / h;
    const vhalf = (persp.fov * Math.PI) / 360, hhalf = Math.atan(Math.tan(vhalf) * persp.aspect);
    const d = radius / Math.sin(Math.min(vhalf, hhalf)) * 1.15;
    const v = new THREE.Vector3(...(DIRS[dir] || DIRS.iso)).normalize();
    for (const cam of [persp, ortho]) {
      cam.position.copy(v).multiplyScalar(d);
      cam.near = Math.max(d / 1000, 0.01); cam.far = d * 100;
      cam.lookAt(0, 0, 0);
    }
    controls.target.set(0, 0, 0);
    resize();
    controls.update();
  }

  function setOrtho(on) {
    const prev = camera;
    useOrtho = !!on;
    camera = useOrtho ? ortho : persp;
    if (prev !== camera) { camera.position.copy(prev.position); camera.quaternion.copy(prev.quaternion); camera.up.copy(prev.up); }
    controls.object = camera;
    resize();
  }

  function resize(w = container.clientWidth, h = container.clientHeight) {
    if (!w || !h) return;
    renderer.setSize(w, h, true);
    const a = w / h;
    persp.aspect = a; persp.updateProjectionMatrix();
    fitOrtho(a);
  }

  // Ortho frustum = the model's bounding box as seen from the current camera
  // direction (plus margin), so flat parts fill a front view instead of a sliver.
  function fitOrtho(a = persp.aspect) {
    if (camera !== ortho) { ortho.position.copy(persp.position); ortho.quaternion.copy(persp.quaternion); }
    ortho.updateMatrixWorld();
    const inv = ortho.matrixWorldInverse;
    let x0 = Infinity, x1 = -Infinity, y0 = Infinity, y1 = -Infinity;
    const b = [bbox.min.clone().sub(offset), bbox.max.clone().sub(offset)];
    if (!isFinite(b[0].x)) { b[0].set(-radius, -radius, -radius); b[1].set(radius, radius, radius); }
    for (let i = 0; i < 8; i++) {
      const v = new THREE.Vector3(b[i & 1].x, b[(i >> 1) & 1].y, b[(i >> 2) & 1].z).applyMatrix4(inv);
      x0 = Math.min(x0, v.x); x1 = Math.max(x1, v.x); y0 = Math.min(y0, v.y); y1 = Math.max(y1, v.y);
    }
    const cx = (x0 + x1) / 2, cy = (y0 + y1) / 2;
    let hw = (x1 - x0) / 2 * 1.12 + 1e-3, hh = (y1 - y0) / 2 * 1.12 + 1e-3;
    if (hw / hh < a) hw = hh * a; else hh = hw / a;
    ortho.left = cx - hw; ortho.right = cx + hw; ortho.top = cy + hh; ortho.bottom = cy - hh;
    ortho.updateProjectionMatrix();
  }

  function draw() {
    key.position.copy(camera.position);
    fill.position.copy(camera.position).applyAxisAngle(new THREE.Vector3(0, 0, 1), 2.4);
    back.position.copy(camera.position).multiplyScalar(-1);
    renderer.render(scene, camera);
  }

  function loop() { requestAnimationFrame(loop); controls.update(); draw(); }

  function stats() {
    if (!model) return null;
    let tris = 0, vol = 0;
    for (const p of model.parts) {
      if (p.kind !== "normal") continue;
      const a = p.geometry.attributes.position.array;
      tris += a.length / 9;
      for (let i = 0; i < a.length; i += 9)
        vol += (a[i] * (a[i + 4] * a[i + 8] - a[i + 5] * a[i + 7]) - a[i + 1] * (a[i + 3] * a[i + 8] - a[i + 5] * a[i + 6])
              + a[i + 2] * (a[i + 3] * a[i + 7] - a[i + 4] * a[i + 6])) / 6;
    }
    const size = bbox.getSize(new THREE.Vector3());
    return {
      size: [size.x, size.y, size.z], min: bbox.min.toArray(), max: bbox.max.toArray(),
      tris, volume_mm3: Math.abs(vol),
      parts: model.parts.map(p => ({ name: p.name, object: p.object, kind: p.kind })),
      pauses: model.pauses, bed: model.bed, settings: model.settings,
    };
  }

  // Headless: render one view at w x h and return a PNG data URL.
  function snapshot({ view: v = "iso", ortho: o = false, w = 800, h = 600, azimuth = 0, scale = 1 } = {}) {
    container.style.width = w + "px"; container.style.height = h + "px";
    setOrtho(o);
    frame(v);
    if (azimuth) {
      for (const cam of [persp, ortho]) cam.position.applyAxisAngle(new THREE.Vector3(0, 0, 1), azimuth * Math.PI / 180);
      persp.lookAt(0, 0, 0);
    }
    resize(w, h);
    if (scale !== 1) { persp.position.multiplyScalar(scale); ortho.zoom = 1 / scale; ortho.updateProjectionMatrix(); }
    draw();
    return renderer.domElement.toDataURL("image/png");
  }

  addEventListener("resize", () => resize());
  if (typeof ResizeObserver !== "undefined") new ResizeObserver(() => resize()).observe(container);
  applyScheme(scheme);

  // Re-frame on a new box without rebuilding the scene (for part animations):
  // recentres the model and scales the camera distance, keeping the current
  // orbit direction. grid=false skips rebuilding the grid (cheap, per frame).
  function setBounds(box, { grid: withGrid = true } = {}) {
    bbox.copy(box);
    bbox.getCenter(offset);
    root.position.copy(offset).negate();
    const size = bbox.getSize(new THREE.Vector3());
    radius = Math.max(size.x, size.y, size.z, 1) * 0.5;
    if (withGrid) rebuildGrid(size);
    const vhalf = (persp.fov * Math.PI) / 360, hhalf = Math.atan(Math.tan(vhalf) * persp.aspect);
    const d = radius / Math.sin(Math.min(vhalf, hhalf)) * 1.15;
    const dir = persp.position.clone().sub(controls.target).normalize();
    controls.target.set(0, 0, 0);
    for (const cam of [persp, ortho]) { cam.position.copy(dir).multiplyScalar(d); cam.near = Math.max(d / 1000, 0.01); cam.far = d * 100; }
    persp.updateProjectionMatrix();
    fitOrtho();
  }

  return {
    renderer, scene, controls, state, show, frame, setOrtho, setSection, resize, draw, loop, stats, snapshot, setBounds,
    get meshes() { return meshes; },   // one per part: userData.part = { name, object, kind, geometry }
    get root() { return root; },       // model group (recentred); overlays added here move with the model
    get bounds() { return bbox.clone(); },
    setView: frame,
    setScheme: applyScheme,
    set(patch) { Object.assign(state, patch); apply(); },
    get section() { return section; },
    get offset() { return offset.clone(); },
  };
}
