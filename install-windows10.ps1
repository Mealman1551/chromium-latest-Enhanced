# install-windows10.ps1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

Write-Host "Checking latest Chromium revision..."
$lastChangeUrl = "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Win_x64%2FLAST_CHANGE?alt=media"
$revision = (Invoke-WebRequest -UseBasicParsing -Uri $lastChangeUrl).Content.Trim()
Write-Host "Latest revision: $revision"

$zipUrl = "https://www.googleapis.com/download/storage/v1/b/chromium-browser-snapshots/o/Win_x64%2F$revision%2Fchrome-win.zip?alt=media"
$tempZip = "$env:TEMP\chromium-$revision.zip"
$installDir = "$env:LOCALAPPDATA\Chromium"
$exePath = Join-Path $installDir "chrome-win\chrome.exe"

if (Test-Path $installDir) {
    Write-Host "Removing previous version..."
    Remove-Item -Recurse -Force $installDir
}

Write-Host "Downloading Chromium revision $revision..."
Invoke-WebRequest -Uri $zipUrl -OutFile $tempZip -UseBasicParsing

Write-Host "Extracting files..."
Expand-Archive -LiteralPath $tempZip -DestinationPath $installDir

Write-Host "Creating shortcuts..."
$desktopShortcut = [IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "Chromium (Latest).lnk")
$startMenuShortcut = [IO.Path]::Combine($env:APPDATA, "Microsoft\Windows\Start Menu\Programs\Chromium (Latest).lnk")

$WshShell = New-Object -ComObject WScript.Shell
foreach ($shortcut in @($desktopShortcut, $startMenuShortcut)) {
    $link = $WshShell.CreateShortcut($shortcut)
    $link.TargetPath = $exePath
    $link.IconLocation = $exePath
    $link.Save()
}

Write-Host "Copying installer for future updates..."
Copy-Item -Path $MyInvocation.MyCommand.Definition -Destination "$installDir\install-windows10.ps1" -Force

$updateScript = @"
Write-Host 'Updating Chromium...'
& '$installDir\install-windows10.ps1'
"@
$updateScriptPath = "$env:LOCALAPPDATA\Microsoft\WindowsApps\chromiumup.ps1"
$updateScript | Out-File -Encoding UTF8 -FilePath $updateScriptPath -Force

# Voeg alias toe aan profiel (voor PowerShell 5.1)
$profilePath = $PROFILE
if (-not (Test-Path $profilePath)) {
    New-Item -ItemType File -Path $profilePath -Force | Out-Null
}
$aliasLine = "Set-Alias chromiumup '$updateScriptPath'"
if (-not (Select-String -Path $profilePath -SimpleMatch $aliasLine -ErrorAction SilentlyContinue)) {
    Add-Content -Path $profilePath -Value "`n$aliasLine"
}

Write-Host "Chromium installed successfully!"
Write-Host "You can now run 'chromiumup' in PowerShell to update it."
