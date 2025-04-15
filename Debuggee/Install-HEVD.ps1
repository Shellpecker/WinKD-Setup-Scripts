# Script to download, extract, and install HEVD.sys as a persistent driver service

$zipUrl = "https://github.com/hacksysteam/HackSysExtremeVulnerableDriver/releases/download/v3.00/HEVD.3.00.zip"
$zipPath = "$env:TEMP\HEVD.zip"
$extractPath = "$env:TEMP\HEVD_Extracted"
$driverRelativePath = "driver\vulnerable\x64\HEVD.sys"
$driverFullPath = Join-Path $extractPath $driverRelativePath
$serviceName = "HEVD"

# Check for admin rights
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Not running as administrator. Relaunching with elevated privileges..."
    $scriptPath = $PSCommandPath
    if (-not $scriptPath) { $scriptPath = $MyInvocation.MyCommand.Definition }
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# Download the ZIP
Write-Host "Downloading HEVD..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

# Extract the ZIP
Write-Host "Extracting HEVD..."
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

# Verify driver path exists
if (-Not (Test-Path $driverFullPath)) {
    Write-Error "HEVD.sys not found at expected path: $driverFullPath"
    exit 1
}

# Copy to System32\drivers to persist across reboots
$destPath = "$env:SystemRoot\System32\drivers\HEVD.sys"
Copy-Item -Path $driverFullPath -Destination $destPath -Force

# Check if the service exists already
$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue
if ($service) {
    Write-Host "HEVD service already exists. Stopping and deleting it..."
    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $serviceName | Out-Null
    Start-Sleep -Seconds 1
}

# Register the driver as a system service
Write-Host "Creating persistent driver service..."
sc.exe create $serviceName binPath= "System32\drivers\HEVD.sys" type= kernel start= auto error= normal displayname= "HackSys Extreme Vulnerable Driver" | Out-Null

# Start the driver
Write-Host "Starting HEVD driver..."
Start-Service -Name $serviceName

Write-Host "HEVD installed and set to auto-start on boot."
