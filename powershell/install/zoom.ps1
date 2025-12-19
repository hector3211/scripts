$ErrorActionPreference = "Stop"

# Detect if Zoom Workplace is already installed
$ZoomInstalled = Get-ItemProperty `
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", `
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "Zoom*" }

if ($ZoomInstalled) {
    Write-Host "Zoom Workplace already installed. Exiting."
    exit 0
}

# Download latest Zoom Workplace MSI installer
$Url = "https://zoom.us/client/latest/ZoomInstallerFull.msi?archType=x64"
$Installer = "$env:TEMP\ZoomInstallerFull.msi"

Write-Host "Downloading Zoom Workplace MSI installer..."
curl.exe -L --fail $Url -o $Installer

if (!(Test-Path $Installer)) {
    Write-Error "Download failed."
    exit 1
}

Write-Host "Launching Zoom Workplace installer in background..."

# Start a background job for non‑blocking install and cleanup
Start‑Job ‑ScriptBlock {
    param($InstallerPath)

    # Silent install: /quiet /qn /norestart
    Start‑Process ‑FilePath "msiexec.exe" `
        ‑ArgumentList "/i `"$InstallerPath`" /quiet /qn /norestart" `
        ‑NoNewWindow ‑Wait

    # Cleanup after install finishes
    Remove‑Item $InstallerPath ‑Force ‑ErrorAction SilentlyContinue
} ‑ArgumentList $Installer

Write‑Host "Zoom Workplace installer started in background. Script continues."
exit 0

