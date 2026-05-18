param(
    [Parameter(Mandatory = $true)]
    [string]$GamePcDir
)

$ErrorActionPreference = "Stop"

function Add-Result {
    param(
        [string]$Check,
        [ValidateSet("OK", "WARN", "FAIL")]
        [string]$Status,
        [string]$Detail
    )

    [pscustomobject]@{
        Check = $Check
        Status = $Status
        Detail = $Detail
    }
}

if (!(Test-Path -LiteralPath $GamePcDir -PathType Container)) {
    Add-Result "Game directory" "FAIL" "Directory does not exist: $GamePcDir"
    exit 1
}

$gameExe = Join-Path $GamePcDir "IGI.exe"
if (Test-Path -LiteralPath $gameExe -PathType Leaf) {
    Add-Result "Game executable" "OK" "Found IGI.exe"
} else {
    Add-Result "Game executable" "FAIL" "IGI.exe not found in $GamePcDir"
}

$ddraw = Join-Path $GamePcDir "DDraw.dll"
$d3dimm = Join-Path $GamePcDir "D3DImm.dll"
if ((Test-Path -LiteralPath $ddraw -PathType Leaf) -and (Test-Path -LiteralPath $d3dimm -PathType Leaf)) {
    Add-Result "DirectX wrapper" "OK" "Found DDraw.dll and D3DImm.dll"
} else {
    Add-Result "DirectX wrapper" "WARN" "Missing dgVoodoo2 DirectX wrapper DLLs. Run tools\Install-DgVoodoo2.ps1 if you see DDERR_UNSUPPORTED."
}

$codecKeys = @(
    "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Drivers32",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows NT\CurrentVersion\Drivers32"
)
$codecValues = foreach ($key in $codecKeys) {
    if (Test-Path $key) {
        $value = (Get-ItemProperty -Path $key -Name "vidc.iv50" -ErrorAction SilentlyContinue)."vidc.iv50"
        if ($value) { $value }
    }
}
$codecFiles = @(
    "$env:WINDIR\System32\ir50_32.dll",
    "$env:WINDIR\SysWOW64\ir50_32.dll"
) | Where-Object { Test-Path -LiteralPath $_ -PathType Leaf }

if ($codecValues -or $codecFiles) {
    Add-Result "Indeo Video 5" "OK" "IV50 codec registration or codec DLL was found."
} else {
    Add-Result "Indeo Video 5" "WARN" "IV50 codec was not detected. Intro videos may not play; install/register a trusted Indeo Video 5 codec if needed."
}

try {
    Add-Type -AssemblyName System.Windows.Forms
    $bounds = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds
    if ($bounds.Width -gt 2048 -or $bounds.Height -gt 2048) {
        Add-Result "Display size" "WARN" "Primary display is $($bounds.Width)x$($bounds.Height). Use dgVoodoo2 or another wrapper for resolutions above DirectX 7's 2048 limit."
    } else {
        Add-Result "Display size" "OK" "Primary display is $($bounds.Width)x$($bounds.Height)."
    }
} catch {
    Add-Result "Display size" "WARN" "Could not query primary display size: $($_.Exception.Message)"
}

$overlayNames = "RTSS", "RTSSHooksLoader32", "RTSSHooksLoader64", "MSIAfterburner", "Discord", "steam", "GameBar", "NVIDIA Share"
$runningOverlays = Get-Process -ErrorAction SilentlyContinue | Where-Object {
    $name = $_.ProcessName
    $overlayNames | Where-Object { $name -like "$_*" }
} | Select-Object -ExpandProperty ProcessName -Unique

if ($runningOverlays) {
    Add-Result "Overlay processes" "WARN" "Possible overlay/hook processes running: $($runningOverlays -join ', '). Disable them if missions crash while loading."
} else {
    Add-Result "Overlay processes" "OK" "No common overlay/hook processes detected."
}
