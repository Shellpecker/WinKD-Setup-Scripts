param(
    [Parameter(Mandatory=$false)]
    [string]$HostIP = "192.168.123.1",

    [Parameter(Mandatory=$false)]
    [int]$Port = 50000
)

# Check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Script not running as administrator. Attempting to re-launch with elevated privileges..."
    # Retrieve the current script's full path
    $scriptPath = $PSCommandPath
    if (-not $scriptPath) { $scriptPath = $MyInvocation.MyCommand.Definition }
    # Relaunch the script as administrator and pass the parameters
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" -HostIP $HostIP -Port $Port" -Verb RunAs
    exit
}

Write-Host "Enabling kernel debugging..."
# Enable kernel debugging
bcdedit /set debug on

Write-Host "Setting debug type to network..."
# Set the debug type to network
bcdedit /set debugtype NET

Write-Host "Configuring network debugging settings..."
# Configure network kernel debugging using the provided IP and port
bcdedit /set dbgsettings NET hostip:$HostIP port:$Port

Write-Host "Kernel debugging has been configured. The computer will now reboot."
Restart-Computer -Force
