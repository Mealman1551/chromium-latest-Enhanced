# uninstall-windows.ps1 — Remove Chromium installation, shortcuts and chromiumup command
$ErrorActionPreference = "Stop"

$installDir = "$env:LOCALAPPDATA\Chromium"
$appDir = Join-Path $installDir "Application"
$userDataDir = Join-Path $installDir "User Data"
$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$shortcutName = "Chromium (Latest).lnk"
$windowsApps = "$env:LOCALAPPDATA\Microsoft\WindowsApps"
$chromiumUpScript = Join-Path $windowsApps "chromiumup.ps1"

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

Remove-Shortcut (Join-Path $desktop $shortcutName)
Remove-Shortcut (Join-Path $startMenu $shortcutName)

$versionFile = Join-Path $installDir "version.txt"
if (Test-Path $versionFile) { Remove-Item $versionFile -Force }

if ((Test-Path $installDir) -and ((Get-ChildItem $installDir | Measure-Object).Count -eq 0)) {
    Remove-Item $installDir -Force
    Write-Host "Removed Chromium directory."
}

# Remove chromiumup command
if (Test-Path $chromiumUpScript) {
    Remove-Item $chromiumUpScript -Force
    Write-Host "Removed chromiumup command."
}

# Clean alias from PowerShell profile
$profilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
if (Test-Path $profilePath) {
    $lines = Get-Content $profilePath | Where-Object {$_ -notmatch "Set-Alias chromiumup"}
    Set-Content $profilePath $lines
    Write-Host "Removed chromiumup alias from PowerShell profile."
}

Write-Host "`nChromium uninstalled successfully!"
