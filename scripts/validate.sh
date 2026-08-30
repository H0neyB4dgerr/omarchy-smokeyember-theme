#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
COLORS_FILE="$PROJECT_DIR/colors.toml"
SVG_FILES=(
  "$PROJECT_DIR/assets/wallpaper/smokeyember-charcoal.svg"
  "$PROJECT_DIR/assets/wallpaper/smokeyember-charcoal-ultrawide.svg"
  "$PROJECT_DIR/assets/unlock/smokeyember-unlock.svg"
)
PNG_FILES=(
  "$PROJECT_DIR/backgrounds/01-smokeyember-charcoal.png"
  "$PROJECT_DIR/backgrounds/02-smokeyember-charcoal-5120x1440.png"
  "$PROJECT_DIR/unlock.png"
  "$PROJECT_DIR/preview-unlock.png"
)
PNG_EXPECTED_DIMENSIONS=(
  "3840x2160"
  "5120x1440"
  "900x260"
  "1920x1080"
)

REQUIRED_FILES=(
  "$PROJECT_DIR/README.md"
  "$PROJECT_DIR/LICENSE"
  "$PROJECT_DIR/colors.toml"
  "$PROJECT_DIR/icons.theme"
  "${SVG_FILES[@]}"
  "${PNG_FILES[@]}"
)

for required_file in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f $required_file ]]; then
    printf 'Error: required file is missing: %s\n' "$required_file" >&2
    exit 1
  fi
done

if [[ -e $PROJECT_DIR/kitty.conf ]]; then
  printf 'Error: kitty.conf must not be committed; Omarchy generates it from colors.toml.\n' >&2
  exit 1
fi

if [[ -e $PROJECT_DIR/shell.lock.toml ]]; then
  printf 'Error: shell.lock.toml must remain absent so Omarchy generates the desktop lock palette.\n' >&2
  exit 1
fi

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

  if [[ -L $png_file ]]; then
    printf 'Error: PNG assets must be regular files, not symlinks: %s\n' "$png_file" >&2
    exit 1
  fi

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

if command -v magick >/dev/null 2>&1; then
  if [[ $(magick identify -format '%[opaque]' "$PROJECT_DIR/unlock.png") != "False" ]]; then
    printf 'Error: unlock.png must contain transparent pixels.\n' >&2
    exit 1
  fi

  if [[ $(magick identify -format '%[opaque]' "$PROJECT_DIR/preview-unlock.png") != "True" ]]; then
    printf 'Error: preview-unlock.png must be fully composited and opaque.\n' >&2
    exit 1
  fi

  if [[ $(magick identify -format '%[pixel:p{0,0}]' "$PROJECT_DIR/unlock.png") != "srgba(0,0,0,0)" ]]; then
    printf 'Error: unlock.png must have a fully transparent canvas outside the glow.\n' >&2
    exit 1
  fi

  if [[ $(magick identify -format '%[pixel:p{0,0}]' "$PROJECT_DIR/preview-unlock.png") != "srgb(11,11,15)" ]]; then
    printf 'Error: preview-unlock.png must use #0B0B0F as its background.\n' >&2
    exit 1
  fi
fi

if ! grep -Fq 'width="900" height="260"' "$PROJECT_DIR/assets/unlock/smokeyember-unlock.svg" ||
   ! grep -Fq 'translate(50 36) scale(0.658436214 0.659649123)' "$PROJECT_DIR/assets/unlock/smokeyember-unlock.svg" ||
   ! grep -Fq 'fill="#A79ABD"' "$PROJECT_DIR/assets/unlock/smokeyember-unlock.svg" ||
   ! grep -Fq 'fill="#FF6B35" opacity="0.20"' "$PROJECT_DIR/assets/unlock/smokeyember-unlock.svg" ||
   ! grep -Fq 'feGaussianBlur stdDeviation="8"' "$PROJECT_DIR/assets/unlock/smokeyember-unlock.svg"; then
  printf 'Error: unlock SVG does not match the specified canvas, wordmark, colors, opacity, and glow.\n' >&2
  exit 1
fi

REQUIRED_COLORS=(
  mode accent selection selection_background selection_foreground muted
  background dark_background darker_background lighter_background
  surface surface_2 border
  foreground dark_foreground light_foreground bright_foreground
  red yellow orange green cyan blue magenta brown
  bright_red bright_yellow bright_green bright_cyan bright_blue bright_magenta
  hyprland_active_border hyprland_inactive_border
)

EXPECTED_COLOR_VALUES=(
  'mode=dark'
  'accent=#FF6B35'
  'selection=#332F3D'
  'selection_background=#332F3D'
  'selection_foreground=#ECEAF1'
  'muted=#8176A5'
  'background=#0B0B0F'
  'dark_background=#07070A'
  'darker_background=#050507'
  'lighter_background=#191820'
  'surface=#121218'
  'surface_2=#191820'
  'border=#332F3D'
  'foreground=#C8C7D0'
  'dark_foreground=#686674'
  'light_foreground=#D8D6DF'
  'bright_foreground=#ECEAF1'
  'red=#D9572B'
  'yellow=#E89A5B'
  'orange=#FF6B35'
  'green=#87968B'
  'cyan=#8396A6'
  'blue=#7F8FBE'
  'magenta=#9D7CD8'
  'brown=#8C5742'
  'bright_red=#FF7A50'
  'bright_yellow=#FFB16E'
  'bright_green=#A7B1A8'
  'bright_cyan=#A4B0BD'
  'bright_blue=#9DACD2'
  'bright_magenta=#B89EE7'
  'hyprland_active_border=rgba(a79abdee)'
  'hyprland_inactive_border=rgba(332f3daa)'
)

for expected_pair in "${EXPECTED_COLOR_VALUES[@]}"; do
  color_key=${expected_pair%%=*}
  expected_value=${expected_pair#*=}
  if ! grep -Fqx "$color_key = \"$expected_value\"" "$COLORS_FILE"; then
    printf 'Error: expected %s = "%s" in colors.toml.\n' "$color_key" "$expected_value" >&2
    exit 1
  fi
done

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

  for expected_pair in "${EXPECTED_COLOR_VALUES[@]}"; do
    color_key=${expected_pair%%=*}
    expected_value=${expected_pair#*=}
    if ! awk -F '\t' -v key="$color_key" -v expected="$expected_value" '$1 == key && $2 == expected { found = 1 } END { exit !found }' <<<"$RESOLVED_COLORS"; then
      printf 'Error: resolved %s does not equal %s.\n' "$color_key" "$expected_value" >&2
      exit 1
    fi
  done
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

if ! grep -Fq 'https://github.com/H0neyB4dgerr/omarchy-smokeyember-theme.git' "$PROJECT_DIR/README.md"; then
  printf 'Error: README.md must use the public SmokeyEmber GitHub URL.\n' >&2
  exit 1
fi

printf 'SmokeyEmber validation passed.\n'
