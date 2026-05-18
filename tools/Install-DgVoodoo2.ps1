param(
    [Parameter(Mandatory = $true)]
    [string]$GamePcDir,

    [string]$Version = "latest"
)

$ErrorActionPreference = "Stop"

if (!(Test-Path -LiteralPath $GamePcDir -PathType Container)) {
    throw "Game PC directory does not exist: $GamePcDir"
}

$headers = @{ "User-Agent" = "IGIPatch-setup" }
if ($Version -eq "latest") {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/dege-diosg/dgVoodoo2/releases/latest" -Headers $headers
} else {
    $release = Invoke-RestMethod -Uri "https://api.github.com/repos/dege-diosg/dgVoodoo2/releases/tags/$Version" -Headers $headers
}

$asset = $release.assets | Where-Object { $_.name -match '^dgVoodoo2_.*\.zip$' -and $_.name -notmatch '_dbg|_dev' } | Select-Object -First 1
if ($null -eq $asset) {
    throw "Could not find a standard dgVoodoo2 ZIP asset for $($release.tag_name)."
}

$workDir = Join-Path $env:TEMP "IGIPatch-dgVoodoo2"
$zipPath = Join-Path $workDir $asset.name
$extractDir = Join-Path $workDir "extract"

New-Item -ItemType Directory -Force -Path $workDir | Out-Null
if (Test-Path -LiteralPath $extractDir) {
    Remove-Item -LiteralPath $extractDir -Recurse -Force
}

Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath -Headers $headers
Expand-Archive -LiteralPath $zipPath -DestinationPath $extractDir

$required = @(
    "MS\x86\DDraw.dll",
    "MS\x86\D3DImm.dll",
    "dgVoodoo.conf"
)

foreach ($relative in $required) {
    $source = Join-Path $extractDir $relative
    if (!(Test-Path -LiteralPath $source)) {
        throw "dgVoodoo2 package did not contain expected file: $relative"
    }
    Copy-Item -LiteralPath $source -Destination (Join-Path $GamePcDir (Split-Path $relative -Leaf)) -Force
}

Write-Host "Installed dgVoodoo2 $($release.tag_name) DirectX wrapper files to $GamePcDir"
