Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Drawing

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="Remote Guard Pro v18 - Ultimate Security Edition" Height="950" Width="900" Background="#121212">
    <Window.Resources>
        <Style TargetType="Button">
            <Setter Property="Background" Value="#2D2D30"/><Setter Property="Foreground" Value="#E0E0E0"/>
            <Setter Property="BorderThickness" Value="1"/><Setter Property="BorderBrush" Value="#3F3F46"/><Setter Property="Margin" Value="3"/>
            <Setter Property="Padding" Value="5"/>
        </Style>
    </Window.Resources>

    <DockPanel>
        <Border DockPanel.Dock="Top" Background="#1E1E1E" Padding="15" BorderBrush="#007ACC" BorderThickness="0,0,0,2">
            <UniformGrid Columns="4">
                <StackPanel>
                    <TextBlock Name="lblMachine" Text="OFFLINE" FontSize="16" FontWeight="Bold" Foreground="#007ACC"/>
                    <TextBlock Name="lblUser" Text="User: --" Foreground="#888888" FontSize="10"/>
                </StackPanel>
                <StackPanel VerticalAlignment="Center">
                    <TextBlock Name="lblCPU" Text="CPU: --" Foreground="White" HorizontalAlignment="Center" FontSize="10"/>
                    <ProgressBar Name="pbCPU" Height="10" Width="120" Foreground="#007ACC" Background="#333333"/>
                </StackPanel>
                <StackPanel VerticalAlignment="Center">
                    <TextBlock Name="lblRAM" Text="RAM: --" Foreground="White" HorizontalAlignment="Center" FontSize="10"/>
                    <ProgressBar Name="pbRAM" Height="10" Width="120" Foreground="#2ECC71" Background="#333333"/>
                </StackPanel>
                <Button Name="btnGlobalSync" Content="SYNC SYSTEM" Height="45" Background="#005A9E" FontWeight="Bold"/>
            </UniformGrid>
        </Border>

        <StatusBar DockPanel.Dock="Bottom" Background="#007ACC">
            <TextBlock Name="mainStatus" Text="Ready" Foreground="White" FontWeight="Bold" Margin="10,2"/>
        </StatusBar>

        <TabControl Background="#121212" BorderThickness="0">
            <TabItem Header=" Remote Shell ">
                <Grid Margin="15">
                    <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="100"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                    <TextBlock Text="PowerShell Command:" Foreground="#007ACC" Margin="0,0,0,5"/>
                    <TextBox Name="txtCommand" Grid.Row="1" Background="#1E1E1E" Foreground="#2ECC71" FontFamily="Consolas" FontSize="13" AcceptsReturn="True" VerticalScrollBarVisibility="Auto"/>
                    <Button Name="btnRunShell" Grid.Row="2" Content="RUN ON REMOTE HOST" Height="35" Background="#007ACC" FontWeight="Bold" Margin="0,10"/>
                    <TextBox Name="txtOutput" Grid.Row="3" IsReadOnly="True" Background="#050505" Foreground="#DCDCDC" FontFamily="Consolas" FontSize="12" VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Auto" AcceptsReturn="True"/>
                </Grid>
            </TabItem>

            <TabItem Header=" Security ">
                <ScrollViewer VerticalScrollBarVisibility="Auto">
                <StackPanel Margin="20">
                    <TextBlock Text="CRITICAL OVERRIDES" Foreground="#B71C1C" FontWeight="Bold" FontSize="14" Margin="0,0,0,10"/>
                    <Button Name="btnPanicMsg" Content="SEND EMERGENCY ALERT OVERLAY" Height="60" Background="#B71C1C" FontWeight="Bold"/>
                    
                    <Grid Margin="0,10">
                        <Grid.ColumnDefinitions><ColumnDefinition/><ColumnDefinition/></Grid.ColumnDefinitions>
                        <Button Name="btnBlockInput" Grid.Column="0" Content="BLOCK INPUT (60s)" Height="80" Background="#E65100"/>
                        <Button Name="btnBlackout" Grid.Column="1" Content="SCREEN BLACKOUT" Height="80" Background="#212121"/>
                    </Grid>

                    <UniformGrid Columns="2">
                        <Button Name="btnBuzzer" Content="REMOTE BUZZER (Beep)" Height="50" Background="#455A64"/>
                        <Button Name="btnRestoreDesk" Content="RESTORE DESKTOP" Height="50" Background="#2E7D32"/>
                    </UniformGrid>

                    <TextBlock Text="RESTRICTIONS" Foreground="#007ACC" FontWeight="Bold" FontSize="14" Margin="0,20,0,10"/>
                    <UniformGrid Columns="2">
                        <Button Name="btnDisableTools" Content="BLOCK TASKMGR/CMD/REG" Height="50" Background="#4E342E"/>
                        <Button Name="btnEnableTools" Content="ALLOW TASKMGR/CMD/REG" Height="50" Background="#333333"/>
                    </UniformGrid>

                    <TextBlock Text="SESSION CONTROL" Foreground="#888888" FontWeight="Bold" FontSize="14" Margin="0,20,0,10"/>
                    <UniformGrid Columns="3">
                        <Button Name="btnLock" Content="Lock Screen" Height="80"/>
                        <Button Name="btnLogoff" Content="Force Logoff" Height="80" Background="#BF360C"/>
                        <Button Name="btnRestart" Content="Restart PC" Height="80" Background="#B71C1C"/>
                    </UniformGrid>
                </StackPanel>
                </ScrollViewer>
            </TabItem>

            <TabItem Header=" Task Manager ">
                <Grid Margin="10">
                    <Grid.RowDefinitions><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                    <DataGrid Name="dgProcesses" AutoGenerateColumns="False" IsReadOnly="True" SelectionMode="Single" Background="#1E1E1E">
                        <DataGrid.Columns>
                            <DataGridTextColumn Header="PID" Binding="{Binding Id}" Width="60"/>
                            <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="200"/>
                            <DataGridTextColumn Header="CPU %" Binding="{Binding CPU}" Width="70"/>
                            <DataGridTextColumn Header="Title" Binding="{Binding Title}" Width="*"/>
                        </DataGrid.Columns>
                    </DataGrid>
                    <UniformGrid Grid.Row="1" Columns="2" Margin="0,10,0,0">
                        <Button Name="btnRefreshProc" Content="Refresh List" Height="45"/>
                        <Button Name="btnKill" Content="FORCE TERMINATE" Height="45" Background="#B71C1C" FontWeight="Bold"/>
                    </UniformGrid>
                </Grid>
            </TabItem>

            <TabItem Header=" Config ">
                <StackPanel Margin="30">
                    <TextBlock Text="Target IP:" Foreground="White"/><TextBox Name="txtHost" Text="192.168.178.89" Background="#2D2D30" Foreground="White" Margin="0,5" Padding="8"/>
                    <TextBlock Text="Admin User:" Foreground="White"/><TextBox Name="txtUser" Text="fwv" Background="#2D2D30" Foreground="White" Margin="0,5" Padding="8"/>
                    <TextBlock Text="Password:" Foreground="White"/><PasswordBox Name="txtPass" Background="#2D2D30" Foreground="White" Margin="0,5" Padding="8"/>
                </StackPanel>
            </TabItem>
        </TabControl>
    </DockPanel>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)

