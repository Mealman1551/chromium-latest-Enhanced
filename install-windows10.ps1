# install-windows10.ps1 — Install or update Chromium + chromiumup (Windows 10 safe mode)
$ErrorActionPreference = "Stop"

$baseUrl = "https://commondatastorage.googleapis.com/chromium-browser-snapshots/Win_x64"
$installDir = "$env:LOCALAPPDATA\Chromium"
$appDir = Join-Path $installDir "Application"
$userDataDir = Join-Path $installDir "User Data"
$tempZip = Join-Path $env:TEMP "chromium-latest.zip"

# --- Download & update Chromium ---
Write-Host "Checking latest Chromium revision..."
$latestRevision = (Invoke-WebRequest -UseBasicParsing "$baseUrl/LAST_CHANGE").Content.Trim()
Write-Host "Latest revision: $latestRevision"

$installerPath = Join-Path $installDir "install-windows10.ps1"
$currentRevisionFile = Join-Path $installDir "version.txt"
if (Test-Path $currentRevisionFile) {
    $currentRevision = Get-Content $currentRevisionFile -Raw
} else {
    $currentRevision = ""
}

if ($currentRevision -ne $latestRevision) {
    Write-Host "Downloading Chromium revision $latestRevision..."
    $downloadUrl = "$baseUrl/$latestRevision/chrome-win.zip"
    Invoke-WebRequest -Uri $downloadUrl -OutFile $tempZip -UseBasicParsing

    Write-Host "Extracting files..."
    if (-Not (Test-Path $appDir)) { New-Item -ItemType Directory -Path $appDir | Out-Null }

    $shell = New-Object -ComObject Shell.Application
    $zip = $shell.NameSpace($tempZip)
    $dest = $shell.NameSpace($appDir)
    $dest.CopyHere($zip.Items(), 20+4) # 20 = respond with Yes to all, 4 = Do not display progress

    Remove-Item $tempZip -Force
    Set-Content $currentRevisionFile $latestRevision
}

# --- Create shortcuts ---
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

# --- Copy installer to install dir ---
Write-Host "Copying installer to $installerPath..."
if (-not (Test-Path $installerPath) -or ($MyInvocation.MyCommand.Path -ne $installerPath)) {
    Copy-Item -Path $MyInvocation.MyCommand.Path -Destination $installerPath -Force
}

# --- chromiumup command ---
$windowsApps = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
if (-not (Test-Path $windowsApps)) { New-Item -ItemType Directory -Path $windowsApps | Out-Null }
$chromiumUpScript = Join-Path $windowsApps "chromiumup.ps1"

$chromiumUpContent = @"
Write-Host 'Updating Chromium...'
`$installer = '$installerPath'
if (-not (Test-Path `$installer)) {
    Write-Error "install-windows10.ps1 not found at `$installer"
    exit 1
}
& powershell -NoProfile -ExecutionPolicy Bypass -File `$installer
"@

$chromiumUpContent | Out-File -Encoding UTF8 $chromiumUpScript -Force

# --- Add alias to PowerShell profile ---
$profilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
if (-not (Test-Path $profilePath)) { New-Item -ItemType File -Path $profilePath -Force | Out-Null }

$aliasLine = "Set-Alias chromiumup '$chromiumUpScript'"
$profileContent = Get-Content $profilePath -Raw
if ($profileContent -notmatch [regex]::Escape($aliasLine)) {
    Add-Content $profilePath "`n$aliasLine"
}

Write-Host "`nChromium installed successfully!"
Write-Host "You can now update Chromium anytime by typing: chromiumup"
Write-Host "Location: $appDir"
Write-Host "User Data: $userDataDir"
