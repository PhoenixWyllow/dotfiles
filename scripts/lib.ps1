<#
.SYNOPSIS
Dotfiles manifest utilities and helpers.

.DESCRIPTION
Provides core functions for parsing manifest.yaml, detecting platform, expanding paths,
and managing dotfiles deployment across Windows and Linux.

Functions:
- Get-CurrentPlatform: Detect current platform (windows)
- Expand-HomePath: Convert ~/ paths to full user home path
- Test-PlatformMatch: Check if platform matches entry filters
- Get-ManifestRecords: Parse manifest.yaml into deployment records
- Strip-Quotes: Remove surrounding quotes from YAML values

.NOTES
For internal use by apply.ps1, capture.ps1, doctor.ps1, bootstrap-git-aliases.ps1
#>

Set-StrictMode -Version Latest

$script:RepoRoot = Split-Path -Parent $PSScriptRoot
$script:ManifestPath = if ($env:MANIFEST_PATH) { $env:MANIFEST_PATH } else { Join-Path $script:RepoRoot 'manifest.yaml' }

function Strip-Quotes {
    param([string]$Value)

    $trimmed = $Value.Trim()
    if ($trimmed.Length -ge 2 -and $trimmed.StartsWith('"') -and $trimmed.EndsWith('"')) {
        return $trimmed.Substring(1, $trimmed.Length - 2)
    }

    return $trimmed
}

function Get-CurrentPlatform {
    return 'windows'
}

function Expand-HomePath {
    param([string]$Path)

    if ($Path -eq '~') {
        return $HOME
    }

    if ($Path.StartsWith('~/')) {
        $relative = $Path.Substring(2) -replace '/', [IO.Path]::DirectorySeparatorChar
        return Join-Path $HOME $relative
    }

    return $Path
}

function Test-PlatformMatch {
    param(
        [string]$CurrentPlatform,
        [string]$Platforms
    )

    if ($Platforms -eq 'all') {
        return $true
    }

    return (($Platforms -replace '\s', '') -split ',') -contains $CurrentPlatform
}

function Get-ManifestRecords {
    if (-not (Test-Path -LiteralPath $script:ManifestPath)) {
        throw "Manifest not found: $script:ManifestPath"
    }

    $currentSection = 'entries'
    $source = $null
    $target = $null
    $type = $null
    $mode = $null
    $records = New-Object System.Collections.Generic.List[object]

    $emitRecord = {
        if (-not $source -and -not $target) {
            return
        }

        if (-not $source -or -not $target) {
            throw "Malformed manifest entry near source='$source'"
        }

        $platforms = if ($currentSection -eq 'entries') { 'all' } else { $currentSection }
        $records.Add([pscustomobject]@{
            Source = $source
            Target = $target
            Platforms = $platforms
            Type = if ($type) { $type } else { 'file' }
            Mode = if ($mode) { $mode } else { 'copy' }
        })
    }

    foreach ($rawLine in Get-Content -LiteralPath $script:ManifestPath) {
        $line = $rawLine.Trim()
        if (-not $line -or $line.StartsWith('#')) {
            continue
        }

        if ($rawLine -match '^[A-Za-z]') {
            & $emitRecord
            $source = $null
            $target = $null
            $type = $null
            $mode = $null
            $currentSection = $line.TrimEnd(':')
            continue
        }

        switch -Regex ($line) {
            '^- source:\s*(.+)$' {
                & $emitRecord
                $source = Strip-Quotes $Matches[1]
                $target = $null
                $type = $null
                $mode = $null
                continue
            }
            '^target:\s*(.+)$' {
                $target = Strip-Quotes $Matches[1]
                continue
            }
            '^type:\s*(.+)$' {
                $type = Strip-Quotes $Matches[1]
                continue
            }
            '^mode:\s*(.+)$' {
                $mode = Strip-Quotes $Matches[1]
                continue
            }
        }
    }

    & $emitRecord
    return $records
}