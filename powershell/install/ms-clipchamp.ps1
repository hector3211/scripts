$ErrorActionPreference = "Stop"

# Detect Clipchamp
$ClipchampInstalled = Get-ItemProperty `
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", `
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "Clipchamp*" }

if ($ClipchampInstalled) {
    Write-Host "Clipchamp already installed. Exiting."
    exit 0
}

# Download EXE
$Url = "https://aka.ms/clipchampinstaller"
$Installer = "$env:TEMP\ClipchampInstaller.exe"

Write-Host "Downloading Clipchamp..."
curl.exe -L --fail $Url -o $Installer

if (!(Test-Path $Installer)) {
    Write-Error "Download failed."
    exit 1
}

Write-Host "Installing Clipchamp in background..."
Start-Job -ScriptBlock {
    param($InstallerPath)
    Start-Process -FilePath $InstallerPath -ArgumentList "/silent /install" -NoNewWindow -Wait
    Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue
} -ArgumentList $Installer

Write-Host "Clipchamp installer started."
exit 0

