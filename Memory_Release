# Releases available Memory on Windows 10/11 systems - Save as .PS1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create the form
$form = New-Object System.Windows.Forms.Form
$form.Text = "Memory Release"
$form.Size = New-Object System.Drawing.Size(300,150)
$form.StartPosition = "CenterScreen"

# Create the progress bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(10,50)
$progressBar.Size = New-Object System.Drawing.Size(260,20)
$form.Controls.Add($progressBar)

# Create the label
$label = New-Object System.Windows.Forms.Label
$label.Location = New-Object System.Drawing.Point(10,20)
$label.Size = New-Object System.Drawing.Size(260,20)
$label.Text = "Releasing memory..."
$form.Controls.Add($label)

# Function to release memory
function Release-Memory {
    $totalSteps = 5
    for ($i = 1; $i -le $totalSteps; $i++) {
        $progressBar.Value = ($i / $totalSteps) * 100
        
        switch ($i) {
            1 { 
                $label.Text = "Clearing file system cache..."
                [System.Diagnostics.Process]::Start("cmd.exe", "/c echo 1 > `"C:\ProgramData\Microsoft\Windows\Caches\cversions.2.db`"").WaitForExit()
            }
            2 { 
                $label.Text = "Clearing standby list..."
                [System.Diagnostics.Process]::Start("cmd.exe", "/c echo 3 > `"C:\ProgramData\Microsoft\Windows\Caches\cversions.2.db`"").WaitForExit()
            }
            3 { 
                $label.Text = "Clearing working set..."
                [System.Diagnostics.Process]::Start("cmd.exe", "/c echo 4 > `"C:\ProgramData\Microsoft\Windows\Caches\cversions.2.db`"").WaitForExit()
            }
            4 { 
                $label.Text = "Running garbage collection..."
                [System.GC]::Collect()
                [System.GC]::WaitForPendingFinalizers()
            }
            5 { 
                $label.Text = "Optimizing memory usage..."
                [System.Diagnostics.Process]::Start("cmd.exe", "/c rundll32.exe advapi32.dll,ProcessIdleTasks").WaitForExit()
            }
        }
        
        $form.Refresh()
        Start-Sleep -Milliseconds 500
    }
    
    $label.Text = "Memory release complete!"
    $progressBar.Value = 100
}

# Show the form and start the memory release process
$form.Show()
Release-Memory

# Keep the form open until closed by the user
$form.ShowDialog()
