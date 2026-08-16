#!/usr/bin/env bash
# Build a release zip of the coach/ skill bundle.
# Usage: scripts/bundle_coach_skill.sh [version]
# Version defaults to COACH_VERSION, then git describe --tags --always, then "dev".
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

VERSION="${1:-${COACH_VERSION:-}}"
if [[ -z "$VERSION" ]]; then
  VERSION="$(git describe --tags --always 2>/dev/null || true)"
fi
VERSION="${VERSION:-dev}"
# Strip leading v for display inside archive; keep tag as given for filename.
SAFE_VERSION="${VERSION#v}"
SAFE_VERSION="${SAFE_VERSION//\//-}"

# Strip YAML frontmatter from SKILL.md so Project instructions stay prose-only.
strip_frontmatter() {
  awk '
    BEGIN { fm = 0 }
    NR == 1 && /^---[[:space:]]*$/ { fm = 1; next }
    fm == 1 && /^---[[:space:]]*$/ { fm = 0; next }
    fm == 0 { print }
  ' "$1"
}

echo "==> Regenerating coach/exports/project-instructions.md"
mkdir -p coach/exports
{
  echo '# Study Coach — Claude Project instructions'
  echo
  echo 'Paste this entire file into the Claude Project instructions for one subject.'
  echo 'Upload course.md, routine.md, state.md, and log.md as Project knowledge.'
  echo 'Commands: `/coach`, `/coach:setup`, `/coach:probe`, `/coach:orient`, `/coach:plan`, `/coach:teach`, `/coach:check`.'
  echo
  echo '---'
  cat coach/voice.md
  echo
  echo '---'
  strip_frontmatter coach/SKILL.md
  echo
  echo '---'
  cat coach/setup.md
  for f in probe orient plan teach check; do
    echo
    echo '---'
    echo
    cat "coach/phases/$f.md"
  done
} > coach/exports/project-instructions.md

echo "==> Validating bundle"
python3 scripts/validate_coach_bundle.py

DIST="$ROOT/dist"
mkdir -p "$DIST"
STAGING="$(mktemp -d)"
cleanup() { rm -rf "$STAGING"; }
trap cleanup EXIT

# Claude skill upload requires SKILL.md in the top-level folder of the zip
# (study-coach/SKILL.md), not nested as study-coach/coach/SKILL.md.
STAGE_NAME="study-coach"
mkdir -p "$STAGING/$STAGE_NAME"
cp -R coach/. "$STAGING/$STAGE_NAME/"
cp README.md "$STAGING/$STAGE_NAME/"
cp docs/how-to-update-skills.md "$STAGING/$STAGE_NAME/"

ARCHIVE="$DIST/study-coach-skill-${SAFE_VERSION}.zip"
rm -f "$ARCHIVE"
(
  cd "$STAGING"
  zip -r "$ARCHIVE" "$STAGE_NAME"
)

if ! unzip -Z -1 "$ARCHIVE" | grep -qx "${STAGE_NAME}/SKILL.md"; then
  echo "ERROR: zip must contain ${STAGE_NAME}/SKILL.md at the top of the skill folder" >&2
  unzip -Z -1 "$ARCHIVE" | grep SKILL.md || true
  exit 1
fi

# Checksum next to the zip (useful on the Release page)
(
  cd "$DIST"
  shasum -a 256 "study-coach-skill-${SAFE_VERSION}.zip" > "study-coach-skill-${SAFE_VERSION}.zip.sha256"
)

echo "==> Built $ARCHIVE"
ls -la "$ARCHIVE" "$ARCHIVE.sha256"
