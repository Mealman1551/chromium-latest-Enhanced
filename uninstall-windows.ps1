# uninstall-windows.ps1 — Remove Chromium installation, shortcuts, and chromiumup command
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

# Remove version file
$versionFile = Join-Path $installDir "version.txt"
if (Test-Path $versionFile) { Remove-Item $versionFile -Force }

# Remove the installer script itself
$installScript = Join-Path $installDir "install-windows.ps1"
if (Test-Path $installScript) { Remove-Item $installScript -Force }

# Remove chromiumup command
$chromiumUpScript = "$env:LOCALAPPDATA\Microsoft\WindowsApps\chromiumup.ps1"
if (Test-Path $chromiumUpScript) { Remove-Item $chromiumUpScript -Force; Write-Host "Removed chromiumup command." }

# Remove alias from profile if present
$profilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
if (Test-Path $profilePath) {
    (Get-Content $profilePath) | Where-Object { $_ -notmatch 'Set-Alias chromiumup' } | Set-Content $profilePath
}

# Remove installDir if empty
if ((Test-Path $installDir) -and ((Get-ChildItem $installDir | Measure-Object).Count -eq 0)) {
    Remove-Item $installDir -Force
}

Write-Host "`nChromium uninstalled successfully!"
