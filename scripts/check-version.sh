#!/bin/sh
# Every place the specflow version is written must agree with plugin.json.
# The skills cannot read the manifest at run time (see LESSONS.md, "Seen during
# extraction" 6), so the version is repeated and this check keeps the copies
# honest. Run it before tagging a release.
set -eu

root=$(cd "$(dirname "$0")/.." && pwd)
version=$(sed -n 's/^ *"version": *"\([^"]*\)".*/\1/p' "$root/.claude-plugin/plugin.json")

if [ -z "$version" ]; then
  echo "no version found in .claude-plugin/plugin.json"
  exit 1
fi

status=0

require() {
  if ! grep -qF -- "$2" "$root/$1"; then
    echo "$1: expected to contain: $2"
    status=1
  fi
}

require .claude-plugin/marketplace.json "\"version\": \"$version\""
require skills/sync/SKILL.md "<!-- specflow:begin v$version -->"
require skills/run/SKILL.md "**This is specflow v$version.**"
require skills/run/SKILL.md "A stamp other than \`v$version\`"

if [ "$status" -eq 0 ]; then
  echo "specflow $version: every copy agrees"
fi
exit "$status"
