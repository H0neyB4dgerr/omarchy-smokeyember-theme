#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
SOURCE="$PROJECT_DIR/assets/unlock/smokeyember-unlock.svg"
UNLOCK_OUTPUT="$PROJECT_DIR/unlock.png"
PREVIEW_OUTPUT="$PROJECT_DIR/preview-unlock.png"
PREVIEW_HELPER_DIR=""

cleanup() {
  if [[ -n $PREVIEW_HELPER_DIR && -d $PREVIEW_HELPER_DIR ]]; then
    rm -rf -- "$PREVIEW_HELPER_DIR"
  fi
}
trap cleanup EXIT

for command_name in rsvg-convert magick omarchy-plymouth-preview; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Error: %s is required to export the unlock assets.\n' "$command_name" >&2
    exit 1
  fi
done

rsvg-convert --format png --width 900 --height 260 --output "$UNLOCK_OUTPUT" "$SOURCE"

# The official compositor opens its result in imv. A no-op shim keeps this
# reproducible exporter non-interactive while leaving the compositor unchanged.
PREVIEW_HELPER_DIR=$(mktemp -d)
printf '#!/usr/bin/env bash\nexit 0\n' >"$PREVIEW_HELPER_DIR/imv"
chmod 755 "$PREVIEW_HELPER_DIR/imv"
PATH="$PREVIEW_HELPER_DIR:$PATH" \
  omarchy-plymouth-preview '#0B0B0F' '#C4BFCC' "$UNLOCK_OUTPUT" "$PREVIEW_OUTPUT"

# ImageMagick records creation timestamps by default. Strip those ancillary
# chunks so identical SVG and palette inputs produce byte-identical PNGs.
magick "$PREVIEW_OUTPUT" -strip -define png:exclude-chunks=date,time \
  "$PREVIEW_HELPER_DIR/preview-unlock.png"
mv "$PREVIEW_HELPER_DIR/preview-unlock.png" "$PREVIEW_OUTPUT"

printf 'Exported %s\n' "$UNLOCK_OUTPUT"
printf 'Exported %s\n' "$PREVIEW_OUTPUT"
