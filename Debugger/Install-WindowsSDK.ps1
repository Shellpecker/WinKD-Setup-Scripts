# Ensure the script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Script is not running as Administrator. Relaunching with elevated privileges..."
    $scriptPath = $MyInvocation.MyCommand.Definition
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# Define the stable FWLink URL that always points to the latest Windows SDK installer.
$installerUrl = "https://go.microsoft.com/fwlink/p/?linkid=2120843"

# Define a temporary download path for the installer
$installerPath = Join-Path $env:TEMP "WindowsSDKSetup.exe"

Write-Host "Downloading the latest Windows SDK installer..."
try {
    Invoke-WebRequest -Uri $installerUrl -OutFile $installerPath -UseBasicParsing
    Write-Host "Download complete: $installerPath"
} catch {
    Write-Error "Error downloading the installer from $installerUrl"
    exit 1
}

Write-Host "Starting Windows SDK installation. This may take a few minutes..."

# Run the installer silently. The arguments /quiet and /norestart ensure an unattended installation without automatic reboot.
$arguments = "/quiet /norestart"
try {
    $process = Start-Process -FilePath $installerPath -ArgumentList $arguments -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        Write-Error "Installation exited with code $($process.ExitCode). Please check the installer logs for more details."
        exit $process.ExitCode
    }
} catch {
    Write-Error "Failed to start the Windows SDK installer."
    exit 1
}

Write-Host "Windows SDK installation completed successfully."

# Clean up the installer file from the temporary folder
try {
    Remove-Item $installerPath -Force
    Write-Host "Installer file removed from: $installerPath"
} catch {
    Write-Warning "Unable to remove the installer file. Please delete it manually: $installerPath"
}

Write-Host "Installation complete. If required, please reboot your machine."
