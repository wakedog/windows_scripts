# Load the PresentationFramework assembly
Add-Type -AssemblyName PresentationFramework

# Define the XAML form
[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Windows Clean" Height="350" Width="400">
    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>
        <Grid.RowDefinitions>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        <StackPanel Grid.Column="0" Grid.Row="0" HorizontalAlignment="Center" VerticalAlignment="Center">
            <Button x:Name="btnDeleteTempFiles" Content="Delete Temporary Files" Width="150" Margin="5"/>
            <Button x:Name="btnEmptyRecycleBin" Content="Empty Recycle Bin" Width="150" Margin="5"/>
            <Button x:Name="btnDeleteUnwantedData" Content="Delete Unwanted Data" Width="150" Margin="5"/>
            <Button x:Name="btnDeleteEventLogData" Content="Delete Event Log Data" Width="150" Margin="5"/>
            <Button x:Name="btnClearWindowsEventLogs" Content="Clear Windows Event Logs" Width="150" Margin="5"/>
            <Button x:Name="btnScanSystemForErrors" Content="Scan System For Errors" Width="150" Margin="5"/>
        </StackPanel>
        <Label x:Name="lblStatus" Content="Status:" Grid.Column="0" Grid.Row="1" HorizontalAlignment="Left" Margin="10,0,0,0"/>
        <Label Content="Created by Wakedog" Grid.Column="0" Grid.Row="1" HorizontalAlignment="Right" Margin="0,0,10,0"/>
    </Grid>
</Window>
"@

# Create the XAML form
$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

# Define the cleanup functions
function Delete-TemporaryFiles {
    try {
        Remove-Item -Path $env:TEMP\* -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force -ErrorAction SilentlyContinue
        Remove-Item -Path "C:\Windows\Prefetch\*" -Recurse -Force -ErrorAction SilentlyContinue
        $window.FindName("lblStatus").Content = "Temporary files deleted!"
    } catch {
        $window.FindName("lblStatus").Content = "Error deleting temporary files."
    }
}

function Empty-RecycleBin {
    try {
        Clear-RecycleBin -Force -ErrorAction SilentlyContinue
        $window.FindName("lblStatus").Content = "Recycle bin emptied!"
    } catch {
        $window.FindName("lblStatus").Content = "Error emptying recycle bin."
    }
}

function Delete-UnwantedData {
    try {
        $users = Get-WmiObject -Class Win32_UserProfile
        foreach ($user in $users) {
            if ($user.LocalPath -notmatch "helpdesk|administrator|Default") {
                $user.Delete()
            }
        }
        $window.FindName("lblStatus").Content = "Unwanted data deleted!"
    } catch {
        $window.FindName("lblStatus").Content = "Error deleting unwanted data."
    }
}

function Delete-EventLogData {
    try {
        Get-EventLog -List | ForEach-Object { Clear-EventLog -LogName $_.Log }
        $window.FindName("lblStatus").Content = "Event log data deleted!"
    } catch {
        $window.FindName("lblStatus").Content = "Error deleting event log data."
    }
}

function Clear-WindowsEventLogs {
    try {
        Get-EventLog -List | ForEach-Object { Clear-EventLog -LogName $_.Log }
        $window.FindName("lblStatus").Content = "Windows event logs cleared!"
    } catch {
        $window.FindName("lblStatus").Content = "Error clearing Windows event logs."
    }
}

function Scan-SystemForErrors {
    try {
        sfc /scannow
        $window.FindName("lblStatus").Content = "System scanned for errors!"
    } catch {
        $window.FindName("lblStatus").Content = "Error scanning system for errors."
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
    Delete-UnwantedData
}

$btnDeleteEventLogData_Click = {
    Delete-EventLogData
}

$btnClearWindowsEventLogs_Click = {
    Clear-WindowsEventLogs
}

$btnScanSystemForErrors_Click = {
    Scan-SystemForErrors
}

# Get the buttons from the XAML form
$btnDeleteTempFiles = $window.FindName("btnDeleteTempFiles")
$btnEmptyRecycleBin = $window.FindName("btnEmptyRecycleBin")
$btnDeleteUnwantedData = $window.FindName("btnDeleteUnwantedData")
$btnDeleteEventLogData = $window.FindName("btnDeleteEventLogData")
$btnClearWindowsEventLogs = $window.FindName("btnClearWindowsEventLogs")
$btnScanSystemForErrors = $window.FindName("btnScanSystemForErrors")

# Add the button click events
$btnDeleteTempFiles.Add_Click($btnDeleteTempFiles_Click)
$btnEmptyRecycleBin.Add_Click($btnEmptyRecycleBin_Click)
$btnDeleteUnwantedData.Add_Click($btnDeleteUnwantedData_Click)
$btnDeleteEventLogData.Add_Click($btnDeleteEventLogData_Click)
$btnClearWindowsEventLogs.Add_Click($btnClearWindowsEventLogs_Click)
$btnScanSystemForErrors.Add_Click($btnScanSystemForErrors_Click)

# Show the XAML form
$window.ShowDialog()
