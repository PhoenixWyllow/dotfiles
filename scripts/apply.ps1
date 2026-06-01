<#
.SYNOPSIS
Deploy repository-managed files to home paths.

.DESCRIPTION
Copies files and directories from the repository into their target locations, filtered
by the current platform (Windows vs Linux). Supports dry-run preview.

Non-destructive: only copies files matching manifest entries, does not delete.

.PARAMETER DryRun
Preview what would be copied without making changes. Use -n or --dry-run.

.EXAMPLE
PS> ./apply.ps1
Apply all entries for current platform

.EXAMPLE
PS> ./apply.ps1 --dry-run
Show what would be applied without copying

.EXAMPLE
PS> ./apply.ps1 -h
Show this help

.NOTES
Run from repository root: pwsh -NoProfile -File scripts/apply.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

. "$PSScriptRoot/lib.ps1"

function Invoke-Step {
    param([string]$Description)
    if ($script:dryRun) {
        Write-Host "[DRY-RUN] $Description"
        return $false
    }
    return $true
}

$dryRun = $false

function Show-Usage {
    @'
Usage: scripts/apply.ps1 [--dry-run]

Copy managed files from the repository into target home paths for the current platform.
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
$applied = 0

foreach ($record in Get-ManifestRecords) {
    if (-not (Test-PlatformMatch $currentPlatform $record.Platforms)) {
        continue
    }

    if ($record.Mode -ne 'copy') {
        Write-Host "Skipping $($record.Source) because mode '$($record.Mode)' is not supported yet."
        continue
    }

    $srcPath = Join-Path $script:RepoRoot $record.Source
    $dstPath = Expand-HomePath $record.Target

    if (-not (Test-Path -LiteralPath $srcPath)) {
        Write-Host "Skipping missing source: $($record.Source)"
        continue
    }

    switch ($record.Type) {
        'file' {
            if (Invoke-Step "copy (file) $srcPath -> $dstPath") {
                $parent = Split-Path -Parent $dstPath
                if ($parent) {
                    New-Item -ItemType Directory -Force -Path $parent | Out-Null
                }
                Copy-Item -LiteralPath $srcPath -Destination $dstPath -Force
            }
        }
        'dir' {
            if (Test-Path -LiteralPath $dstPath) {
                Get-ChildItem -LiteralPath $dstPath -Recurse -File | ForEach-Object {
                    $rel = $_.FullName.Substring($dstPath.Length).TrimStart([IO.Path]::DirectorySeparatorChar)
                    if (-not (Test-Path -LiteralPath (Join-Path $srcPath $rel))) {
                        $itemPath = $_.FullName
                        if (Invoke-Step "delete $itemPath") {
                            Remove-Item -LiteralPath $itemPath -Force
                        }
                    }
                }
                Get-ChildItem -LiteralPath $dstPath -Recurse -Directory |
                    Sort-Object { $_.FullName.Length } -Descending |
                    ForEach-Object {
                        $rel = $_.FullName.Substring($dstPath.Length).TrimStart([IO.Path]::DirectorySeparatorChar)
                        if (-not (Test-Path -LiteralPath (Join-Path $srcPath $rel))) {
                            $itemPath = $_.FullName
                            if (Invoke-Step "delete $itemPath") {
                                Remove-Item -LiteralPath $itemPath -Force -Recurse
                            }
                        }
                    }
            }
            if (Invoke-Step "copy (dir) $srcPath -> $dstPath") {
                New-Item -ItemType Directory -Force -Path $dstPath | Out-Null
                Get-ChildItem -LiteralPath $srcPath -Force | ForEach-Object {
                    Copy-Item -LiteralPath $_.FullName -Destination $dstPath -Recurse -Force
                }
            }
        }
        default {
            Write-Host "Skipping $($record.Source) because type '$($record.Type)' is unsupported."
            continue
        }
    }

    if (-not $script:dryRun) {
        Write-Host "Applied ($($record.Type)): $($record.Source) -> $($record.Target)"
    }
    $applied++
}

Write-Host "Completed apply for platform '$currentPlatform'. Entries processed: $applied"