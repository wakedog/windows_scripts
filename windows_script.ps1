# ASCII art banner
Write-Output "
   __  __  __  __  __  __  __
  /  \/  \/  \/  \/  \/  \/  \
 ( W   A   K   E   D   O   G )
  \__/\__/\__/\__/\__/\__/\__/
"

# Create a function to prompt the user for confirmation before executing a block of code
function Confirm-Execution {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message
    )

    Write-Host -ForegroundColor Yellow "$Message (Y/N)"
    $confirmation = Read-Host
    if ($confirmation -eq "Y") {
        return $true
    } else {
        return $false
    }
}

# 1. Harden the system by enabling built-in security features
# 1.1 Enable Windows Firewall
if (Get-NetFirewallProfile | Where-Object {$_.Enabled -eq "False"}) {
    if (Confirm-Execution "Do you want to enable Windows Firewall?") {
        Enable-NetFirewallProfile -Profile Domain,Public,Private
    }
}

# 1.2 Enable Windows Defender
if ((Get-MpPreference).DisableRealtimeMonitoring) {
    if (Confirm-Execution "Do you want to enable Windows Defender?") {
        Set-MpPreference -DisableRealtimeMonitoring $false
    }
}

# 1.3 Enable User Account Control
if ((Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA).EnableLUA -eq 0) {
    if (Confirm-Execution "Do you want to enable User Account Control?") {
        Set-ItemProperty -Path HKLM:\Software\Microsoft\Windows\CurrentVersion\policies\system -Name EnableLUA -Value 1
    }
}

# 1.4 Enable the built-in Administrator account
if (!(Get-LocalUser -Name "Administrator").Enabled) {
    if (Confirm-Execution "Do you want to enable the built-in Administrator account?") {
        Enable-LocalUser -Name "Administrator"
    }
}

# 1.5 Set the built-in Administrator account password to a strong, randomly-generated value
$password = ConvertTo-SecureString (New-Guid).ToString() -AsPlainText -Force
Set-LocalUser -Name "Administrator" -Password $password

# 2. Clean the system by removing unnecessary or harmful software
# 2.1 Uninstall unnecessary Windows 10 apps
if (Confirm-Execution "Do you want to uninstall unnecessary Windows 10 apps?") {
    Get-AppxPackage | Where-Object {$_.Name -notlike "*windows*"} | Remove-AppxPackage
}

# 2.2 Remove harmful software (e.g. malware, adware)
if (Confirm-Execution "Do you want to scan for and remove harmful software?") {
    # Use Windows Defender to scan for and remove harmful software
    Start-MpScan -ScanType QuickScan
}

# 3. Debloat the system by removing unnecessary features and components
# 3.1 Remove unnecessary Windows features and components
if (Confirm-Execution "Do you want to remove unnecessary Windows features and components?") {
    # Use DISM to remove unnecessary Windows features and components
    # List of unnecessary features and components can be customized to suit the user's needs
    # Example: remove Internet Explorer, Windows Media Player, and XPS Viewer
    Disable-WindowsOptionalFeature -Online -FeatureName "Internet-Explorer-Optional-amd64"
    Disable-WindowsOptionalFeature -Online -FeatureName "Windows-Media-Player"
    Disable-WindowsOptionalFeature -Online -FeatureName "Xps-Viewer"
}

