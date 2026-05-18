param(
    [Parameter(Mandatory = $true)]
    [string]$GamePcDir,

    [string]$CuePath,

    [ValidatePattern('^[A-Z]$')]
    [string]$DriveLetter = "D"
)

$ErrorActionPreference = "Stop"

$gameExe = Join-Path $GamePcDir "IGI.exe"
if (!(Test-Path -LiteralPath $gameExe -PathType Leaf)) {
    throw "IGI.exe not found in: $GamePcDir"
}

if ($CuePath) {
    if (!(Test-Path -LiteralPath $CuePath -PathType Leaf)) {
        throw "CUE file does not exist: $CuePath"
    }

    $mountCandidates = @(
        "${env:ProgramFiles(x86)}\WinCDEmu\batchmnt64.exe",
        "$env:ProgramFiles\WinCDEmu\batchmnt64.exe"
    )
    $mounter = $mountCandidates | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf } | Select-Object -First 1
    if ($null -eq $mounter) {
        throw "WinCDEmu batchmnt64.exe was not found. Install WinCDEmu or launch without -CuePath."
    }

    & $mounter $CuePath "$DriveLetter`:" | Out-Null
}

Start-Process -FilePath $gameExe -WorkingDirectory $GamePcDir
