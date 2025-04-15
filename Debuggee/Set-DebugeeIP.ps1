# Desired static IP configuration
$StaticIP = "192.168.123.2"
$PrefixLength = 24  # Equivalent to 255.255.255.0
$DefaultGateway = $null
$DNSServers = @()  # Empty array = no DNS servers

# Get all interfaces with an APIPA address
$apipaAdapters = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -like "169.254.*" }

if ($apipaAdapters.Count -eq 0) {
    Write-Host "No interfaces with APIPA addresses found."
} else {
    foreach ($adapter in $apipaAdapters) {
        $ifIndex = $adapter.InterfaceIndex
        $ifAlias = $adapter.InterfaceAlias

        Write-Host "Configuring interface '$ifAlias' (Index: $ifIndex) with static IP $StaticIP..."

        # Remove APIPA address
        Remove-NetIPAddress -InterfaceIndex $ifIndex -IPAddress $adapter.IPAddress -Confirm:$false -ErrorAction SilentlyContinue

        # Remove any existing gateway config
        Remove-NetRoute -InterfaceIndex $ifIndex -NextHop 0.0.0.0 -Confirm:$false -ErrorAction SilentlyContinue

        # Assign the new static IP (no gateway, no DNS)
        New-NetIPAddress -InterfaceIndex $ifIndex -IPAddress $StaticIP -PrefixLength $PrefixLength -AddressFamily IPv4

        # Clear DNS server settings
        Set-DnsClientServerAddress -InterfaceIndex $ifIndex -ServerAddresses $DNSServers

        Write-Host "Successfully assigned $StaticIP with no gateway or DNS to '$ifAlias'."
    }
}

# Enable inbound ICMPv4 echo request (ping)
Write-Host "Enabling ICMP (ping) response through Windows Firewall..."
New-NetFirewallRule -DisplayName "Allow ICMPv4-In (Ping)" -Protocol ICMPv4 -IcmpType 8 `
    -Direction Inbound -Action Allow -Profile Any -Enabled True -ErrorAction SilentlyContinue

Write-Host "✅ Static IP configured and ICMP allowed. No DHCP, Gateway, or DNS involved."
