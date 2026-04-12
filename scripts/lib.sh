#!/usr/bin/env bash
# SYNOPSIS: Dotfiles manifest utilities and helpers.
#
# DESCRIPTION:
#   Internal library providing core functions for parsing manifest.yaml,
#   detecting platform, expanding paths, and managing dotfiles deployment
#   across Linux and Windows.
#
# FUNCTIONS (for internal use by scripts):
#   detect_platform() - Detect current platform (linux, windows, unknown)
#   expand_home_path() - Convert ~/ paths to full user home path
#   platform_matches() - Check if platform matches entry filters
#   manifest_records() - Parse manifest.yaml into deployment records
#
# NOTES:
#   Sourced by apply.sh, capture.sh, doctor.sh, bootstrap-git-aliases.sh.
#   Not meant to be executed directly.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST_PATH="${MANIFEST_PATH:-$REPO_ROOT/manifest.yaml}"

trim() {
  local value="$1"
  value="${value#${value%%[![:space:]]*}}"
  value="${value%${value##*[![:space:]]}}"
  printf '%s' "$value"
}

strip_quotes() {
  local value="$1"
  if [[ "$value" == \"*\" && "$value" == *\" ]]; then
    value="${value#\"}"
    value="${value%\"}"
  fi
  printf '%s' "$value"
}

detect_platform() {
  local uname_out
  uname_out="$(uname -s | tr '[:upper:]' '[:lower:]')"

  case "$uname_out" in
    linux*)
      printf 'linux'
      ;;
    msys*|mingw*|cygwin*)
      printf 'windows'
      ;;
    *)
      printf 'unknown'
      ;;
  esac
}

expand_home_path() {
  local path="$1"
  if [[ "$path" == "~" ]]; then
    printf '%s' "$HOME"
    return
  fi
  if [[ "$path" == "~"/* ]]; then
    printf '%s' "$HOME/${path#\~/}"
    return
  fi
  printf '%s' "$path"
}

platform_matches() {
  local current_platform="$1"
  local raw_platforms="$2"

  # "all" is emitted for entries under the shared entries: section.
  [[ "$raw_platforms" == "all" ]] && return 0

  local normalized
  normalized="${raw_platforms// /}"
  normalized=",$normalized,"

  [[ "$normalized" == *",$current_platform,"* ]]
}

manifest_records() {
  if [[ ! -f "$MANIFEST_PATH" ]]; then
    echo "Manifest not found: $MANIFEST_PATH" >&2
    return 1
  fi

  # Track which top-level section we are in.
  # entries: -> platforms=all  linux:/windows:/etc. -> platforms=<section name>
  local current_section="entries"
  local source="" target="" type="" mode=""

  emit_record() {
    [[ -z "$source" && -z "$target" ]] && return

    if [[ -z "$source" || -z "$target" ]]; then
      echo "Malformed manifest entry near source='$source'" >&2
      return 1
    fi

    local platforms
    [[ "$current_section" == "entries" ]] && platforms="all" || platforms="$current_section"

    # Apply defaults: type=file, mode=copy unless explicitly overridden.
    # Directories must be stated explicitly with type: dir.
    printf '%s\t%s\t%s\t%s\t%s\n' \
      "$source" "$target" "$platforms" "${type:-file}" "${mode:-copy}"
  }

  while IFS= read -r raw_line || [[ -n "$raw_line" ]]; do
    local line
    line="$(trim "$raw_line")"
    [[ -z "$line" || "$line" == \#* ]] && continue

    # Top-level section header: starts at column 0 with a letter.
    if [[ "$raw_line" =~ ^[[:alpha:]] ]]; then
      emit_record || return 1
      source="" target="" type="" mode=""
      current_section="${line%:}"
      continue
    fi

    case "$line" in
      "- source:"*)
        emit_record || return 1
        source="$(strip_quotes "$(trim "${line#- source:}")")" 
        target="" type="" mode=""
        ;;
      "target:"*)
        target="$(strip_quotes "$(trim "${line#target:}")")" 
        ;;
      "type:"*)
        type="$(strip_quotes "$(trim "${line#type:}")")"
        ;;
      "mode:"*)
        mode="$(strip_quotes "$(trim "${line#mode:}")")"
        ;;
    esac
  done < "$MANIFEST_PATH"

  emit_record || return 1
}
