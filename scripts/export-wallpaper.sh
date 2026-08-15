#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
CHARCOAL_SOURCE="$PROJECT_DIR/assets/wallpaper/smokeyember-charcoal.svg"
CHARCOAL_ULTRAWIDE_SOURCE="$PROJECT_DIR/assets/wallpaper/smokeyember-charcoal-ultrawide.svg"
CHARCOAL_OUTPUT="$PROJECT_DIR/backgrounds/01-smokeyember-charcoal.png"
CHARCOAL_ULTRAWIDE_OUTPUT="$PROJECT_DIR/backgrounds/02-smokeyember-charcoal-5120x1440.png"

if ! command -v rsvg-convert >/dev/null 2>&1; then
  printf 'Error: rsvg-convert is required to export the wallpaper.\n' >&2
  printf 'Install librsvg, then run this script again.\n' >&2
  exit 1
fi

mkdir -p "$PROJECT_DIR/backgrounds"
rsvg-convert --width 3840 --height 2160 --output "$CHARCOAL_OUTPUT" "$CHARCOAL_SOURCE"
rsvg-convert --width 5120 --height 1440 --output "$CHARCOAL_ULTRAWIDE_OUTPUT" "$CHARCOAL_ULTRAWIDE_SOURCE"

printf 'Exported %s\n' "$CHARCOAL_OUTPUT"
printf 'Exported %s\n' "$CHARCOAL_ULTRAWIDE_OUTPUT"
