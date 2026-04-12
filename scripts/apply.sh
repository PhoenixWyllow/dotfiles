#!/usr/bin/env bash
# SYNOPSIS: Deploy repository-managed files to home paths.
#
# DESCRIPTION:
#   Copies files and directories from the repository into their target locations,
#   filtered by the current platform (Linux vs Windows). Supports dry-run preview.
#   Non-destructive: only copies files matching manifest entries, does not delete.
#
# USAGE:
#   scripts/apply.sh               - Apply all entries for current platform
#   scripts/apply.sh --dry-run     - Preview what would be applied without copying
#   scripts/apply.sh --help        - Show this help
#   scripts/apply.sh -h            - Shorthand for --help
#
# NOTES:
#   Run from repository root. Skips missing sources. Works on Linux, WSL, Windows.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/lib.sh"

DRY_RUN=false

usage() {
  cat <<'EOF'
Usage: scripts/apply.sh [--dry-run]

Deploy repository-managed files to home paths for the current platform.
Filtered by platform, non-destructive (copy-only). Manifest controls deployment.

OPTIONS:
  --dry-run, -n     Preview deployment without copying files
  --help, -h        Show this help message

EXAMPLES:
  Apply all entries:
    $ bash scripts/apply.sh
  Preview first:
    $ bash scripts/apply.sh --dry-run
  Via git alias (after bootstrap):
    $ git df-apply --dry-run
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

applied=0

while IFS=$'\t' read -r source target platforms type mode; do
  # Only process entries explicitly enabled for the current platform.
  platform_matches "$current_platform" "$platforms" || continue

  # Future-proofing: only copy mode is implemented in first migration pass.
  if [[ "$mode" != "copy" ]]; then
    echo "Skipping $source because mode '$mode' is not supported yet."
    continue
  fi

  src_path="$REPO_ROOT/$source"
  dst_path="$(expand_home_path "$target")"

  if [[ ! -e "$src_path" ]]; then
    echo "Skipping missing source: $source"
    continue
  fi

  # Dry-run prints exactly what would happen, without touching target files.
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] copy ($type) $src_path -> $dst_path"
    applied=$((applied + 1))
    continue
  fi

  # File entries replace one file; dir entries merge directory contents.
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

  echo "Applied ($type): $source -> $target"
  applied=$((applied + 1))
done < <(manifest_records)

echo "Completed apply for platform '$current_platform'. Entries processed: $applied"