$xaml.SelectNodes("//*[@Name]") | ForEach-Object {
    Set-Variable -Name $_.Name -Value $window.FindName($_.Name)
}

$txtPass.Password = "1234"

function Get-Cred { 
    $sec = ConvertTo-SecureString $txtPass.Password -AsPlainText -Force
    return New-Object System.Management.Automation.PSCredential($txtUser.Text, $sec) 
}

function Exec-R ($SB, $Args = @()) {
    try {
        $mainStatus.Text = "Connecting..."
        $res = Invoke-Command -ComputerName $txtHost.Text -Credential (Get-Cred) -ScriptBlock $SB -ArgumentList $Args -ErrorAction Stop
        $mainStatus.Text = "Command Successful"
        return $res
    }
    catch {
        $mainStatus.Text = "Error: $($_.Exception.Message)"
        return "ERROR: $($_.Exception.Message)"
    }
}

$btnBlockInput.Add_Click({
        Exec-R {
            $code = '[DllImport("user32.dll")] public static extern bool BlockInput(bool fBlockIt);'
            $type = Add-Type -MemberDefinition $code -Name "Win32BlockInput" -Namespace Win32Functions -PassThru
            $type::BlockInput($true)
            Start-Sleep -Seconds 60
            $type::BlockInput($false)
        }
    })

$btnBlackout.Add_Click({
        Exec-R {
            Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
            Add-Type -AssemblyName System.Windows.Forms
            $form = New-Object Windows.Forms.Form
            $form.BackColor = "Black"
            $form.FormBorderStyle = "None"
            $form.WindowState = "Maximized"
            $form.TopMost = $true
            $form.Show()
            Start-Sleep -Seconds 15
            $form.Close()
        }
    })

$btnRestoreDesk.Add_Click({
        Exec-R { Start-Process explorer.exe }
    })

