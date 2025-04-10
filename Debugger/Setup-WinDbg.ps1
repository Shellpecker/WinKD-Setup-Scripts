# Resolve user paths
$DesktopPath = [Environment]::GetFolderPath('Desktop')
$DocumentsPath = [Environment]::GetFolderPath('MyDocuments')
$ThemeDir = Join-Path $DocumentsPath "WinDbgTheme"
$ThemePath = Join-Path $ThemeDir "dark-green-x64.wew"
$DownloadUrl = "https://github.com/nextco/windbg-readable-theme/raw/refs/heads/master/dark-green-x64.wew"

# Detect WinDbg x64 path
$PossiblePaths = @(
    "C:\Program Files\Windows Kits\10\Debuggers\x64\windbg.exe",
    "C:\Program Files (x86)\Windows Kits\10\Debuggers\x64\windbg.exe"
)

$TargetFile = $PossiblePaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $TargetFile) {
    Write-Error "WinDbg x64 not found in standard locations."
    exit 1
}

# Ensure theme directory exists
if (-not (Test-Path $ThemeDir)) {
    New-Item -ItemType Directory -Path $ThemeDir | Out-Null
}

# Download theme if not already present
if (-not (Test-Path $ThemePath)) {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ThemePath
}

# Prepare WinDbg arguments
$Arguments = "-k net:port=50000,key=none -Q -y C:\Symbols -WF `"$ThemePath`""

# Create WScript.Shell object
$WScriptShell = New-Object -ComObject WScript.Shell

# Create elevated shortcut
$ShortcutPathElevated = Join-Path $DesktopPath "WinDbg (Admin).lnk"
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPathElevated)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Arguments = $Arguments
$Shortcut.Save()

# Modify shortcut to request elevation
$bytes = [System.IO.File]::ReadAllBytes($ShortcutPathElevated)
$bytes[0x15] = $bytes[0x15] -bor 0x20
[System.IO.File]::WriteAllBytes($ShortcutPathElevated, $bytes)

# Create non-elevated shortcut
$ShortcutPathNormal = Join-Path $DesktopPath "WinDbg.lnk"
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPathNormal)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Arguments = $Arguments
$Shortcut.Save()

# Add firewall rule for WinDbg kernel debugging (TCP 50000)
$RuleName = "Allow WinDbg Kernel Debugging TCP 50000"
if (-not (Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName $RuleName `
                        -Direction Inbound `
                        -Program $TargetFile `
                        -Action Allow `
                        -Protocol TCP `
                        -LocalPort 50000 `
                        -Profile Domain,Private `
                        -Description "Allow inbound kernel debugging over TCP port 50000 for WinDbg"
}
