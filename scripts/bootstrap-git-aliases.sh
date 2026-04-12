#!/usr/bin/env bash
# SYNOPSIS: Install dotfiles git aliases.
#
# DESCRIPTION:
#   Configures git aliases to call dotfiles scripts, making deployment simple:
#     git df-apply        # Deploy to home
#     git df-capture      # Sync home changes back
#     git df-doctor       # Validate setup
#     git df-bootstrap    # Reinstall aliases
#
#   Alias scope defaults to --local (current repository). Use --global to share.
#
# USAGE:
#   scripts/bootstrap-git-aliases.sh          - Install in local scope
#   scripts/bootstrap-git-aliases.sh --local  - Same as above
#   scripts/bootstrap-git-aliases.sh --global - Install globally
#   scripts/bootstrap-git-aliases.sh --help   - Show this help
#   scripts/bootstrap-git-aliases.sh -h       - Shorthand for --help
#
# NOTES:
#   Must run from repository root. After bootstrap, use git df-* instead of scripts.
#   Recommended: run once per machine and repository clone.

set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/bootstrap-git-aliases.sh [--global|--local]

Install dotfiles git aliases for the deployment workflow.
Default scope is --local (current repository only).

OPTIONS:
  --local          Install in this repository only (default)
  --global         Install globally for all repositories on this machine
  --help, -h       Show this help

ALIASES INSTALLED:
  git df-bootstrap - Reinstall aliases
  git df-apply     - Deploy repo files to home
  git df-capture   - Sync home changes back to repo
  git df-doctor    - Validate setup and prerequisites

EXAMPLES:
  Local setup:
    $ bash scripts/bootstrap-git-aliases.sh
  Global setup:
    $ bash scripts/bootstrap-git-aliases.sh --global
EOF
}

scope="--local"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global)
      scope="--global"
      shift
      ;;
    --local)
      scope="--local"
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

git config "$scope" alias.df-bootstrap '!bash scripts/bootstrap-git-aliases.sh'
git config "$scope" alias.df-apply '!bash scripts/apply.sh'
git config "$scope" alias.df-capture '!bash scripts/capture.sh'
git config "$scope" alias.df-doctor '!bash scripts/doctor.sh'

echo "Installed aliases in $scope scope:"
echo "  git df-bootstrap"
echo "  git df-apply"
echo "  git df-capture"
echo "  git df-doctor"
