{
  pkgs,
  ...
}:
pkgs.writeShellScriptBin "resolution-switch" ''
  #!/usr/bin/env bash
  set -euo pipefail

  NIRI_DIR="$HOME/.config/niri"
  RES_DIR="$NIRI_DIR/resolution"
  ACTIVE="$NIRI_DIR/active-profile.kdl"

  HARD=0

  usage() {
    echo "usage: resolution-switch [--hard] {default|xreal}" >&2
  }

  if [[ $# -eq 0 ]]; then
    usage
    exit 1
  fi

  if [[ "$1" == "--hard" ]]; then
    HARD=1
    shift
  fi

  if [[ $# -ne 1 ]]; then
    usage
    exit 1
  fi

  MODE="$1"

  case "$MODE" in
    default)
      PROFILE="monitor_16_9_1920_1080.kdl"
      ;;
    xreal)
      PROFILE="xreal_beam_pro_2400_1080.kdl"
      ;;
    *)
      echo "unknown mode: $MODE" >&2
      usage
      exit 1
      ;;
  esac

  TARGET="$RES_DIR/$PROFILE"

  if [[ ! -f "$TARGET" ]]; then
    echo "profile not found: $TARGET" >&2
    exit 1
  fi

  ln -sf "$TARGET" "$ACTIVE"

  if [[ "$HARD" -eq 1 ]]; then
    niri msg action quit
  else
    niri msg action load-config-file
  fi
''
