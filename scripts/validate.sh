#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
COLORS_FILE="$PROJECT_DIR/colors.toml"
SVG_FILES=(
  "$PROJECT_DIR/assets/wallpaper/smokeyember-charcoal.svg"
  "$PROJECT_DIR/assets/wallpaper/smokeyember-charcoal-ultrawide.svg"
)
PNG_FILES=(
  "$PROJECT_DIR/backgrounds/01-smokeyember-charcoal.png"
  "$PROJECT_DIR/backgrounds/02-smokeyember-charcoal-5120x1440.png"
)
PNG_EXPECTED_DIMENSIONS=(
  "3840x2160"
  "5120x1440"
)

REQUIRED_FILES=(
  "$PROJECT_DIR/README.md"
  "$PROJECT_DIR/LICENSE"
  "$PROJECT_DIR/colors.toml"
  "$PROJECT_DIR/icons.theme"
  "$PROJECT_DIR/kitty.conf"
  "${SVG_FILES[@]}"
  "${PNG_FILES[@]}"
)

for required_file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f $required_file ]]; then
    printf 'Error: required file is missing: %s\n' "$required_file" >&2
    exit 1
  fi
done

for script in "$SCRIPT_DIR"/*.sh; do
  bash -n "$script"
done

if command -v xmllint >/dev/null 2>&1; then
  for svg_file in "${SVG_FILES[@]}"; do
    xmllint --noout "$svg_file"
  done
else
  printf 'Warning: xmllint is unavailable; skipping explicit SVG XML validation.\n' >&2
fi

for png_index in "${!PNG_FILES[@]}"; do
  png_file=${PNG_FILES[$png_index]}
  expected_dimensions=${PNG_EXPECTED_DIMENSIONS[$png_index]}
  PNG_DIMENSIONS=""
  if command -v magick >/dev/null 2>&1; then
    PNG_DIMENSIONS=$(magick identify -format '%wx%h' "$png_file")
  elif command -v identify >/dev/null 2>&1; then
    PNG_DIMENSIONS=$(identify -format '%wx%h' "$png_file")
  else
    printf 'Warning: ImageMagick is unavailable; skipping PNG dimension validation.\n' >&2
    break
  fi

  if [[ $PNG_DIMENSIONS != "$expected_dimensions" ]]; then
    printf 'Error: wallpaper PNG must be %s, found %s in %s.\n' "$expected_dimensions" "$PNG_DIMENSIONS" "$png_file" >&2
    exit 1
  fi
done

REQUIRED_COLORS=(
  mode accent selection selection_background selection_foreground muted
  background dark_background darker_background lighter_background
  foreground dark_foreground light_foreground bright_foreground
  red yellow orange green cyan blue magenta brown
  bright_red bright_yellow bright_green bright_cyan bright_blue bright_magenta
  hyprland_active_border hyprland_inactive_border
)

if command -v omarchy-theme-color >/dev/null 2>&1; then
  RESOLVED_COLORS=$(omarchy-theme-color --file "$COLORS_FILE" --all)
  for color_key in "${REQUIRED_COLORS[@]}"; do
    if ! awk -F '\t' -v key="$color_key" '$1 == key && length($2) > 0 { found = 1 } END { exit !found }' <<<"$RESOLVED_COLORS"; then
      printf 'Error: colors.toml does not resolve required key: %s\n' "$color_key" >&2
      exit 1
    fi
  done

  if [[ $(omarchy-theme-color --file "$COLORS_FILE" mode) != "dark" ]]; then
    printf 'Error: SmokeyEmber must resolve as a dark theme.\n' >&2
    exit 1
  fi
else
  printf 'Warning: omarchy-theme-color is unavailable; using basic key checks.\n' >&2
  for color_key in "${REQUIRED_COLORS[@]}"; do
    if ! grep -Eq "^[[:space:]]*${color_key}[[:space:]]*=" "$COLORS_FILE"; then
      printf 'Error: colors.toml is missing required key: %s\n' "$color_key" >&2
      exit 1
    fi
  done
fi

if [[ $(tr -d '[:space:]' <"$PROJECT_DIR/icons.theme") != "Yaru-purple" ]]; then
  printf 'Error: icons.theme must select Yaru-purple.\n' >&2
  exit 1
fi

if ! grep -Eq '^cursor[[:space:]]+#FF6B35$' "$PROJECT_DIR/kitty.conf"; then
  printf 'Error: Kitty cursor must use the SmokeyEmber orange accent.\n' >&2
  exit 1
fi

if ! grep -Eq '^active_border_color[[:space:]]+#A79ABD$' "$PROJECT_DIR/kitty.conf"; then
  printf 'Error: Kitty active border must use the SmokeyEmber focus lavender.\n' >&2
  exit 1
fi

printf 'SmokeyEmber validation passed.\n'
