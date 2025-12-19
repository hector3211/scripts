$ErrorActionPreference = "Stop"

# Detect if Adobe Reader is already installed
$ReaderInstalled = Get-ItemProperty `
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*", `
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" `
    -ErrorAction SilentlyContinue |
    Where-Object { $_.DisplayName -like "Adobe Acrobat Reader*" }

if ($ReaderInstalled) {
    Write-Host "Adobe Acrobat Reader already installed. Exiting."
    exit 0
}

# Adobe Online Installer (small web installer, latest version)
$Url = "https://get.adobe.com/reader/download/?installer=Reader_DC_2025_Web.exe&standalone=0"
$Installer = "$env:TEMP\AcroRdrDC_Online.exe"

Write-Host "Downloading Adobe Acrobat Reader DC (online installer)..."
curl.exe -L --fail $Url -o $Installer

if (!(Test-Path $Installer)) {
    Write-Error "Download failed."
    exit 1
}

Write-Host "Launching Adobe Acrobat Reader online installer in background..."

# Start background job for non-blocking install
Start-Job -ScriptBlock {
    param($InstallerPath)

    # Silent install, accept EULA, suppress reboot
    Start-Process -FilePath $InstallerPath `
        -ArgumentList "/sAll /rs /rps /msi EULA_ACCEPT=YES" `
        -NoNewWindow `
        -Wait

    # Cleanup installer after completion
    Remove-Item $InstallerPath -Force -ErrorAction SilentlyContinue
} -ArgumentList $Installer

Write-Host "Adobe installer started in background. Script continues."
exit 0

