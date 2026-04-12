<#
.SYNOPSIS
Sync home changes back into the repository.

.DESCRIPTION
Copies files and directories from home paths back into the repository source paths,
reversing the apply.ps1 direction. Filtered by current platform. Supports dry-run.

Use this to capture edits made in home (~, ~/.config/, etc) as repo updates.

.PARAMETER DryRun
Preview what would be captured without making changes. Use -n or --dry-run.

.EXAMPLE
PS> ./capture.ps1
Capture all home changes for current platform

.EXAMPLE
PS> ./capture.ps1 --dry-run
Show what would be captured without copying

.EXAMPLE
PS> ./capture.ps1 -h
Show this help

.NOTES
Non-destructive: only copies files in manifest, does not delete from repo.
Run from repository root: pwsh -NoProfile -File scripts/capture.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/lib.ps1"

$dryRun = $false

function Show-Usage {
    @'
Usage: scripts/capture.ps1 [--dry-run]

Copy managed target files from home paths back into repository source paths.
'@ | Write-Host
}

foreach ($arg in $args) {
    switch ($arg) {
        '--dry-run' { $dryRun = $true }
        '-n' { $dryRun = $true }
        '--help' { Show-Usage; exit 0 }
        '-h' { Show-Usage; exit 0 }
        default { throw "Unknown argument: $arg" }
    }
}

$currentPlatform = Get-CurrentPlatform
$captured = 0

foreach ($record in Get-ManifestRecords) {
    if (-not (Test-PlatformMatch $currentPlatform $record.Platforms)) {
        continue
    }

    if ($record.Mode -ne 'copy') {
        Write-Host "Skipping $($record.Source) because mode '$($record.Mode)' is not supported yet."
        continue
    }

    $srcPath = Expand-HomePath $record.Target
    $dstPath = Join-Path $script:RepoRoot $record.Source

    if (-not (Test-Path -LiteralPath $srcPath)) {
        Write-Host "Skipping missing target: $($record.Target)"
        continue
    }

    if ($dryRun) {
        Write-Host "[DRY-RUN] capture ($($record.Type)) $srcPath -> $dstPath"
        $captured++
        continue
    }

    switch ($record.Type) {
        'file' {
            $parent = Split-Path -Parent $dstPath
            if ($parent) {
                New-Item -ItemType Directory -Force -Path $parent | Out-Null
            }
            Copy-Item -LiteralPath $srcPath -Destination $dstPath -Force
        }
        'dir' {
            New-Item -ItemType Directory -Force -Path $dstPath | Out-Null
            Get-ChildItem -LiteralPath $srcPath -Force | ForEach-Object {
                Copy-Item -LiteralPath $_.FullName -Destination $dstPath -Recurse -Force
            }
        }
        default {
            Write-Host "Skipping $($record.Source) because type '$($record.Type)' is unsupported."
            continue
        }
    }

    Write-Host "Captured ($($record.Type)): $($record.Target) -> $($record.Source)"
    $captured++
}

Write-Host "Completed capture for platform '$currentPlatform'. Entries processed: $captured"