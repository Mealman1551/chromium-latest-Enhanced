# install-windows10.ps1
$ErrorActionPreference = "Stop"
Write-Host "Checking latest Chromium revision..."

$revUrl = "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Win_x64%2FLAST_CHANGE?alt=media"
$revision = (Invoke-WebRequest -Uri $revUrl -UseBasicParsing).Content.Trim()
Write-Host "Latest revision: $revision"

$zipUrl = "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Win_x64%2F$revision%2Fchrome-win.zip?alt=media"
$appDir = "$env:LOCALAPPDATA\Chromium"
$zipPath = "$env:TEMP\chromium.zip"
$extractDir = "$env:TEMP\chrome-win"

Write-Host "Downloading Chromium revision $revision..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath -UseBasicParsing
Write-Host "Download completed!"

if (Test-Path $extractDir) { Remove-Item -Recurse -Force $extractDir }
if (Test-Path $appDir) { Remove-Item -Recurse -Force $appDir }

Write-Host "Extracting files..."
Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::ExtractToDirectory($zipPath, $env:TEMP)

Write-Host "Installing Chromium..."
Move-Item "$extractDir" $appDir

Remove-Item $zipPath -Force
Write-Host "Chromium installed successfully at $appDir!"
Write-Host "Launch: $appDir\chrome.exe"