$btnBuzzer.Add_Click({
        Exec-R {
            $sessionID = (quser | Select-String ">" | ForEach-Object { ($_ -split '\s+')[2] })
            $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -Command [console]::Beep(1000,1000)"
            $taskName = "RemoteBuzzer_$(Get-Random)"
            Register-ScheduledTask -TaskName $taskName -Action $action -Force -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries) | Out-Null
            Start-ScheduledTask -TaskName $taskName
            Start-Sleep -Seconds 2
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        }
    })

$btnDisableTools.Add_Click({
        Exec-R {
            $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System"
            if (-not (Test-Path $path)) { New-Item $path -Force }
            Set-ItemProperty $path -Name "DisableTaskMgr" -Value 1
            Set-ItemProperty $path -Name "DisableRegistryTools" -Value 1
            $cmdPath = "HKCU:\Software\Policies\Microsoft\Windows\System"
            if (-not (Test-Path $cmdPath)) { New-Item $cmdPath -Force }
            Set-ItemProperty $cmdPath -Name "DisableCMD" -Value 1
        }
    })

$btnEnableTools.Add_Click({
        Exec-R {
            Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableTaskMgr" -Value 0
            Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableRegistryTools" -Value 0
            Set-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\System" -Name "DisableCMD" -Value 0
        }
    })

$btnRunShell.Add_Click({
        $localCmd = $txtCommand.Text
        if ([string]::IsNullOrWhiteSpace($localCmd)) { 
            $txtOutput.Text = "SYSTEM: Please enter a command first."
            return 
        }
    
        $txtOutput.Text = "Connecting to $($txtHost.Text) and executing...`r`n"
    
        $result = Exec-R {
            try {
                Invoke-Expression $using:localCmd 2>&1 | Out-String
            }
            catch {
                "REMOTE ERROR: " + $_.Exception.Message
            }
        }
    
        if ($result) {
            $txtOutput.Text = $result
        }
        else {
            $txtOutput.Text = "SYSTEM: Command completed but returned no data (Void)."
        }
    })

$btnGlobalSync.Add_Click({
        $stats = Exec-R {
            $os = Get-CimInstance Win32_OperatingSystem
            @{ Name = $env:COMPUTERNAME; User = (Get-CimInstance Win32_ComputerSystem).UserName; 
                CPU = (Get-CimInstance Win32_Processor).LoadPercentage; 
                RAM = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100), 0) 
            }
        }
        if ($stats -is [hashtable]) {
            $lblMachine.Text = $stats.Name; $lblUser.Text = "User: " + $stats.User
            $lblCPU.Text = "CPU: $($stats.CPU)%"; $pbCPU.Value = $stats.CPU
            $lblRAM.Text = "RAM: $($stats.RAM)%"; $pbRAM.Value = $stats.RAM
        }
    })

$btnRefreshProc.Add_Click({
        $procs = Exec-R { Get-Process | Select-Object Id, Name, @{N = 'CPU'; E = { [math]::Round($_.CPU, 1) } }, MainWindowTitle }
        if ($procs -and $procs -isnot [string]) {
            $list = New-Object System.Collections.ObjectModel.ObservableCollection[Object]
            foreach ($p in $procs) { $list.Add([PSCustomObject]@{ Id = $p.Id; Name = $p.Name; CPU = $p.CPU; Title = $p.MainWindowTitle }) }
            $dgProcesses.ItemsSource = $list
        }
    })

$btnKill.Add_Click({
        if ($dgProcesses.SelectedItem) {
            $pinid = $dgProcesses.SelectedItem.Id
            Exec-R { param($p) taskkill /F /PID $p /T } $pinid
        }
    })

$btnLock.Add_Click({
        Exec-R {
            $sessionInfo = quser | Select-String ">"
            if ($sessionInfo) {
                $sessionID = ($sessionInfo -split '\s+')[2]
                tsdiscon $sessionID
            }
            else {
                tsdiscon 1
                tsdiscon 2
            }
        }
        $mainStatus.Text = "Lock/Disconnect signal sent."
    })

$btnLogoff.Add_Click({
        Exec-R {
            $query = quser
            $session = $query | Select-String ">"
            if ($session) {
                $id = ($session -split '\s+')[2]
                logoff $id
            }
            else {
                logoff 1 
                logoff 2
            }
        }
        $mainStatus.Text = "Logoff command sent to active session."
    })

$btnRestart.Add_Click({ Exec-R { Restart-Computer -Force } })

$btnPanicMsg.Add_Click({ Exec-R { msg * /TIME:0 "ADMIN ALERT: THIS SESSION IS UNDER RESTRICTED CONTROL." } })

$window.ShowDialog() | Out-Null