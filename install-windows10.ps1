# install-windows10.ps1 — Chromium Latest Enhanced installer for Windows 10+
$ErrorActionPreference = "Stop"

Write-Host "Checking latest Chromium revision..."

$lastChangeUrl = "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Win%2FLAST_CHANGE?alt=media"
$zipBase = "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Win%2F{REV}%2Fchrome-win.zip?alt=media"

$wc = New-Object System.Net.WebClient
$revision = $wc.DownloadString($lastChangeUrl).Trim()
Write-Host "Latest revision: $revision"

$tempZip = Join-Path $env:TEMP "chromium-latest.zip"
$zipUrl = $zipBase -replace "{REV}", $revision

Write-Host "Downloading Chromium revision $revision..."
$wc.DownloadFile($zipUrl, $tempZip)
Write-Host "Download completed!"

$installDir = "$env:LOCALAPPDATA\Chromium"
$appDir = Join-Path $installDir "Application"
if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir | Out-Null }

Write-Host "Extracting files..."
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($tempZip, $installDir)

# Fix: remove old Application folder first to avoid overwrite errors
if (Test-Path $appDir) {
    Write-Host "Removing previous Chromium application..."
    Remove-Item $appDir -Recurse -Force
}

# Move chrome-win contents to Application
$chromeWin = Join-Path $installDir "chrome-win"
if (Test-Path $chromeWin) {
    Move-Item "$chromeWin\*" $appDir -Force
    Remove-Item $chromeWin -Recurse -Force
}

Remove-Item $tempZip -Force

Write-Host "Creating shortcuts..."
$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$shortcutName = "Chromium (Latest).lnk"
$targetPath = Join-Path $appDir "chrome.exe"

$wsh = New-Object -ComObject WScript.Shell
foreach ($path in @($desktop, $startMenu)) {
    $shortcut = $wsh.CreateShortcut((Join-Path $path $shortcutName))
    $shortcut.TargetPath = $targetPath
    $shortcut.Save()
}

Write-Host "Registering chromiumup command..."
$profileDir = "$env:USERPROFILE\Documents\PowerShell"
if (-not (Test-Path $profileDir)) { New-Item -ItemType Directory -Path $profileDir | Out-Null }
$profilePath = Join-Path $profileDir "Microsoft.PowerShell_profile.ps1"

$chromiumUpScript = "$env:LOCALAPPDATA\Microsoft\WindowsApps\chromiumup.ps1"
@"
Write-Host 'Updating Chromium...'
\$wc = New-Object System.Net.WebClient
\$revision = \$wc.DownloadString('$lastChangeUrl').Trim()
Write-Host ('Latest revision: ' + \$revision)
\$zipUrl = '$zipBase' -replace '{REV}', \$revision
\$tempZip = Join-Path \$env:TEMP 'chromium-latest.zip'
Write-Host 'Downloading Chromium revision ' + \$revision + '...'
\$wc.DownloadFile(\$zipUrl, \$tempZip)
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory(\$tempZip, '$installDir', \$true)
Remove-Item \$tempZip -Force
Write-Host 'Chromium updated to revision ' + \$revision
"@ | Set-Content $chromiumUpScript -Encoding UTF8

Set-Content -Path $profilePath -Value ((Get-Content $profilePath -ErrorAction SilentlyContinue) + "`nSet-Alias chromiumup `"$chromiumUpScript`"") -Force

Write-Host "Cleaning up..."
Remove-Variable wc

Write-Host "`nChromium installed successfully!"
Write-Host "You can launch it from Start Menu or Desktop."
Write-Host "To update, type: chromiumup"
