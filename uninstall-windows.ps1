# uninstall.ps1 — Remove Chromium installation and shortcuts
$ErrorActionPreference = "Stop"

$installDir = "$env:LOCALAPPDATA\Chromium"
$appDir = Join-Path $installDir "Application"
$userDataDir = Join-Path $installDir "User Data"
$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$shortcutName = "Chromium (Latest).lnk"

# Ask user if they want to remove user data
$removeUserData = Read-Host "Do you want to remove all user data as well? (y/N)"
$removeUserData = $removeUserData.ToLower() -eq "y"

function Remove-Shortcut($path) {
    if (Test-Path $path) {
        Remove-Item $path -Force
        Write-Host "Removed shortcut: $path"
    }
}

Write-Host "Removing Chromium application..."
if (Test-Path $appDir) { Remove-Item $appDir -Recurse -Force }

if ($removeUserData -and (Test-Path $userDataDir)) {
    Write-Host "Removing user data..."
    Remove-Item $userDataDir -Recurse -Force
}

# Remove shortcuts
Remove-Shortcut (Join-Path $desktop $shortcutName)
Remove-Shortcut (Join-Path $startMenu $shortcutName)

# Remove version file if exists
$versionFile = Join-Path $installDir "version.txt"
if (Test-Path $versionFile) { Remove-Item $versionFile -Force }

# If installDir is now empty, remove it
if ((Test-Path $installDir) -and ((Get-ChildItem $installDir | Measure-Object).Count -eq 0)) {
    Remove-Item $installDir -Force
}


Write-Host "`nChromium uninstalled successfully!"
