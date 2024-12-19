# This script downloads a CSV file provided by VPNGate, filters VPN servers based on the country selected by the user, and attempts to connect.
# Upon a successful connection, it verifies the VPN connection by checking the IP address.
# If you want to change the VPN name, modify `$vpnName = "VPN Gate"` in Step 5: Set up VPN connection.



# Step 1: Download CSV file
$url = "https://www.vpngate.net/api/iphone/"
$filePath = "$env:TEMP\VPNGateServers.csv"

Write-Host "---------------------------------------------------------------------------------------------------"

# Download file
try {
    Invoke-WebRequest -Uri $url -OutFile $filePath
    Write-Host "● CSV file download completed"
} catch {
    Write-Host "Error occurred while downloading the file: $_"
    exit
}

Write-Host "---------------------------------------------------------------------------------------------------"

# Step 2: Manually process the CSV file
$csvContent = Get-Content -Path $filePath
$headerLine = $csvContent[1]
$headers = $headerLine.Split(',')
$serverData = $csvContent[2..($csvContent.Length - 1)]

# Create country list (unique)
$countryList = $serverData | ForEach-Object {
    $fields = $_.Split(',')
    $fields[5]  # 6th field is 'Country'
} | Sort-Object -Unique

Write-Host "`n---------------------------------------------------------------------------------------------------"
Write-Host "● Country List"
Write-Host "---------------------------------------------------------------------------------------------------"
$countryList | ForEach-Object { 
    $index = [array]::IndexOf($countryList, $_) + 1  # # Index starts from 1
    Write-Host "   $index $_"
}

# Step 3: Get country number from user
Write-Host "---------------------------------------------------------------------------------------------------"
$countryInput = 0  # Initial value

# User input validation
do {
    $countryInput = Read-Host -Prompt "Input Country (1-$($countryList.Length))"
    
    # Try to convert input to an integer
    $countryInputInt = 0
    $isValid = [int]::TryParse($countryInput, [ref]$countryInputInt)

    # Check if the input is a valid number and within the valid range
    if (-not $isValid -or $countryInputInt -lt 1 -or $countryInputInt -gt $countryList.Length) {
        Write-Host "Invalid input. Please enter a valid country number between 1 and $($countryList.Length)."
    }
} while (-not $isValid -or $countryInputInt -lt 1 -or $countryInputInt -gt $countryList.Length)

Write-Host "---------------------------------------------------------------------------------------------------"

# Get selected country name
$selectedCountry = $countryList[$countryInputInt - 1]  # Extract country name based on user input
Write-Host "`n---------------------------------------------------------------------------------------------------"
Write-Host "● Filtered Data for Country: $selectedCountry"
Write-Host "---------------------------------------------------------------------------------------------------"


# Step 4: Filter data for the selected country
$filteredServers = $serverData | Where-Object {
    $fields = $_.Split(',')
    $fields[5] -eq $selectedCountry  # Compare 6th field 'Country'
}

# Create list of server HostNames (add .opengw.net to HostName)
$vpnServers = $filteredServers | ForEach-Object {
    $fields = $_.Split(',')
    $fields[0] + ".opengw.net"  # 1st field is HostName
}

# Output selected VPN server list
Write-Host "Selected VPN server list:"
$vpnServers | ForEach-Object { Write-Host $_ }

Write-Host "---------------------------------------------------------------------------------------------------"
Write-Host "`n---------------------------------------------------------------------------------------------------"

# Step 5: Set up VPN connection
$vpnName = "VPN Gate"
$vpnUser = "vpn"
$vpnPassword = "vpn"
$vpnTunnelType = "Automatic"  # VPN type: Automatic

# Check if VPN connection already exists
$existingVpn = Get-VpnConnection -Name $vpnName -ErrorAction SilentlyContinue

if ($existingVpn) {
    # If existing VPN connection exists, check if settings match
    $vpnMatches = $existingVpn.ServerAddress -eq $vpnServers[0] -and $existingVpn.TunnelType -eq $vpnTunnelType

    if ($vpnMatches) {
        # If settings match, attempt connection as is
        Write-Host "Existing VPN connection matches the settings."
        Write-Host "Attempting to connect to VPN..."
    } else {
        # If settings differ, remove the existing connection and add a new one
        Write-Host "Existing VPN connection settings do not match. Removing and adding a new connection."
        Write-Host "Removing existing connection..."
        rasdial $vpnName /disconnect  # Disconnect first
        Remove-VpnConnection -Name $vpnName -Force  # Remove existing connection

        Write-Host "`nAdding new VPN connection..."
        try {
            Add-VpnConnection -Name $vpnName `
                               -ServerAddress $vpnServers[0] `
                               -TunnelType $vpnTunnelType `
                               -RememberCredential
            Write-Host "New VPN connection added successfully."
        } catch {
            Write-Host "`n[Error occurred]"
            Write-Host "Error adding VPN connection: $($_.Exception.Message)" -ForegroundColor Red
        }
    }
} else {
    # If no existing VPN connection, add a new one
    Write-Host "No existing VPN connection. Adding a new one."
    Write-Host "`nAdding new VPN connection..."
    try {
        Add-VpnConnection -Name $vpnName `
                           -ServerAddress $vpnServers[0] `
                           -TunnelType $vpnTunnelType `
                           -RememberCredential
        Write-Host "New VPN connection added successfully."
    } catch {
        Write-Host "`n[Error occurred]"
        Write-Host "Error adding VPN connection: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Start recording VPN connection time
$startTime = Get-Date
Write-Host "`nAttempting to connect to VPN..."

# Attempt VPN connection: Try multiple servers sequentially
$connected = $false
foreach ($vpnServer in $vpnServers) {
    Write-Host "Attempting VPN connection to: $vpnServer"
    
    try {
        # Try connecting to VPN
        $vpnConnectionResult = rasdial $vpnName $vpnUser $vpnPassword
        if ($?) {
            Write-Host "`nVPN connection successful: $vpnServer"
            
            $endTime = Get-Date
            $duration = $endTime - $startTime
            Write-Host "Time taken: $($duration.TotalSeconds) seconds"
            
            $connected = $true
            break  # Exit if connection is successful
        } else {
            Write-Host "[Error occurred] VPN connection attempt failed: $vpnServer`n" -ForegroundColor Red
        }
    } catch {
        Write-Host "[Error occurred] Error during VPN connection attempt: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Check IP address after VPN connection is successful
if ($connected) {
    Write-Host "`nChecking IP address after VPN connection..."
    
    # 1. Check IP address using Test-Connection
    try {
        $ipAddress = (Test-Connection -ComputerName "1.1.1.1" -Count 1).Address
        Write-Host "Test-Connection: $ipAddress"
    } catch {
        Write-Host "Failed to check IP address (Test-Connection): $($_.Exception.Message)" -ForegroundColor Red
    }

    # 2. Check IP address using Invoke-WebRequest (Cloudflare)
    Write-Host "`nAttempting to check IP address..."
    try {
        $response = Invoke-WebRequest -Uri "https://www.cloudflare.com/cdn-cgi/trace"
        Write-Host "Current IP address (web request): "
        $ipAddressFromWeb = ($response.Content -match "ip=(\d+\.\d+\.\d+\.\d+)") | Out-Null; $matches[1]
        Write-Host $ipAddressFromWeb
    } catch {
        Write-Host "Failed to check IP address via web request: $($_.Exception.Message)" -ForegroundColor Red
    }
} else {
    Write-Host "`nFailed to connect to VPN. Unable to check IP address." -ForegroundColor Red
}

# Keep PowerShell window open
Write-Host ""
Read-Host -Prompt "Press Enter to exit"
