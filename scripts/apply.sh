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

# Executes a command or previews it depending on DRY_RUN.
do_step() {
  local desc="$1"; shift
  if [[ "$DRY_RUN" == true ]]; then
    echo "[DRY-RUN] $desc"
  else
    "$@"
  fi
}

copy_file_to() {
  mkdir -p "$(dirname "$2")"
  cp -f "$1" "$2"
}

sync_dir_to() {
  mkdir -p "$2"
  cp -a "$1/." "$2/"
}

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

  # File entries replace one file; dir entries sync directory contents.
  case "$type" in
    file)
      do_step "copy (file) $src_path -> $dst_path" copy_file_to "$src_path" "$dst_path"
      ;;
    dir)
      if [[ -d "$dst_path" ]]; then
        while IFS= read -r -d '' dst_file; do
          rel="${dst_file#${dst_path}/}"
          [[ -e "$src_path/$rel" ]] || do_step "delete $dst_file" rm -f "$dst_file"
        done < <(find "$dst_path" -mindepth 1 -type f -print0)
        while IFS= read -r -d '' dst_dir; do
          rel="${dst_dir#${dst_path}/}"
          [[ -e "$src_path/$rel" ]] || do_step "delete $dst_dir" rm -rf "$dst_dir"
        done < <(find "$dst_path" -mindepth 1 -type d -print0 | sort -rz)
      fi
      do_step "copy (dir) $src_path -> $dst_path" sync_dir_to "$src_path" "$dst_path"
      ;;
    *)
      echo "Skipping $source because type '$type' is unsupported."
      continue
      ;;
  esac

  [[ "$DRY_RUN" != true ]] && echo "Applied ($type): $source -> $target"
  applied=$((applied + 1))
done < <(manifest_records)

echo "Completed apply for platform '$current_platform'. Entries processed: $applied"
