# ASCII art banner
Write-Output @"
   __  __  __  __  __  __  __
  /  \/  \/  \/  \/  \/  \/  \
 ( W   A   K   E   D   O   G )
  \__/\__/\__/\__/\__/\__/\__/
"@

# Function to prompt for confirmation
function Confirm-Execution {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$Message)

    Write-Host -ForegroundColor Yellow "$Message (Y/N)"
    $confirmation = Read-Host
    return $confirmation -eq "Y"
}

# Main script starts here

# 1. Harden the system
# 1.1 Enable Windows Firewall
if (-not (Get-NetFirewallProfile -Profile Domain, Public, Private | Where-Object Enabled)) {
    if (Confirm-Execution "Enable Windows Firewall?") {
        Enable-NetFirewallProfile -Profile Domain, Public, Private
    }
}

# 1.2 Enable Windows Defender
if ((Get-MpPreference).DisableRealtimeMonitoring) {
    if (Confirm-Execution "Enable Windows Defender?") {
        Set-MpPreference -DisableRealtimeMonitoring $false
    }
}

# 1.3 Enable User Account Control
if ((Get-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name EnableLUA).EnableLUA -eq 0) {
    if (Confirm-Execution "Enable User Account Control?") {
        Set-ItemProperty -Path 'HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System' -Name EnableLUA -Value 1
    }
}

# 1.4 Enable the built-in Administrator account
if (-not (Get-LocalUser -Name "Administrator").Enabled) {
    if (Confirm-Execution "Enable the built-in Administrator account?") {
        Enable-LocalUser -Name "Administrator"
    }
}

# 1.5 Securely set the Administrator account password
$password = ConvertTo-SecureString (New-Guid).ToString() -AsPlainText -Force
Set-LocalUser -Name "Administrator" -Password $password

# 2. Clean the system
# 2.1 Uninstall unnecessary apps
if (Confirm-Execution "Uninstall unnecessary apps?") {
    Get-AppxPackage | Where-Object Name -notlike "*windows*" | Remove-AppxPackage
}

# 2.2 Scan for and remove harmful software
if (Confirm-Execution "Scan for and remove harmful software?") {
    Start-MpScan -ScanType QuickScan
}

# 3. Debloat the system
# 3.1 Remove unnecessary features
if (Confirm-Execution "Remove unnecessary features?") {
    Disable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-amd64", "Windows-Media-Player", "Xps-Viewer"
}

# 3.2 Remove bloatware
if (Confirm-Execution "Remove bloatware?") {
    Get-AppxPackage -Name "Microsoft.XboxApp", "Microsoft.BingFinance", "Microsoft.BingNews", "Microsoft.BingSports", "Microsoft.BingWeather", "Microsoft.Windows.Photos", "Microsoft.WindowsAlarms", "Microsoft.WindowsCalculator", "Microsoft.WindowsCamera", "Microsoft.WindowsMaps", "Microsoft.WindowsPhone", "Microsoft.WindowsSoundRecorder", "Microsoft.ZuneMusic", "Microsoft.ZuneVideo", "Microsoft.SolitaireCollection" | Remove-AppxPackage
}

# 4. Customize system settings
# 4.1 Set screen lock timeout
if ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System').ScreenSaverTimeout -ne 1) {
    if (Confirm-Execution "Set screen lock timeout to 1 minute?") {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ScreenSaverTimeout -Value 1
    }
}

# 4.2 Enable automatic updates
if ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update').AutoUpdate -ne 1) {
    if (Confirm-Execution "Enable automatic updates?") {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' -Name AutoUpdate -Value 1
    }
}

# 4.3 Enable strong passwords
if ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Network').MinimumPasswordLength -lt 8) {
    if (Confirm-Execution "Enable strong passwords?") {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Network' -Name MinimumPasswordLength -Value 8
    }
}

# 4.4 Set power plan to high performance
if ((Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\238C9FA8-0AAD-41ED-83F4-97BE242C8F20\7bc4a2f9-d8fc-4469-b07b-33eb785aaca0').Attributes -ne 2) {
    if (Confirm-Execution "Set power plan to high performance?") {
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\238C9FA8-0AAD-41ED-83F4-97BE242C8F20\7bc4a2f9-d8fc-4469-b07b-33eb785aaca0' -Name Attributes -Value 2
    }
}

# 5. Optimize system performance
# 5.1 Defragment hard drive
if (Confirm-Execution "Defragment hard drive?") {
    Optimize-Volume -DriveLetter C -Defrag
}

# 5.2 Clear temporary files
if (Confirm-Execution "Clear temporary files?") {
    Cleanmgr
}

# 5.3 Disable unnecessary services
if (Confirm-Execution "Disable unnecessary services?") {
    # Example: disable print spooler service if no printers installed
    if ((Get-WmiObject -Class Win32_Printer | Where-Object WorkOffline -eq $false).Count -eq 0) {
        Set-Service -Name "Spooler" -StartupType Disabled
    }
}

# 6. Perform a system backup
if (Confirm-Execution "Perform a system backup?") {
    $backupLocation = "\\server\share\backup"
    $dateTime = Get-Date -Format yyyy-MM-dd_HH-mm-ss
    $backupFolder = Join-Path -Path $backupLocation -ChildPath $dateTime
    New-Item -ItemType Directory -Path $backupFolder -Force
    wbadmin start backup -include:C: -backupTarget:$backupFolder -quiet
}

# 7. Restart the system
if (Confirm-Execution "Restart the system now?") {
    Restart-Computer
}

# Additional Hardening Measures

# 1. Implement Credential Guard
if (-not (Get-ItemProperty -Path 'HKLM:\System\Setup\Guardian') -and (Test-Path -Path 'HKLM:\System\Setup\Guardian')) {
    if (Confirm-Execution "Enable Credential Guard?") {
        # Note: Enabling Credential Guard requires a reboot and cannot be done directly via PowerShell script.
        # Consider using Group Policy or Task Scheduler to automate the reboot.
        # Reference: https://docs.microsoft.com/en-us/windows/security/identity-protection/credential-guard/credential-guard-manage
    }
}

# 2. Enable Device Guard
if (-not (Get-ItemProperty -Path 'HKLM:\System\DeviceGuard') -and (Test-Path -Path 'HKLM:\System\DeviceGuard')) {
    if (Confirm-Execution```
