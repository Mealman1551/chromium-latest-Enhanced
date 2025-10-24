# uninstall-windows.ps1 — Remove Chromium installation, shortcuts, and chromiumup command
$ErrorActionPreference = "Stop"

$installDir = "$env:LOCALAPPDATA\Chromium"
$appDir = Join-Path $installDir "Application"
$userDataDir = Join-Path $installDir "User Data"
$desktop = [Environment]::GetFolderPath("Desktop")
$startMenu = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$shortcutName = "Chromium (Latest).lnk"

# Vraag of gebruiker ook user data wil verwijderen
$removeUserData = Read-Host "Do you want to remove all user data as well? (y/N)"
$removeUserData = $removeUserData.ToLower() -eq "y"

function Remove-Shortcut($path) {
    if (Test-Path $path) {
        Remove-Item $path -Force
        Write-Host "Removed shortcut: $path"
    }
}

# Verwijder Chromium applicatie
Write-Host "Removing Chromium application..."
if (Test-Path $appDir) { Remove-Item $appDir -Recurse -Force }

# Verwijder user data
if ($removeUserData -and (Test-Path $userDataDir)) {
    Write-Host "Removing user data..."
    Remove-Item $userDataDir -Recurse -Force
}

# Verwijder snelkoppelingen
Remove-Shortcut (Join-Path $desktop $shortcutName)
Remove-Shortcut (Join-Path $startMenu $shortcutName)

# Verwijder versie bestand
$versionFile = Join-Path $installDir "version.txt"
if (Test-Path $versionFile) { Remove-Item $versionFile -Force }

# Verwijder install-windows.ps1
$installerPath = Join-Path $installDir "install-windows.ps1"
if (Test-Path $installerPath) { Remove-Item $installerPath -Force }

# Verwijder chromiumup script
$chromiumUpScript = "$env:LOCALAPPDATA\Microsoft\WindowsApps\chromiumup.ps1"
if (Test-Path $chromiumUpScript) { Remove-Item $chromiumUpScript -Force }

# Verwijder alias uit PowerShell profiel
$profilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
if (Test-Path $profilePath) {
    $profileContent = Get-Content $profilePath | Where-Object { $_ -notmatch "Set-Alias chromiumup" }
    Set-Content -Path $profilePath -Value $profileContent
}

# Indien map leeg is, verwijder deze
if ((Test-Path $installDir) -and ((Get-ChildItem $installDir | Measure-Object).Count -eq 0)) {
    Remove-Item $installDir -Force
}

Write-Host "`nChromium and chromiumup uninstalled successfully!"
