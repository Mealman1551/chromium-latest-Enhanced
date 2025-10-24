# install-windows.ps1 — Install or update latest Chromium and chromiumup command
$ErrorActionPreference = "Stop"

$baseUrl = "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Win_x64"
$installDir = "$env:LOCALAPPDATA\Chromium"
$appDir = Join-Path $installDir "Application"
$userDataDir = Join-Path $installDir "User Data"
$tempZip = Join-Path $env:TEMP "chromium.zip"
$installScriptPath = Join-Path $installDir "install-windows.ps1"

# Als het script nog niet in installDir staat, kopieer het daarheen
if ($MyInvocation.MyCommand.Path -ne $installScriptPath) {
    Write-Host "Copying installer to $installScriptPath..."
    if (-not (Test-Path $installDir)) { New-Item -ItemType Directory -Path $installDir | Out-Null }
    Copy-Item -Path $MyInvocation.MyCommand.Path -Destination $installScriptPath -Force
}

Write-Host "Checking latest Chromium revision..."
$latestRevision = (curl.exe -s "$baseUrl/LAST_CHANGE").Trim()
Write-Host "Latest revision: $latestRevision"

$currentRevisionFile = Join-Path $installDir "version.txt"
if (Test-Path $currentRevisionFile) {
    $currentRevision = Get-Content $currentRevisionFile -Raw
} else {
    $currentRevision = ""
}

if ($currentRevision -eq $latestRevision) {
    Write-Host "You already have the latest version ($latestRevision)."
} else {
    Write-Host "Downloading Chromium revision $latestRevision..."
    $downloadUrl = "$baseUrl/$latestRevision/chrome-win.zip"
    curl.exe -L -# -o $tempZip $downloadUrl

    Write-Host "Extracting files..."
    if (Test-Path $appDir) { Remove-Item $appDir -Recurse -Force }
    Expand-Archive -Path $tempZip -DestinationPath $installDir -Force
    if (Test-Path "$installDir\chrome-win") {
        Move-Item "$installDir\chrome-win" $appDir -Force
    }
    Remove-Item $tempZip -Force
    Set-Content $currentRevisionFile $latestRevision
}

$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$shortcutName = "Chromium (Latest).lnk"
$targetPath = Join-Path $appDir "chrome.exe"
$iconPath = $targetPath
$arguments = "--user-data-dir=`"$userDataDir`""

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

# ---- chromiumup command ----
$windowsApps = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
$chromiumUpScript = Join-Path $windowsApps "chromiumup.ps1"

@"
Write-Host 'Updating Chromium...'
& pwsh -NoProfile -ExecutionPolicy Bypass -File `"$installScriptPath`"
"@ | Out-File -Encoding UTF8 $chromiumUpScript -Force

Write-Host "Setting execution permissions for chromiumup..."
if (-not (Get-Command chromiumup -ErrorAction SilentlyContinue)) {
    $profilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    if (-not (Test-Path $profilePath)) { New-Item -ItemType File -Path $profilePath -Force | Out-Null }
    Add-Content $profilePath "`nSet-Alias chromiumup '$chromiumUpScript'"
}

Write-Host "`nChromium installed successfully!"
Write-Host "You can now update Chromium anytime by typing: chromiumup"
Write-Host "Location: $appDir"
Write-Host "User Data: $userDataDir"
