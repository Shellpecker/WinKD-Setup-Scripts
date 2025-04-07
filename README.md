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
    .\Setup-KernelDebugging.ps1 -HostIP "10.0.0.5" -Port 60000
    ```
  - **Directly from GitHub:**
    ```powershell
    powershell -ExecutionPolicy Bypass -Command "& { . ([scriptblock]::Create((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/Shellpecker/WinKD-Setup-Scripts/refs/heads/main/Debuggee/Setup-KernelDebugging.ps1'))) -HostIP '10.0.0.5' -Port 60000 }"
    ```

## Debugger Scripts (Coming Soon)

...


## Security Notice

**Warning:** Running scripts directly from the internet can pose security risks. Please review the code and understand its effects before executing it on your system.
