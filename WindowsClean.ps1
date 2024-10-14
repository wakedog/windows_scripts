# Ensure the script is running with administrative privileges
if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    [System.Windows.MessageBox]::Show("Please run this script as an Administrator.", "Insufficient Privileges", "OK", "Warning")
    exit
}

# Load the PresentationFramework assembly
Add-Type -AssemblyName PresentationFramework

# Define the XAML form
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Windows Cleaner" Height="400" Width="450" ResizeMode="NoResize">
    <Grid Margin="10">
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <ScrollViewer Grid.Column="0" Grid.Row="0">
            <StackPanel HorizontalAlignment="Center" VerticalAlignment="Top">
                <Button x:Name="btnDeleteTempFiles" Content="Delete Temporary Files" Width="200" Margin="5"/>
                <Button x:Name="btnEmptyRecycleBin" Content="Empty Recycle Bin" Width="200" Margin="5"/>
                <Button x:Name="btnDeleteUnwantedData" Content="Delete Unwanted User Profiles" Width="200" Margin="5"/>
                <Button x:Name="btnClearEventLogs" Content="Clear Event Logs" Width="200" Margin="5"/>
                <Button x:Name="btnDiskCleanup" Content="Run Disk Cleanup" Width="200" Margin="5"/>
                <Button x:Name="btnDefragment" Content="Defragment Drives" Width="200" Margin="5"/>
                <Button x:Name="btnScanSystemForErrors" Content="Scan System For Errors" Width="200" Margin="5"/>
            </StackPanel>
        </ScrollViewer>
        <StackPanel Grid.Column="0" Grid.Row="1" Orientation="Horizontal" HorizontalAlignment="SpaceBetween" Margin="0,10,0,0">
            <Label x:Name="lblStatus" Content="Status: Idle" HorizontalAlignment="Left"/>
            <Label Content="Created by Wakedog" HorizontalAlignment="Right"/>
        </StackPanel>
    </Grid>
</Window>
"@

# Create the XAML form
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Define log file path
$logFile = "$env:LOCALAPPDATA\WindowsCleaner.log"

# Function to log messages
function Write-Log {
    param (
        [string]$message
    )
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$timestamp - $message" | Out-File -FilePath $logFile -Append -Encoding UTF8
}

# Define the cleanup functions
function Delete-TemporaryFiles {
    try {
        Write-Log "Starting deletion of temporary files."
        Remove-Item -Path "$env:TEMP\*" -Recurse -Force -ErrorAction Stop
        Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction Stop
        Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction Stop
        $window.FindName("lblStatus").Content = "Temporary files deleted successfully."
        Write-Log "Temporary files deleted successfully."
    } catch {
        $window.FindName("lblStatus").Content = "Error deleting temporary files."
        Write-Log "Error deleting temporary files: $_"
    }
}

function Empty-RecycleBin {
    try {
        Write-Log "Starting to empty Recycle Bin."
        Clear-RecycleBin -Force -ErrorAction Stop
        $window.FindName("lblStatus").Content = "Recycle Bin emptied successfully."
        Write-Log "Recycle Bin emptied successfully."
    } catch {
        $window.FindName("lblStatus").Content = "Error emptying Recycle Bin."
        Write-Log "Error emptying Recycle Bin: $_"
    }
}

function Delete-UnwantedUserProfiles {
    try {
        Write-Log "Starting deletion of unwanted user profiles."
        $profiles = Get-WmiObject -Class Win32_UserProfile | Where-Object {
            $_.Special -eq $false -and $_.LocalPath -notmatch "^(C:\\Users\\(Default|Public|DefaultUser|WDAGUtilityAccount))$"
        }
        foreach ($profile in $profiles) {
            $profilePath = $profile.LocalPath
            $profile.Delete()
            Write-Log "Deleted user profile: $profilePath"
        }
        $window.FindName("lblStatus").Content = "Unwanted user profiles deleted successfully."
        Write-Log "Unwanted user profiles deleted successfully."
    } catch {
        $window.FindName("lblStatus").Content = "Error deleting user profiles."
        Write-Log "Error deleting user profiles: $_"
    }
}

