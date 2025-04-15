param(
    [Parameter(Mandatory=$false)]
    [switch]$Disable = $false
)

# Check if the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Script not running as administrator. Attempting to re-launch with elevated privileges..."
    $scriptPath = $PSCommandPath
    if (-not $scriptPath) { $scriptPath = $MyInvocation.MyCommand.Definition }
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`" $(if ($Disable) { '-Disable' })" -Verb RunAs
    exit
}

if ($Disable) {
    Write-Host "Disabling Test Mode..."
    bcdedit /set testsigning off
    Write-Host "Test Mode has been disabled."
} else {
    Write-Host "Enabling Test Mode to allow unsigned drivers..."
    bcdedit /set testsigning on
    Write-Host "Test Mode has been enabled."
}

Write-Host "`nSystem will reboot in 5 seconds..."
for ($i = 5; $i -ge 1; $i--) {
    Write-Host "$i..."
    Start-Sleep -Seconds 1
}

Restart-Computer -Force
