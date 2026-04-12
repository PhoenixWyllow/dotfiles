#!/usr/bin/env bash
# SYNOPSIS: Sync home changes back into the repository.
#
# DESCRIPTION:
#   Copies files and directories from home paths back into the repository source paths,
#   reversing the apply.sh direction. Filtered by current platform. Supports dry-run.
#   Use this to capture edits made in home for committing.
#
# USAGE:
#   scripts/capture.sh             - Capture all home changes for current platform
#   scripts/capture.sh --dry-run   - Preview what would be captured without copying
#   scripts/capture.sh --help      - Show this help
#   scripts/capture.sh -h          - Shorthand for --help
#
# NOTES:
#   Non-destructive: only copies files in manifest, does not delete from repo.
#   Useful after editing dotfiles in home; brings changes back for commit.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/lib.sh"

DRY_RUN=false

usage() {
  cat <<'EOF'
Usage: scripts/capture.sh [--dry-run]

Sync home changes back into the repository (reverse of apply).
Copies edited files from home into repo source paths for committing.

OPTIONS:
  --dry-run, -n     Preview capture without copying files
  --help, -h        Show this help message

EXAMPLES:
  Capture home changes:
    $ bash scripts/capture.sh
  Preview first:
    $ bash scripts/capture.sh --dry-run
  Via git alias (after bootstrap):
    $ git df-capture
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run|-n)
      DRY_RUN=true
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

current_platform="$(detect_platform)"
if [[ "$current_platform" == "unknown" ]]; then
  echo "Unsupported platform. Expected Linux or Windows-compatible shell runtime." >&2
  exit 1
fi

captured=0

while IFS=$'\t' read -r source target platforms type mode; do
  platform_matches "$current_platform" "$platforms" || continue

  if [[ "$mode" != "copy" ]]; then
    echo "Skipping $source because mode '$mode' is not supported yet."
    continue
  fi

  src_path="$(expand_home_path "$target")"
  dst_path="$REPO_ROOT/$source"

  if [[ ! -e "$src_path" ]]; then
    echo "Skipping missing target: $target"
    continue
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] capture ($type) $src_path -> $dst_path"
    captured=$((captured + 1))
    continue
  fi

  case "$type" in
    file)
      mkdir -p "$(dirname "$dst_path")"
      cp -f "$src_path" "$dst_path"
      ;;
    dir)
      mkdir -p "$dst_path"
      cp -a "$src_path/." "$dst_path/"
      ;;
    *)
      echo "Skipping $source because type '$type' is unsupported."
      continue
      ;;
  esac

  echo "Captured ($type): $target -> $source"
  captured=$((captured + 1))
done < <(manifest_records)

echo "Completed capture for platform '$current_platform'. Entries processed: $captured"
