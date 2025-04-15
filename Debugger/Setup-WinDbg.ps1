# Shared theme path
$ThemeDir = "C:\WinDbgTheme"
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

# Prepare theme folder
if (-not (Test-Path $ThemeDir)) {
    New-Item -ItemType Directory -Path $ThemeDir | Out-Null
    icacls $ThemeDir /grant "Users:(OI)(CI)RX" | Out-Null
}

# Download theme if missing
if (-not (Test-Path $ThemePath)) {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $ThemePath
}

# Updated symbol path to include Microsoft Symbol Server
$SymbolPath = "srv*C:\Symbols*https://msdl.microsoft.com/download/symbols"

# Debug key
$DebugKey = "2b1i68bxp7pea.3t5g827tcava5.3bqaxa0qorrh5.dov2402b65qc"

# WinDbg launch args
$Arguments = "-k net:port=50000,key=$DebugKey -y `"$SymbolPath`" -Q -WF `"$ThemePath`""

# Public desktop shortcuts
$PublicDesktop = "C:\Users\Public\Desktop"
$WScriptShell = New-Object -ComObject WScript.Shell

# Elevated shortcut
$ShortcutPathElevated = Join-Path $PublicDesktop "WinDbg (Admin).lnk"
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPathElevated)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Arguments = $Arguments
$Shortcut.Save()

# Set "Run as Admin" flag
$bytes = [System.IO.File]::ReadAllBytes($ShortcutPathElevated)
$bytes[0x15] = $bytes[0x15] -bor 0x20
[System.IO.File]::WriteAllBytes($ShortcutPathElevated, $bytes)

# Non-elevated shortcut
$ShortcutPathNormal = Join-Path $PublicDesktop "WinDbg.lnk"
$Shortcut = $WScriptShell.CreateShortcut($ShortcutPathNormal)
$Shortcut.TargetPath = $TargetFile
$Shortcut.Arguments = $Arguments
$Shortcut.Save()

# Firewall rule
$RuleName = "Allow WinDbg TCP 50000"
if (-not (Get-NetFirewallRule -DisplayName $RuleName -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -DisplayName $RuleName `
                        -Direction Inbound `
                        -Action Allow `
                        -Protocol TCP `
                        -LocalPort 50000 `
                        -Profile Any `
                        -Description "Allow kernel debugging over TCP 50000"
}
