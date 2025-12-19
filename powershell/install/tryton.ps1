$ErrorActionPreference = "Stop"

# Prompt user for Tryton version (e.g., 7.0.27)
$TrytonVersion = Read-Host "Enter the Tryton version to install (e.g., 7.0.27)"
if ([string]::IsNullOrWhiteSpace($TrytonVersion)) {
    Write-Error "No version entered. Exiting."
    exit 1
}

# Detect if Tryton is already installed
$TrytonInstalled = Get-ItemProperty `
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", `
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "Tryton*" }

if ($TrytonInstalled) {
    Write-Host "Tryton already installed. Exiting."
    exit 0
}

# Construct the official installer URL dynamically
$Url = "https://downloads.tryton.org/7.0/tryton-64bit-$TrytonVersion.exe"
$Installer = "$env:TEMP\Tryton-64bit-$TrytonVersion.exe"

Write-Host "Downloading Tryton $TrytonVersion (64-bit)..."
curl.exe -L --fail $Url -o $Installer

if (!(Test-Path $Installer)) {
    Write-Error "Download failed. Check if version $TrytonVersion exists."
    exit 1
}

Write-Host "Launching Tryton installer in background..."

# Start a background job for non-blocking install and cleanup
Start-Job -ScriptBlock {
    param($InstallerPath)

    # Silent install (NSIS-style)
    Start-Process -FilePath $InstallerPath `
        -ArgumentList "/S" `
        -NoNewWindow `
        -Wait

    # Cleanup installer after installation completes
    Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue
} -ArgumentList $Installer

Write-Host "Tryton installer started in background. Script continues."
exit 0

