#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
PROJECT_DIR=$(CDPATH= cd -- "$SCRIPT_DIR/.." && pwd)
THEMES_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/omarchy/themes"
DESTINATION="$THEMES_DIR/smokeyember"

if [[ -L $DESTINATION ]]; then
  LINK_TARGET=$(readlink -f -- "$DESTINATION" 2>/dev/null || true)
  if [[ $LINK_TARGET == "$PROJECT_DIR" ]]; then
    printf 'SmokeyEmber is already linked at %s\n' "$DESTINATION"
    exit 0
  fi

  printf 'Error: %s is already a symlink to another location.\n' "$DESTINATION" >&2
  printf 'Nothing was changed. Remove or rename it manually before retrying.\n' >&2
  exit 1
fi

if [[ -e $DESTINATION ]]; then
  printf 'Error: %s already exists and will not be overwritten.\n' "$DESTINATION" >&2
  printf 'Nothing was changed. Remove or rename it manually before retrying.\n' >&2
  exit 1
fi

mkdir -p "$THEMES_DIR"
ln -s "$PROJECT_DIR" "$DESTINATION"

printf 'Linked SmokeyEmber at %s\n' "$DESTINATION"
printf 'Apply it with: omarchy theme set smokeyember\n'
