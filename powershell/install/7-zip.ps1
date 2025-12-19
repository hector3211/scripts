$ErrorActionPreference = "Stop"

# Detect 7-Zip
$ZipInstalled = Get-ItemProperty `
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", `
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "7-Zip*" }

if ($ZipInstalled) {
    Write-Host "7-Zip already installed. Exiting."
    exit 0
}

# Download EXE
$Url = "https://www.7-zip.org/a/7z2301-x64.exe"
$Installer = "$env:TEMP\7zipInstaller.exe"

Write-Host "Downloading 7-Zip..."
curl.exe -L --fail $Url -o $Installer

if (!(Test-Path $Installer)) {
    Write-Error "Download failed."
    exit 1
}

Write-Host "Installing 7-Zip in background..."
Start-Job -ScriptBlock {
    param($InstallerPath)
    Start-Process -FilePath $InstallerPath -ArgumentList "/S" -NoNewWindow -Wait
    Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue
} -ArgumentList $Installer

Write-Host "7-Zip installer started."
exit 0