function Clear-EventLogs {
    try {
        Write-Log "Starting to clear event logs."
        Get-EventLog -List | ForEach-Object {
            Clear-EventLog -LogName $_.Log
            Write-Log "Cleared event log: $($_.Log)"
        }
        $window.FindName("lblStatus").Content = "Event logs cleared successfully."
        Write-Log "Event logs cleared successfully."
    } catch {
        $window.FindName("lblStatus").Content = "Error clearing event logs."
        Write-Log "Error clearing event logs: $_"
    }
}

function Run-DiskCleanup {
    try {
        Write-Log "Starting Disk Cleanup."
        Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sagerun:1" -Wait
        $window.FindName("lblStatus").Content = "Disk Cleanup completed."
        Write-Log "Disk Cleanup completed."
    } catch {
        $window.FindName("lblStatus").Content = "Error running Disk Cleanup."
        Write-Log "Error running Disk Cleanup: $_"
    }
}

function Defragment-Drives {
    try {
        Write-Log "Starting defragmentation of drives."
        $drives = Get-PSDrive -PSProvider FileSystem
        foreach ($drive in $drives) {
            defrag $drive.Name: -w -v | Out-Null
            Write-Log "Defragmented drive: $($drive.Name):"
        }
        $window.FindName("lblStatus").Content = "Drives defragmented successfully."
        Write-Log "Drives defragmented successfully."
    } catch {
        $window.FindName("lblStatus").Content = "Error defragmenting drives."
        Write-Log "Error defragmenting drives: $_"
    }
}

function Scan-SystemForErrors {
    try {
        Write-Log "Starting system file scan."
        sfc /scannow | Out-Null
        $window.FindName("lblStatus").Content = "System scanned for errors successfully."
        Write-Log "System scanned for errors successfully."
    } catch {
        $window.FindName("lblStatus").Content = "Error scanning system for errors."
        Write-Log "Error scanning system for errors: $_"
    }
}

# Define the button click events
$btnDeleteTempFiles_Click = {
    Delete-TemporaryFiles
}

$btnEmptyRecycleBin_Click = {
    Empty-RecycleBin
}

$btnDeleteUnwantedData_Click = {
    Delete-UnwantedUserProfiles
}

$btnClearEventLogs_Click = {
    Clear-EventLogs
}

$btnDiskCleanup_Click = {
    Run-DiskCleanup
}

$btnDefragment_Click = {
    Defragment-Drives
}

$btnScanSystemForErrors_Click = {
    Scan-SystemForErrors
}

# Get the buttons from the XAML form
$btnDeleteTempFiles = $window.FindName("btnDeleteTempFiles")
$btnEmptyRecycleBin = $window.FindName("btnEmptyRecycleBin")
$btnDeleteUnwantedData = $window.FindName("btnDeleteUnwantedData")
$btnClearEventLogs = $window.FindName("btnClearEventLogs")
$btnDiskCleanup = $window.FindName("btnDiskCleanup")
$btnDefragment = $window.FindName("btnDefragment")
$btnScanSystemForErrors = $window.FindName("btnScanSystemForErrors")

# Add the button click events
$btnDeleteTempFiles.Add_Click($btnDeleteTempFiles_Click)
$btnEmptyRecycleBin.Add_Click($btnEmptyRecycleBin_Click)
$btnDeleteUnwantedData.Add_Click($btnDeleteUnwantedData_Click)
$btnClearEventLogs.Add_Click($btnClearEventLogs_Click)
$btnDiskCleanup.Add_Click($btnDiskCleanup_Click)
$btnDefragment.Add_Click($btnDefragment_Click)
$btnScanSystemForErrors.Add_Click($btnScanSystemForErrors_Click)

# Initialize Disk Cleanup settings
Start-Process -FilePath "cleanmgr.exe" -ArgumentList "/sageset:1" -Wait

# Show the XAML form
$window.ShowDialog()
