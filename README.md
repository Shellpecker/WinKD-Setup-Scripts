# WinKD-Setup-Scripts
## Debuggee Scripts

**Setup-KernelDebugging.ps1**

- **Purpose:**  
  Configures your Windows machine for kernel debugging over the network.

- **Features:**
  - Enables kernel debugging.
  - Sets the debug type to network.
  - Configures network settings with a customizable debugger host IP and port.
  - Automatically re-launches with elevated (UAC) privileges if necessary.
  - Reboots the machine automatically after configuration.

- **Parameters:**

  | Parameter | Type   | Description                                | Default         |
  |-----------|--------|--------------------------------------------|-----------------|
  | `HostIP`  | string | The IP address of the debugging host.      | `"192.168.50.1"`|
  | `Port`    | int    | The port for debugging communication.      | `50000`         |


- **Example Usage:**
  - **Locally:**
    ```powershell
    .\Setup-KernelDebugging.ps1 -HostIP "192.168.50.1" -Port 50000
    ```
  - **Directly from GitHub:**
    ```powershell
    powershell -ExecutionPolicy Bypass -Command "& { . ([scriptblock]::Create((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Shellpecker/WinKD-Setup-Scripts/refs/heads/main/Debuggee/Setup-KernelDebugging.ps1'))) -HostIP '192.168.50.1' -Port 50000 }"
    ```

## Debugger Scripts

### Install-WindowsSDK.ps1

- **Purpose:**  
  Automatically downloads and installs the latest Windows SDK using Microsoft's stable FWLink. This script ensures you always get the most up-to-date version that fits your OS.

- **Features:**
  - **Administrative Check:** Automatically relaunches with elevated privileges if not already running as Administrator.
  - **Latest SDK Download:** Uses a stable FWLink to download the latest Windows SDK installer.
  - **Silent Installation:** Runs the installer silently (with `/quiet /norestart`), ensuring an unattended installation.
  - **Cleanup:** Removes the installer file from the temporary folder after installation.

- **Example Usage:**
  - **Locally:**
    ```powershell
    .\Install-WindowsSDK.ps1
    ```
  - **Directly from GitHub:**
    ```powershell
    powershell -ExecutionPolicy Bypass -Command "& { . ([scriptblock]::Create((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Shellpecker/WinKD-Setup-Scripts/refs/heads/main/Debugger/Install-WindowsSDK.ps1'))) }"
    ```
  
    Note:
    Ensure that you select the Debugging Tools for Windows component during the installation process, as this is required for kernel debugging.


## Security Notice

**Warning:** Running scripts directly from the internet can pose security risks. Please review the code and understand its effects before executing it on your system.
