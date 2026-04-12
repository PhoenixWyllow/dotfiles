<#
.SYNOPSIS
Validate dotfiles setup and prerequisites.

.DESCRIPTION
Checks that required commands exist, validates manifest.yaml integrity,
verifies source files are present, and checks platform specificity.

Required: git, pwsh, rg, nvim
Optional: starship, lazygit

.EXAMPLE
PS> ./doctor.ps1
Run all diagnostics

.EXAMPLE
PS> ./doctor.ps1 -h
Show this help

.NOTES
Exit code 1 if blocking issues found, 0 if all checks pass.
Run from repository root: pwsh -NoProfile -File scripts/doctor.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/lib.ps1"

$missing = 0
$warnings = 0

function Require-Command {
    param([string]$Name)

    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        Write-Host "[OK] required command found: $Name"
    } else {
        Write-Host "[FAIL] required command missing: $Name"
        $script:missing++
    }
}

function Recommend-Command {
    param([string]$Name)

    if (Get-Command $Name -ErrorAction SilentlyContinue) {
        Write-Host "[OK] optional command found: $Name"
    } else {
        Write-Host "[WARN] optional command missing: $Name"
        $script:warnings++
    }
}

function Test-ManifestEntries {
    $entryCount = 0

    foreach ($record in Get-ManifestRecords) {
        $entryCount++

        if ($record.Type -notin @('file', 'dir')) {
            Write-Host "[FAIL] invalid type '$($record.Type)' for source '$($record.Source)'"
            $script:missing++
        }

        if ($record.Mode -ne 'copy') {
            Write-Host "[WARN] mode '$($record.Mode)' for '$($record.Source)' is not implemented by scripts"
            $script:warnings++
        }

        $sourcePath = Join-Path $script:RepoRoot $record.Source
        switch ($record.Type) {
            'file' {
                if (-not (Test-Path -LiteralPath $sourcePath -PathType Leaf)) {
                    Write-Host "[FAIL] source file not found: $($record.Source)"
                    $script:missing++
                }
            }
            'dir' {
                if (-not (Test-Path -LiteralPath $sourcePath -PathType Container)) {
                    Write-Host "[FAIL] source dir not found: $($record.Source)"
                    $script:missing++
                }
            }
        }

        if (-not ($record.Target.StartsWith('~/') -or $record.Target.StartsWith($HOME + '/'))) {
            Write-Host "[WARN] target does not start with ~/ or `$HOME/: $($record.Target)"
            $script:warnings++
        }

        if ($record.Platforms -ne 'all' -and $record.Platforms -notin @('linux', 'windows')) {
            Write-Host "[WARN] no recognized platform listed for '$($record.Source)': [$($record.Platforms)]"
            $script:warnings++
        }
    }

    if ($entryCount -eq 0) {
        Write-Host '[FAIL] manifest has no entries'
        $script:missing++
    }
}

Write-Host 'Running dotfiles doctor'

Require-Command git
Require-Command pwsh
Require-Command rg
Require-Command nvim

Recommend-Command starship
Recommend-Command lazygit

if (-not (Test-Path -LiteralPath $script:ManifestPath -PathType Leaf)) {
    Write-Host "[FAIL] manifest missing at $script:ManifestPath"
    $missing++
} else {
    Write-Host "[OK] manifest found: $script:ManifestPath"
    Test-ManifestEntries
}

if ($missing -gt 0) {
    Write-Host "Doctor failed with $missing blocking issue(s) and $warnings warning(s)."
    exit 1
}

Write-Host "Doctor passed with $warnings warning(s)."