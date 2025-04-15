# Script to download, extract, and install HEVD.sys with safe scheduled auto-start

$zipUrl = "https://github.com/hacksysteam/HackSysExtremeVulnerableDriver/releases/download/v3.00/HEVD.3.00.zip"
$zipPath = "$env:TEMP\HEVD.zip"
$extractPath = "$env:TEMP\HEVD_Extracted"
$driverRelativePath = "driver\vulnerable\x64\HEVD.sys"
$driverFullPath = Join-Path $extractPath $driverRelativePath
$destDriverPath = "$env:SystemRoot\System32\drivers\HEVD.sys"
$serviceName = "HEVD"
$taskName = "Start_HEVD_Auto"

# Admin check
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
    [Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Not running as administrator. Relaunching with elevated privileges..."
    $scriptPath = $PSCommandPath
    if (-not $scriptPath) { $scriptPath = $MyInvocation.MyCommand.Definition }
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

# Download HEVD
Write-Host "Downloading HEVD..."
Invoke-WebRequest -Uri $zipUrl -OutFile $zipPath

# Extract
Write-Host "Extracting HEVD..."
Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

# Validate
if (-Not (Test-Path $driverFullPath)) {
    Write-Error "HEVD.sys not found at: $driverFullPath"
    exit 1
}

# Copy to System32\drivers
Write-Host "Copying driver to System32\drivers..."
Copy-Item -Path $driverFullPath -Destination $destDriverPath -Force

# Remove old service if exists
if (Get-Service -Name $serviceName -ErrorAction SilentlyContinue) {
    Write-Host "Removing old HEVD service..."
    Stop-Service -Name $serviceName -Force -ErrorAction SilentlyContinue
    sc.exe delete $serviceName | Out-Null
    Start-Sleep -Seconds 1
}

# Create new demand-start kernel driver service
Write-Host "Registering HEVD driver service..."
sc.exe create $serviceName binPath= "System32\drivers\HEVD.sys" type= kernel start= demand error= normal displayname= "HackSys Extreme Vulnerable Driver"

# Create scheduled task to load the driver safely after boot
Write-Host "Creating scheduled task to auto-start HEVD after reboot..."
$action = New-ScheduledTaskAction -Execute "sc.exe" -Argument "start $serviceName"
$trigger = New-ScheduledTaskTrigger -AtStartup -Delay "PT30S"  # 30s after boot
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -RunLevel Highest

# Clean up old task if it exists
if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
}

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal

Write-Host "`n✅ HEVD installed."
Write-Host "🔁 It will start automatically ~30 seconds after each reboot (via scheduled task '$taskName')."
Write-Host "🔐 Make sure Test Mode is enabled: 'bcdedit /set testsigning on'"
