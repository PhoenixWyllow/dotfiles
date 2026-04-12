#!/usr/bin/env bash
# SYNOPSIS: Validate dotfiles setup and prerequisites.
#
# DESCRIPTION:
#   Checks that required commands exist, validates manifest.yaml integrity,
#   verifies source files are present, and checks platform specificity.
#
# REQUIRED COMMANDS: git, bash, rg, nvim
# OPTIONAL COMMANDS: starship, lazygit
#
# USAGE:
#   scripts/doctor.sh             - Run all diagnostics
#   scripts/doctor.sh --help      - Show this help
#   scripts/doctor.sh -h          - Shorthand for --help
#
# NOTES:
#   Safe to run anytime; no modifications made. Shows required/optional commands
#   and validates manifest structure before deployment.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/lib.sh
source "$SCRIPT_DIR/lib.sh"

missing=0
warnings=0

require_cmd() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    echo "[OK] required command found: $name"
  else
    echo "[FAIL] required command missing: $name"
    missing=$((missing + 1))
  fi
}

recommend_cmd() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    echo "[OK] optional command found: $name"
  else
    echo "[WARN] optional command missing: $name"
    warnings=$((warnings + 1))
  fi
}

validate_manifest_entries() {
  local entry_count=0
  while IFS=$'\t' read -r source target platforms type mode; do
    entry_count=$((entry_count + 1))

    if [[ "$type" != "file" && "$type" != "dir" ]]; then
      echo "[FAIL] invalid type '$type' for source '$source'"
      missing=$((missing + 1))
    fi

    if [[ "$mode" != "copy" ]]; then
      echo "[WARN] mode '$mode' for '$source' is not implemented by scripts"
      warnings=$((warnings + 1))
    fi

    case "$type" in
      file)
        if [[ ! -f "$REPO_ROOT/$source" ]]; then
          echo "[FAIL] source file not found: $source"
          missing=$((missing + 1))
        fi
        ;;
      dir)
        if [[ ! -d "$REPO_ROOT/$source" ]]; then
          echo "[FAIL] source dir not found: $source"
          missing=$((missing + 1))
        fi
        ;;
    esac

    if [[ "$target" != "~/"* && "$target" != "$HOME/"* ]]; then
      echo "[WARN] target does not start with ~/ or $HOME/: $target"
      warnings=$((warnings + 1))
    fi

    if [[ "$platforms" != "all" && ",${platforms// /}," != *",linux,"* && ",${platforms// /}," != *",windows,"* ]]; then
      echo "[WARN] no recognized platform listed for '$source': [$platforms]"
      warnings=$((warnings + 1))
    fi
  done < <(manifest_records)

  if [[ "$entry_count" -eq 0 ]]; then
    echo "[FAIL] manifest has no entries"
    missing=$((missing + 1))
  fi
}

echo "Running dotfiles doctor"

require_cmd git
require_cmd bash
require_cmd rg
require_cmd nvim

recommend_cmd starship
recommend_cmd lazygit

if [[ ! -f "$MANIFEST_PATH" ]]; then
  echo "[FAIL] manifest missing at $MANIFEST_PATH"
  missing=$((missing + 1))
else
  echo "[OK] manifest found: $MANIFEST_PATH"
  validate_manifest_entries
fi

if [[ "$missing" -gt 0 ]]; then
  echo "Doctor failed with $missing blocking issue(s) and $warnings warning(s)."
  exit 1
fi

echo "Doctor passed with $warnings warning(s)."
