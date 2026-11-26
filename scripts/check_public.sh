#!/usr/bin/env bash
# Pre-publish privacy check for the public repo. Fails if any tracked file under the kit
# matches a private pattern. Run from anywhere:  kit/scripts/check_public.sh
# Patterns live in the PRIVATE repo (../.public-deny, one extended regex per line), so the
# list of what's private is itself never published. With no deny file, only the built-in
# patterns below are checked.
set -euo pipefail
kit="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$kit"
builtin='/Users/[a-z]|/home/[a-z]+/repos|BEGIN (RSA|OPENSSH) PRIVATE KEY|ghp_[A-Za-z0-9]{20}|sk-ant-'
deny="$kit/../.public-deny"
files=$(git ls-files . | grep -v -E '^(docs/|viewer/vendor|scripts/check_public.sh$|LICENSE$)')
fail=0
# file names
if echo "$files" | grep -E -i 'ref/photos/|\.heic$' ; then echo "^ photo files must not be published"; fail=1; fi
# contents (LICENSE is skipped: it names the copyright holder on purpose)
pats="$builtin"
[ -f "$deny" ] && pats="$pats|$(grep -v -E '^\s*(#|$)' "$deny" | paste -sd'|' -)"
if echo "$files" | tr '\n' '\0' | xargs -0 grep -n -I -i -E "$pats" -- 2>/dev/null; then
  echo "^ private text found (patterns: built-in + ${deny#$kit/})"; fail=1
fi
# big binaries
big=$(echo "$files" | tr '\n' '\0' | xargs -0 du -k 2>/dev/null | awk '$1 > 2048 {print}')
if [ -n "$big" ]; then echo "$big"; echo "^ files over 2 MB: are these meant to be public?"; fail=1; fi
[ $fail = 0 ] && echo "check_public: ok ($(echo "$files" | wc -l | tr -d ' ') files)"
exit $fail