# 3.2 Remove bloatware (i.e. pre-installed manufacturer software)
if (Confirm-Execution "Do you want to remove bloatware?") {
    # List of bloatware can be customized to suit the user's needs
    # Example: remove Candy Crush, Farmville, and other Microsoft Store games
    Get-AppxPackage -Name "Microsoft.XboxApp" | Remove-AppxPackage
    Get-AppxPackage -Name "Microsoft.BingFinance" | Remove-AppxPackage
    Get-AppxPackage -Name "Microsoft.BingNews" | Remove-AppxPackage
    Get-AppxPackage -Name "Microsoft.BingSports" | Remove-AppxPackage
    Get-AppxPackage -Name "Microsoft.BingWeather" | Remove-AppxPackage
    Get-AppxPackage -Name "Microsoft.Windows.Photos" | Remove-AppxPackage
    Get-AppxPackage -Name "Microsoft.WindowsAlarms" | Remove-AppxPackage
    Get-AppxPackage -Name "Microsoft.WindowsCalculator" | Remove-AppxPackage
    Get-AppxPackage -Name "Microsoft.WindowsCamera" | Remove-AppxPackage
    Get-AppxPackage -Name "Microsoft.WindowsMaps" | Remove-AppxPackage
    Get-AppxPackage -Name "Microsoft.WindowsPhone" | Remove-AppxPackage
    Get-AppxPackage -Name "Microsoft.WindowsSoundRecorder" | Remove-AppxPackage
    Get-AppxPackage -Name "Microsoft.ZuneMusic" | Remove-AppxPackage
    Get-AppxPackage -Name "Microsoft.ZuneVideo" | Remove-AppxPackage
    Get-AppxPackage -Name "Microsoft.SolitaireCollection" | Remove-AppxPackage
}

# 4. Customize system settings to improve security and performance
# 4.1 Set the screen lock timeout to 1 minute
if ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System').ScreenSaverTimeout -ne 1) {
    if (Confirm-Execution "Do you want to set the screen lock timeout to 1 minute?") {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies

# 4.1 Set the screen lock timeout to 1 minute
if ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System').ScreenSaverTimeout -ne 1) {
    if (Confirm-Execution "Do you want to set the screen lock timeout to 1 minute?") {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System' -Name ScreenSaverTimeout -Value 1
    }
}

# 4.2 Enable automatic updates
if ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update').AutoUpdate -ne 1) {
    if (Confirm-Execution "Do you want to enable automatic updates?") {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update' -Name AutoUpdate -Value 1
    }
}

# 4.3 Enable strong passwords
if ((Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Network').MinimumPasswordLength -lt 8) {
    if (Confirm-Execution "Do you want to enable strong passwords (minimum length 8 characters)?") {
        Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Network' -Name MinimumPasswordLength -Value 8
    }
}

# 4.4 Set the power plan to high performance
if ((Get-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\238C9FA8-0AAD-41ED-83F4-97BE242C8F20\7bc4a2f9-d8fc-4469-b07b-33eb785aaca0').Attributes -ne 2) {
    if (Confirm-Execution "Do you want to set the power plan to high performance?") {
        Set-ItemProperty -Path 'HKLM:\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\238C9FA8-0AAD-41ED-83F4-97BE242C8F20\7bc4a2f9-d8fc-4469-b07b-33eb785aaca0' -Name Attributes -Value 2
    }
}

# 5. Optimize system performance
# 5.1 Defragment hard drive
if (Confirm-Execution "Do you want to defragment the hard drive?") {
    Optimize-Volume -DriveLetter C -Defrag
}

# 5.2 Clear temporary files
if (Confirm-Execution "Do you want to clear temporary files?") {
    # Use the built-in Disk Cleanup tool
    Cleanmgr
}

# 5.3 Disable unnecessary services
if (Confirm-Execution "Do you want to disable unnecessary services?") {
    # List of unnecessary services can be customized to suit the user's needs
    # Example: disable print spooler service if there are no printers installed
    if ((Get-WmiObject -Class Win32_Printer | Where-Object {$_.WorkOffline -eq $false}).Count -eq 0) {
        Set-Service -Name "Spooler" -StartupType Disabled
    }
}

# 6. Perform a system backup
if (Confirm-Execution "Do you want to perform a system backup?") {
    # Choose a backup location (e.g. external hard drive, network share)
    $backupLocation = "\\server\share\backup"

    # Set the date and time as the backup folder name
    $dateTime = Get-Date -Format yyyy-MM-dd_HH-mm-ss
    $backupFolder = "$backupLocation\$dateTime"

    # Create the backup folder
    New-Item -ItemType Directory -Path $backupFolder

    # Perform the backup using the built-in Windows Backup tool
    wbadmin start backup -include:C: -backupTarget:$backupFolder -quiet
}

# 7. Restart the system
if (Confirm-Execution "Do you want to restart the system now?") {
    Restart-Computer
}