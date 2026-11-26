#!/usr/bin/env bash
# Install Bambu Studio's Linux AppImage for headless CLI slicing (`tools/bambu-studio --slice`).
# Idempotent. Run as root on Ubuntu 24.04 (the cloud image). See tools/cloud/BAMBU.md for
# why each step exists and how to move to a new Bambu release.
#
#   tools/cloud/install_bambu.sh            # installs the pinned version below
#
# --- pinned release: change these three lines to upgrade (see BAMBU.md "Upgrading") ---
BAMBU_VERSION="02.09.01.70"
BAMBU_ASSET="BambuStudio_ubu24-v02.09.01.70-20261103183404.AppImage"
BAMBU_SHA256="668dabb1be53c758189ed6bc89935285dea5e0af46216546b1bafd6882e9aff0"
# FFmpeg 7 shared libraries (Ubuntu 24.04 only has FFmpeg 6) come from this PyAV wheel range
PYAV_SPEC="av>=14,<15"
# ------------------------------------------------------------------------------------------
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dest="$here/.cache/bambu/$BAMBU_VERSION"
url="https://github.com/bambulab/BambuStudio/releases/download/v$BAMBU_VERSION/$BAMBU_ASSET"

if [ -x "$dest/squashfs-root/AppRun" ] && [ -e "$dest/ffmpeg7/libavcodec.so.61" ]; then
  echo "Bambu Studio $BAMBU_VERSION present"; exit 0
fi
mkdir -p "$dest" && cd "$dest"

echo "== system libraries (WebKitGTK 4.1, Wayland server, Xvfb)"
if command -v apt-get >/dev/null && [ "$(id -u)" = 0 ]; then
  apt-get update -qq
  DEBIAN_FRONTEND=noninteractive apt-get install -y -qq --no-install-recommends \
    libwebkit2gtk-4.1-0 libwayland-server0 xvfb xauth
fi

echo "== AppImage $BAMBU_ASSET"
curl -fsSL -o bambu.AppImage "$url"
echo "$BAMBU_SHA256  bambu.AppImage" | sha256sum -c -
chmod +x bambu.AppImage
# no FUSE in containers: extract instead of mounting
rm -rf squashfs-root && ./bambu.AppImage --appimage-extract >/dev/null && rm bambu.AppImage

echo "== FFmpeg 7 libraries from a PyAV wheel"
tmp="$(mktemp -d)"
python3 -m pip download -q --no-deps --only-binary=:all: "$PYAV_SPEC" -d "$tmp"
rm -rf ffmpeg7 && mkdir ffmpeg7
python3 - "$tmp" ffmpeg7 <<'EOF'
import glob, os, re, sys, zipfile
whl = glob.glob(os.path.join(sys.argv[1], "av-*.whl"))[0]
z = zipfile.ZipFile(whl)
for n in z.namelist():
    if n.startswith("av.libs/") and not n.endswith("/"):
        open(os.path.join(sys.argv[2], n.split("/")[-1]), "wb").write(z.read(n))
# plain sonames ONLY for FFmpeg's own libs; the wheel's other bundled libs (gnutls,
# crypto, drm...) keep their hashed names so they never shadow the system copies
for f in os.listdir(sys.argv[2]):
    m = re.match(r"(lib(?:av|sw)\w+)-[0-9a-f]{8}\.so\.(\d+)", f)
    if m:
        os.symlink(f, os.path.join(sys.argv[2], f"{m.group(1)}.so.{m.group(2)}"))
EOF
rm -rf "$tmp"

missing=$(LD_LIBRARY_PATH="$dest/ffmpeg7" ldd squashfs-root/bin/bambu-studio | grep 'not found' || true)
if [ -n "$missing" ]; then echo "still missing:"; echo "$missing"; exit 1; fi
ln -sfn "$dest" "$here/.cache/bambu/current"
echo "Bambu Studio $BAMBU_VERSION installed: tools/bambu-studio --help"
