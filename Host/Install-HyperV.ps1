# Ensure the script is running with administrative privileges.
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator"))
{
    Write-Host "Script is not running as Administrator. Relaunching with elevated privileges..."
    $scriptPath = $MyInvocation.MyCommand.Definition
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    exit
}

Write-Host "Checking if Hyper-V is enabled on this host..."
$feature = Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All

if ($feature.State -eq "Enabled")
{
    Write-Host "Hyper-V is already enabled on this host."
}
else
{
    Write-Host "Enabling Hyper-V. This may take a few minutes..."
    try {
        Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V-All -All -NoRestart -ErrorAction Stop
        Write-Host "Hyper-V has been enabled successfully."
    }
    catch {
        Write-Error "Failed to enable Hyper-V: $_"
        exit 1
    }
    
    Write-Host "A restart is required to complete the installation."
    $response = Read-Host "Do you want to restart now? (Y/N)"
    if ($response -match "^(Y|y)$")
    {
        Restart-Computer -Force
    }
    else
    {
        Write-Host "Please remember to restart your computer later to apply the changes."
    }
}
