#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)

if [[ ! -t 0 ]]; then
  printf 'Error: preview-local.sh must be run in an interactive terminal.\n' >&2
  exit 1
fi

if ! command -v omarchy >/dev/null 2>&1; then
  printf 'Error: Omarchy is not available on PATH.\n' >&2
  exit 1
fi

"$SCRIPT_DIR/validate.sh"
"$SCRIPT_DIR/install-local.sh"

PREVIOUS_THEME=$(omarchy theme current)
RESTORE_NEEDED=0

restore_theme() {
  if (( RESTORE_NEEDED )); then
    RESTORE_NEEDED=0
    printf '\nRestoring %s...\n' "$PREVIOUS_THEME"
    omarchy theme set "$PREVIOUS_THEME"
  fi
}

trap restore_theme EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

RESTORE_NEEDED=1
omarchy theme set smokeyember

printf '\nSmokeyEmber is active for preview.\n'
printf 'Press Enter to restore %s.\n' "$PREVIOUS_THEME"
read -r _
