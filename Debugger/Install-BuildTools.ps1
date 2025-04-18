# Set variables
$buildToolsUrl = "https://aka.ms/vs/17/release/vs_BuildTools.exe"
$installerPath = "$env:TEMP\vs_BuildTools.exe"
$installPath = "C:\BuildTools"

# Download the installer
Invoke-WebRequest -Uri $buildToolsUrl -OutFile $installerPath

# Run the installer silently with MSBuild and full C++ project system
Start-Process -FilePath $installerPath -ArgumentList `
    "--quiet",
    "--wait",
    "--norestart",
    "--nocache",
    "--installPath `"$installPath`"",
    "--add Microsoft.VisualStudio.Workload.MSBuildTools",
    "--add Microsoft.VisualStudio.Workload.VCTools",
    "--add Microsoft.VisualStudio.Component.VC.Tools.x86.x64",
    "--add Microsoft.VisualStudio.Component.VC.CoreBuildTools",
    "--add Microsoft.VisualStudio.Component.VC.ATL",
    "--add Microsoft.VisualStudio.Component.Windows10SDK.19041" `
    -Wait -NoNewWindow

# Remove the installer after install
Remove-Item $installerPath -Force

# Locate MSBuild.exe
$msbuildPath = Get-ChildItem -Path "$installPath\MSBuild" -Recurse -Filter MSBuild.exe -ErrorAction SilentlyContinue |
    Where-Object { $_.FullName -like "*Current\Bin\MSBuild.exe" } |
    Select-Object -First 1 -ExpandProperty FullName

if ($msbuildPath) {
    $msbuildDir = Split-Path $msbuildPath

    # Read current system PATH
    $existingPath = [Environment]::GetEnvironmentVariable("Path", [EnvironmentVariableTarget]::Machine)

    # Only add if it's not already in PATH
    if ($existingPath -notlike "*$msbuildDir*") {
        $newPath = $existingPath + ";$msbuildDir"
        [Environment]::SetEnvironmentVariable("Path", $newPath, [EnvironmentVariableTarget]::Machine)
        Write-Host "✅ System PATH updated persistently with: $msbuildDir"
    } else {
        Write-Host "ℹ️ MSBuild path already in system PATH: $msbuildDir"
    }

    Write-Host "`n📍 MSBuild.exe found at: $msbuildPath"
    Write-Host "💡 You may need to restart your terminal or log off/log on to use it globally."
} 
else {
    Write-Host "❌ MSBuild.exe not found under $installPath. Please check the installation."
}
