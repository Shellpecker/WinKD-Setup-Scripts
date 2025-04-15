# Desired static IP config
$StaticIP = "192.168.123.2"
$SubnetMask = "255.255.255.0"

# Get all interfaces with an APIPA address
$apipaAdapters = Get-NetIPAddress -AddressFamily IPv4 |
    Where-Object { $_.IPAddress -like "169.254.*" }

if ($apipaAdapters.Count -eq 0) {
    Write-Host "No interfaces with APIPA addresses found."
}
else {
    foreach ($adapter in $apipaAdapters) {
        $ifIndex = $adapter.InterfaceIndex
        $ifAlias = $adapter.InterfaceAlias

        Write-Host "Configuring interface '$ifAlias' (Index: $ifIndex) with static IP $StaticIP..."

        # Remove existing (APIPA) IP
        Remove-NetIPAddress -InterfaceIndex $ifIndex -IPAddress $adapter.IPAddress -Confirm:$false

        # Assign the new static IP
        New-NetIPAddress -InterfaceIndex $ifIndex -IPAddress $StaticIP -PrefixLength 24

        Write-Host "Successfully assigned $StaticIP to '$ifAlias'."
    }
}


# Enable inbound ICMPv4 echo request (ping)
Write-Host "Enabling ICMP (ping) response through Windows Firewall..."
New-NetFirewallRule -DisplayName "Allow ICMPv4-In (Ping)" -Protocol ICMPv4 -IcmpType 8 `
    -Direction Inbound -Action Allow -Profile Any -Enabled True

Write-Host "Configuration complete."
