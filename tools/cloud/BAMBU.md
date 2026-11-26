# Bambu Studio CLI on Linux / cloud sessions

Headless slicing is the only way to confirm that Bambu honours a 3MF's settings. It caught the
`wall_loops` override being silently reverted, and the 99%/100% "solid" modifiers that still
sliced as hollow grid (see `tools/README.md`). This page records how the Linux build was made to
run in a cloud container, so it can be redone when Bambu releases a new version.

```bash
tools/cloud/install_bambu.sh          # pinned version; ~20 s; tools/bambu-studio runs it on first use
tools/bambu-studio --slice 0 --outputdir out/ plate.3mf      # Mac app if installed, else this
python3 tools/cloud/check_slice.py plate.3mf --probe X,Y,R,Z  # slice + report what Bambu did
```

Currently pinned: **v02.09.01.70**. Installed under `tools/cloud/.cache/bambu/<version>/`
(gitignored); `current` points at the active one.

## How it works, and why each step exists

1. **Download the AppImage from the GitHub release.**
   `https://github.com/bambulab/BambuStudio/releases/download/v<VER>/<ASSET>`
   - Network: the cloud environment needs `github.com` and
     `release-assets.githubusercontent.com` allowed. Add both to the environment's allowed hosts; the
     download redirects from the first to the second.
   - A cloud session's GitHub gate blocks every page that **lists** assets for repos not
     attached to the session: the release pages, `expanded_assets`, `releases.atom` and the API.
     Direct `/releases/download/...` URLs pass. So **a person has to read the asset filename off
     the release page** in a browser; it can't be discovered from the session.
   - **Filename pattern** (as of v02.09.01.70):
     `BambuStudio_ubu24-v<VER>-<YYYYMMDDHHMMSS>.AppImage`, e.g.
     `BambuStudio_ubu24-v02.09.01.70-20261103183404.AppImage`. The timestamp is the build time
     and can't be guessed. The repo's CI workflow (`.github/workflows/build_bambu.yml`) names
     artifacts differently (`Bambu_Studio_<os>_V<ver>.AppImage`), and release uploads don't
     follow it. Don't trust the workflow for names.
   - Pick the `ubu24` asset: the cloud image is Ubuntu 24.04.
   - The SHA-256 is pinned in `install_bambu.sh`; the install fails if it doesn't match.
2. **Extract, don't mount.** Containers have no FUSE, so `--appimage-extract` unpacks to
   `squashfs-root/` and we run `squashfs-root/AppRun`.
3. **Missing system libraries:** `ldd squashfs-root/bin/bambu-studio | grep "not found"`.
   For v02.09.01.70 that listed:
   - `libwebkit2gtk-4.1.so.0`, `libjavascriptcoregtk-4.1.so.0`: apt `libwebkit2gtk-4.1-0`.
   - `libwayland-server.so.0`: apt `libwayland-server0`.
   - `libavcodec.so.61`, `libavutil.so.59`, `libswscale.so.8` are **FFmpeg 7**, and Ubuntu 24.04 only
     ships FFmpeg 6 (`libavcodec60`). PyAV's manylinux wheels bundle FFmpeg 7 as
     `av.libs/libavcodec-<hash>.so.61...`, so the installer downloads the wheel from PyPI
     (`av>=14,<15`, FFmpeg 7.1) and extracts `av.libs/`. It then adds plain-soname symlinks
     (`libavcodec.so.61 -> libavcodec-<hash>.so.61.19.100`) **only for `libav*`/`libsw*`**.
     The wheel also bundles gnutls, OpenSSL 1.0, drm and others. Giving those plain names would
     shadow the system copies through `LD_LIBRARY_PATH` and break WebKit/GTK.
   - `tools/bambu-studio` sets `LD_LIBRARY_PATH` to that `ffmpeg7/` dir.
4. **Run under Xvfb.** Even `--help` and `--slice` initialise GTK, so the wrapper runs
   `xvfb-run -a`.
5. **Harmless noise:** `[error] GCodeProcessor ... Invalid T command (T65535)` appears on every
   slice. Trust `result.json` (`"return_code": 0`, `"error_string": "Success."`) and the exit code.

## What was verified (v02.09.01.70, Nov 2026)

`examples/triangular-elipsoid/triangular_elipsoid_v3.3mf` (from its `build_3mf.py`):
- Settings: `wall_loops 3` and `enable_support 0` were honoured.
- Pause: exactly one `M400 U1`, right after the layer topping out at z = 2.4 mm. That's the
  model's `PAUSE HEIGHT`.
- Modifiers: inside the plate A post and the plate B pin, the infill lines are parallel and
  **0.425 / 0.43 mm apart**. That's solid 100% zig-zag and matches the desktop 2.08 check; sparse
  grid would be about 0.81 mm with open squares.

A larger single-part plate: slices, honours `wall_loops 6` and an outer-only brim, and uses
129.8 g of filament.

Slicing takes about 5 s per plate on 4 cores.

## Upgrading to a new Bambu release

1. Open the release page in a browser, expand **Assets** and copy the `ubu24` `.AppImage`
   filename. If the release marked Latest has none, use an earlier one.
2. Edit the three pinned lines at the top of `install_bambu.sh`:
   - `BAMBU_VERSION`
   - `BAMBU_ASSET`
   - `BAMBU_SHA256`: download once and run `sha256sum`, or set it to the hash the failed check
     prints, after confirming the download is the right file.
3. Run `tools/cloud/install_bambu.sh`. If it stops with "still missing:", map each library:
   - Try apt first: `apt-cache search <name>`.
   - A newer FFmpeg soname (e.g. `libavcodec.so.62`) means bumping `PYAV_SPEC` to the PyAV
     major that bundles that FFmpeg. Check with
     `python3 -m zipfile -l av-*.whl | grep libavcodec`.
   - Record what you changed in this file.
4. Re-run the verification and compare with the numbers above:
   `python3 tools/cloud/check_slice.py examples/triangular-elipsoid/triangular_elipsoid_v3.3mf --probe 101,128,2,1.0 --probe 150.2,128,2,1.0`.
   Rebuild the 3MF first with `python3 examples/triangular-elipsoid/build_3mf.py`.
5. Old versions stay in `.cache/bambu/<old>/` until deleted; `current` moves to the new one.
6. Update "Currently pinned" and "What was verified" above, then commit.
