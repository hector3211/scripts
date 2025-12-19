$ErrorActionPreference = "Stop"

# Detect Teams
$TeamsInstalled = Get-ItemProperty `
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", `
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "Microsoft Teams*" }

if ($TeamsInstalled) {
    Write-Host "Microsoft Teams already installed. Exiting."
    exit 0
}

# Download MSI
$Url = "https://aka.ms/teams64bitmsi"
$Installer = "$env:TEMP\TeamsInstaller.msi"

Write-Host "Downloading Microsoft Teams..."
curl.exe -L --fail $Url -o $Installer

if (!(Test-Path $Installer)) {
    Write-Error "Download failed."
    exit 1
}

Write-Host "Installing Microsoft Teams in background..."
Start-Job -ScriptBlock {
    param($InstallerPath)
    Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$InstallerPath`" /quiet /qn /norestart" -NoNewWindow -Wait
    Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue
} -ArgumentList $Installer

Write-Host "Microsoft Teams installer started."
exit 0

