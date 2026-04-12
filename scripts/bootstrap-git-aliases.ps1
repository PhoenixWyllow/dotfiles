<#
.SYNOPSIS
Install dotfiles git aliases.

.DESCRIPTION
Configures git aliases to call dotfiles scripts, making deployment as simple as:
  git df-apply        # Deploy to home
  git df-capture      # Sync home changes back
  git df-doctor       # Validate setup
  git df-bootstrap    # Reinstall aliases

Alias scope defaults to --local (current repository only). Use --global to share
across all repositories on this machine.

.PARAMETER Scope
Git config scope: --local (default) or --global

.EXAMPLE
PS> ./bootstrap-git-aliases.ps1
Install aliases in local scope

.EXAMPLE
PS> ./bootstrap-git-aliases.ps1 --global
Install aliases globally for this user

.EXAMPLE
PS> ./bootstrap-git-aliases.ps1 -h
Show this help

.NOTES
Run from repository root: pwsh -NoProfile -File scripts/bootstrap-git-aliases.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$scope = '--local'

function Show-Usage {
    @'
Usage: scripts/bootstrap-git-aliases.ps1 [--global|--local]

Installs dotfiles git aliases that call tracked repo scripts.
Default scope is --local (current repository).
'@ | Write-Host
}

foreach ($arg in $args) {
    switch ($arg) {
        '--global' { $scope = '--global' }
        '--local' { $scope = '--local' }
        '--help' { Show-Usage; exit 0 }
        '-h' { Show-Usage; exit 0 }
        default { throw "Unknown argument: $arg" }
    }
}

git config $scope alias.df-bootstrap '!pwsh -NoProfile -File scripts/bootstrap-git-aliases.ps1'
git config $scope alias.df-apply '!pwsh -NoProfile -File scripts/apply.ps1'
git config $scope alias.df-capture '!pwsh -NoProfile -File scripts/capture.ps1'
git config $scope alias.df-doctor '!pwsh -NoProfile -File scripts/doctor.ps1'

Write-Host "Installed aliases in $scope scope:"
Write-Host '  git df-bootstrap'
Write-Host '  git df-apply'
Write-Host '  git df-capture'
Write-Host '  git df-doctor'