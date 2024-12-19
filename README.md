# PowerShell-VPNGate

## Overview

This PowerShell script automates the process of downloading a list of VPN servers from VPNGate, filtering the servers by the selected country, and attempting to connect to a VPN server. Upon a successful connection, it verifies the VPN connection by checking the system's IP address.

The script is divided into distinct steps:
1. **Download a CSV file** containing VPN server data from VPNGate.
2. **Display a list of available countries** from the CSV file for user selection.
3. **Filter VPN servers** based on the selected country.
4. **Set up and establish a VPN connection** to one of the filtered servers.
5. **Verify the VPN connection** by checking the IP address after a successful connection.

## Features
- **Country-based VPN server filtering**: Users can choose a country, and the script will only show VPN servers from that country.
- **Automatic VPN connection setup**: The script will check if the desired VPN connection exists and configure it automatically.
- **IP address verification**: After a successful VPN connection, the script checks the current IP address using both a `Test-Connection` method and an HTTP request to Cloudflare.

## Requirements
- PowerShell (Windows)
- VPN connection profile setup rights
- Internet access for downloading the CSV file and making the VPN connection.

## Installation and Setup

1. **Download the Script**:  
   Copy and save the script to a `.ps1` file on your system.

2. **Run the Script**:  
   **Method 1: Right-click the file and select "Run with PowerShell"**  
   - **Run the script with PowerShell**:
     1. Locate the script file in **File Explorer**.
     2. Right-click the file and select **"Run with PowerShell"**.
     3. This will open PowerShell and automatically execute the script.

   **Method 2: Open PowerShell as Administrator and run the script**  
   - **Open PowerShell as Administrator**:
     1. Search for **PowerShell** in the **Start menu**.
     2. Right-click **Windows PowerShell** in the search results and select **"Run as administrator"**.
     3. In the PowerShell window, navigate to the folder where the script is saved. For example, if the script is saved in the **C:\Scripts** folder, use the following command:
        ```powershell
        cd C:\Scripts
        ```
     4. Then execute the script with the following command:
        ```powershell
        .\VPNConnectionScript.ps1
        ```

3. **Modify VPN Connection Settings (Optional)**:  
   You can change the VPN connection name, user, password, or VPN tunnel type by editing the following lines in the script:
   ```powershell
   $vpnName = "VPN Gate"  # Modify the VPN connection name
   $vpnUser = "vpn"       # Modify the VPN user
   $vpnPassword = "vpn"   # Modify the VPN password
   $vpnTunnelType = "Automatic"  # Modify the VPN tunnel type
   ```

## Script Workflow
1. **Download VPN Server List**:  
   The script will download a CSV file from the VPNGate API containing a list of available VPN servers.

2. **Display Country List**:  
   The script will process the CSV file and display a list of available countries. You can choose a country by inputting the corresponding number.

3. **Filter VPN Servers by Country**:  
   After selecting the country, the script filters the list of VPN servers to only show those that are located in the chosen country.

4. **VPN Connection Setup**:  
   The script checks whether a VPN connection already exists. If a matching connection exists, it will attempt to connect using that configuration. If not, it will create a new VPN connection with the selected server.

5. **Verify VPN Connection**:  
   Once connected, the script checks the system's IP address using two methods:
   - **Test-Connection**: A standard network ping to an external server (`1.1.1.1`).
   - **Web Request**: An HTTP request to Cloudflare to obtain the external IP address.

## Sample Output
```
---------------------------------------------------------------------------------------------------
● CSV file download completed
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
● Country List
---------------------------------------------------------------------------------------------------
   1 United States
   2 United Kingdom
   3 Germany
   4 France
   5 Canada
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
Input Country (1-5): 1
---------------------------------------------------------------------------------------------------
● Filtered Data for Country: United States
---------------------------------------------------------------------------------------------------
Selected VPN server list:
vpn1.opengw.net
vpn2.opengw.net
vpn3.opengw.net
---------------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------------------------
No existing VPN connection. Adding a new one.
---------------------------------------------------------------------------------------------------
Adding new VPN connection...
New VPN connection added successfully.
---------------------------------------------------------------------------------------------------
Attempting to connect to VPN...
Attempting VPN connection to: vpn1.opengw.net
VPN connection successful: vpn1.opengw.net
Time taken: 10 seconds
---------------------------------------------------------------------------------------------------
Checking IP address after VPN connection...
Test-Connection: 192.168.1.1
Current IP address (web request): 192.168.1.1
---------------------------------------------------------------------------------------------------
Press Enter to exit
```

## Troubleshooting
- **Error: "Error occurred while downloading the file"**: This could indicate an issue with internet connectivity or a problem accessing the VPNGate API. Ensure the network is working and try running the script again.
- **VPN connection issues**: If the connection fails, check the VPN server list and ensure the selected server is available. Verify that the VPN connection settings are correct.
- **IP address verification**: If the IP check fails, make sure the VPN is properly connected, and there are no network issues preventing the IP verification.

## License
This script is released under the MIT License. You are free to modify and distribute it as needed.

## Contributions
Feel free to fork and contribute to this script. If you encounter any issues, please open an issue on the GitHub repository.
