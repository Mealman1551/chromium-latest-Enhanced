# install.ps1 — Install or update latest Chromium on Windows
# Target: C:\Users\<user>\AppData\Local\Chromium

$ErrorActionPreference = "Stop"

$baseUrl = "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Win_x64"
$installDir = "$env:LOCALAPPDATA\Chromium"
$appDir = Join-Path $installDir "Application"
$userDataDir = Join-Path $installDir "User Data"
$tempZip = Join-Path $env:TEMP "chromium.zip"

Write-Host "Checking latest Chromium revision..."
$latestRevision = (curl.exe -s "$baseUrl/LAST_CHANGE").Trim()
Write-Host "Latest revision: $latestRevision"

# Determine current revision
$currentRevisionFile = Join-Path $installDir "version.txt"
if (Test-Path $currentRevisionFile) {
    $currentRevision = Get-Content $currentRevisionFile -Raw
} else {
    $currentRevision = ""
}

if ($currentRevision -eq $latestRevision) {
    Write-Host "You already have the latest version ($latestRevision)."
    exit 0
}

Write-Host "Downloading Chromium revision $latestRevision..."
$downloadUrl = "$baseUrl/$latestRevision/chrome-win.zip"
curl.exe -L -# -o $tempZip $downloadUrl

Write-Host "Extracting files..."
if (Test-Path $appDir) { Remove-Item $appDir -Recurse -Force }
Expand-Archive -Path $tempZip -DestinationPath $installDir -Force

# Move extracted folder to Application
if (Test-Path "$installDir\chrome-win") {
    Move-Item "$installDir\chrome-win" $appDir -Force
}

# Clean up
Remove-Item $tempZip -Force
Set-Content $currentRevisionFile $latestRevision

# Paths for shortcuts
$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$shortcutName = "Chromium (Latest).lnk"
$targetPath = Join-Path $appDir "chrome.exe"
$iconPath = $targetPath
$arguments = "--user-data-dir=`"$userDataDir`""

# Create shortcut function
function Create-Shortcut($path) {
    $WshShell = New-Object -ComObject WScript.Shell
    $shortcut = $WshShell.CreateShortcut($path)
    $shortcut.TargetPath = $targetPath
    $shortcut.Arguments = $arguments
    $shortcut.Description = "Chromium (Latest Snapshot)"
    $shortcut.IconLocation = $iconPath
    $shortcut.WorkingDirectory = $appDir
    $shortcut.Save()
}

Write-Host "Creating desktop and Start Menu shortcuts..."
Create-Shortcut (Join-Path $desktop $shortcutName)
Create-Shortcut (Join-Path $startMenu $shortcutName)

Write-Host "`nChromium installed successfully!"
Write-Host "Location: $appDir"
Write-Host "User Data: $userDataDir"
Write-Host "Shortcuts created on Desktop and Start Menu."
