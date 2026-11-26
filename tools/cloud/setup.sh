#!/usr/bin/env bash
# Install everything up front. Usually unnecessary: every tool installs what it needs
# on first use via tools/cloud/need (see that file). Kept for convenience / old docs.
#   tools/cloud/setup.sh                  # python + openscad (+native) + render
#   tools/cloud/setup.sh --blender --bambu
set -euo pipefail
here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
caps=(python openscad openscad-native render)
[[ " $* " == *" --blender "* ]] && caps+=(blender)
[[ " $* " == *" --bambu "* ]] && caps+=(bambu)
"$here/need" "${caps[@]}"
"$here/../openscad" --version
echo "setup ok: ${caps[*]}"
