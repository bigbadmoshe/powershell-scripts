Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Drawing, System.Windows.Forms

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="pSentinel" Height="1050" Width="1400" Background="#08080A">
    <Window.Resources>
        <Style TargetType="Button" x:Key="NavBtn">
            <Setter Property="Background" Value="Transparent"/><Setter Property="Foreground" Value="#888888"/>
            <Setter Property="BorderThickness" Value="0"/><Setter Property="Height" Value="50"/><Setter Property="FontSize" Value="13"/>
            <Setter Property="HorizontalContentAlignment" Value="Left"/><Setter Property="Padding" Value="25,0,0,0"/>
            <Style.Triggers>
                <Trigger Property="IsMouseOver" Value="True"><Setter Property="Background" Value="#1A1A1D"/><Setter Property="Foreground" Value="#007ACC"/></Trigger>
            </Style.Triggers>
        </Style>
        <Style TargetType="TextBlock"><Setter Property="Foreground" Value="#DCDCDC"/></Style>
        <Style TargetType="DataGrid">
            <Setter Property="Background" Value="#111114"/><Setter Property="Foreground" Value="White"/><Setter Property="BorderThickness" Value="0"/>
            <Setter Property="RowBackground" Value="#161618"/><Setter Property="AlternatingRowBackground" Value="#111114"/><Setter Property="GridLinesVisibility" Value="None"/>
        </Style>
    </Window.Resources>

    <Grid>
        <Grid.ColumnDefinitions>
            <ColumnDefinition Width="240"/> <ColumnDefinition Width="*"/>
        </Grid.ColumnDefinitions>

        <Border Grid.Column="0" Background="#0D0D0F" BorderBrush="#1A1A1D" BorderThickness="0,0,1,0">
            <DockPanel>
                <StackPanel DockPanel.Dock="Top" Margin="25,40,20,30">
                    <TextBlock Text="pSentinel" FontSize="22" FontWeight="Bold" Foreground="#007ACC"/>
                    <TextBlock Text="Remote Administration" FontSize="10" Foreground="#555555" Margin="2,0,0,0"/>
                </StackPanel>
                
                <StackPanel>
                    <Button Name="navDash" Style="{StaticResource NavBtn}" Content="📊 Dashboard Overview"/>
                    <Button Name="navEvents" Style="{StaticResource NavBtn}" Content="🚨 System Events"/>
                    <Button Name="navProc" Style="{StaticResource NavBtn}" Content="⚙️ Active Processes"/>
                    <Button Name="navFile" Style="{StaticResource NavBtn}" Content="📂 File Explorer"/>
                    <Button Name="navNet"  Style="{StaticResource NavBtn}" Content="🌐 Network Audit"/>
                    <Button Name="navSec"  Style="{StaticResource NavBtn}" Content="🛡️ Security Center"/>
                    <Button Name="navSched" Style="{StaticResource NavBtn}" Content="⏳ Task Scheduler"/>
                    <Button Name="navSvc"  Style="{StaticResource NavBtn}" Content="🔧 System Services"/>
                    <Button Name="navCons" Style="{StaticResource NavBtn}" Content="🐚 PowerShell Console"/>
                    <Separator Background="#1A1A1D" Margin="15,10"/>
                    <Button Name="navConfig" Style="{StaticResource NavBtn}" Content="🛠️ Remote Config"/>
                </StackPanel>
            </DockPanel>
        </Border>

        <DockPanel Grid.Column="1">
            <Border DockPanel.Dock="Top" Background="#0A0A0C" Padding="25,15" BorderBrush="#1A1A1D" BorderThickness="0,0,0,1">
                <Grid>
                    <StackPanel Orientation="Horizontal">
                        <Ellipse Name="statusDot" Width="10" Height="10" Fill="#FF5555" Margin="0,0,10,0"/>
                        <TextBlock Name="lblGlobalHost" Text="REMOTE HOST: OFFLINE" FontWeight="Bold" FontSize="14" VerticalAlignment="Center"/>
                    </StackPanel>
                    <Button Name="btnGlobalSync" HorizontalAlignment="Right" Content="SYNCHRONIZE ALL" Width="160" Height="35" Background="#007ACC" Foreground="White" BorderThickness="0" FontWeight="Bold"/>
                </Grid>
            </Border>

            <StatusBar DockPanel.Dock="Bottom" Background="#007ACC" Height="25">
                <TextBlock Name="mainStatus" Text="Ready" Foreground="White" FontSize="11" Margin="15,0"/>
            </StatusBar>

            <TabControl Name="MainTabs" Background="Transparent" BorderThickness="0">
                <TabControl.Template><ControlTemplate TargetType="TabControl"><ContentPresenter ContentSource="SelectedContent"/></ControlTemplate></TabControl.Template>

                <TabItem>
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Margin="25">
                            <Grid Margin="0,0,0,20">
                                <StackPanel>
                                    <TextBlock Name="lblNodeName" Text="NODE: DISCONNECTED" FontSize="26" FontWeight="ExtraBold" Foreground="White"/>
                                    <TextBlock Name="lblNodeIP" Text="0.0.0.0 - Awaiting Telemetry" FontSize="11" Foreground="#666"/>
                                </StackPanel>
                                <Border HorizontalAlignment="Right" Background="#1A1A1D" CornerRadius="15" Padding="15,5">
                                    <StackPanel Orientation="Horizontal">
                                        <Ellipse Name="elStatus" Width="10" Height="10" Fill="#444" Margin="0,0,10,0"/>
                                        <TextBlock Name="txtStatus" Text="IDLE" Foreground="#888" VerticalAlignment="Center" FontWeight="Bold"/>
                                    </StackPanel>
                                </Border>
                            </Grid>

                            <UniformGrid Columns="4" Height="110">
                                <Border Background="#121214" Margin="4" CornerRadius="10" BorderBrush="#1A1A1D" BorderThickness="1">
                                    <StackPanel VerticalAlignment="Center" Margin="15,0">
                                        <TextBlock Text="CPU LOAD" Foreground="#007ACC" FontSize="10" FontWeight="Bold"/>
                                        <TextBlock Name="dashCPU" Text="--" FontSize="30" FontWeight="Bold" Foreground="White"/>
                                        <ProgressBar Name="pbCPU" Height="3" Background="#222" Foreground="#007ACC" BorderThickness="0" Margin="0,5,0,0"/>
                                    </StackPanel>
                                </Border>
                                <Border Background="#121214" Margin="4" CornerRadius="10" BorderBrush="#1A1A1D" BorderThickness="1">
                                    <StackPanel VerticalAlignment="Center" Margin="15,0">
                                        <TextBlock Text="MEM UTILIZATION" Foreground="#2ECC71" FontSize="10" FontWeight="Bold"/>
                                        <TextBlock Name="dashRAM" Text="--" FontSize="30" FontWeight="Bold" Foreground="White"/>
                                        <ProgressBar Name="pbRAM" Height="3" Background="#222" Foreground="#2ECC71" BorderThickness="0" Margin="0,5,0,0"/>
                                    </StackPanel>
                                </Border>
                                <Border Background="#121214" Margin="4" CornerRadius="10" BorderBrush="#1A1A1D" BorderThickness="1">
                                    <StackPanel VerticalAlignment="Center" Margin="15,0">
                                        <TextBlock Text="DISK C: HEALTH" Foreground="#E65100" FontSize="10" FontWeight="Bold"/>
                                        <TextBlock Name="dashDisk" Text="--" FontSize="30" FontWeight="Bold" Foreground="White"/>
                                        <ProgressBar Name="pbDisk" Height="3" Background="#222" Foreground="#E65100" BorderThickness="0" Margin="0,5,0,0"/>
                                    </StackPanel>
                                </Border>
                                <Border Background="#121214" Margin="4" CornerRadius="10" BorderBrush="#1A1A1D" BorderThickness="1">
                                    <StackPanel VerticalAlignment="Center" Margin="15,0">
                                        <TextBlock Text="NET RESPONSE" Foreground="#9C27B0" FontSize="10" FontWeight="Bold"/>
                                        <TextBlock Name="dashPing" Text="-- ms" FontSize="30" FontWeight="Bold" Foreground="White"/>
                                        <TextBlock Name="dashJitter" Text="STABLE" FontSize="9" Foreground="#444"/>
                                    </StackPanel>
                                </Border>
                            </UniformGrid>

                            <Grid Margin="0,15">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/><ColumnDefinition Width="*"/><ColumnDefinition Width="1.2*"/>
                                </Grid.ColumnDefinitions>

                                <Border Grid.Column="0" Background="#0D0D0F" Margin="4" CornerRadius="10" Padding="15" BorderBrush="#222" BorderThickness="1">
                                    <StackPanel>
                                        <TextBlock Text="SECURITY COMPLIANCE" Foreground="#007ACC" FontSize="10" FontWeight="Bold" Margin="0,0,0,10"/>
                                        <Grid Margin="0,4"><TextBlock Text="Firewall" Foreground="#777"/><TextBlock Name="stFW" Text="UNKNOWN" HorizontalAlignment="Right" Foreground="#444"/></Grid>
                                        <Grid Margin="0,4"><TextBlock Text="AV Real-Time" Foreground="#777"/><TextBlock Name="stAV" Text="UNKNOWN" HorizontalAlignment="Right" Foreground="#444"/></Grid>
                                        <Grid Margin="0,4"><TextBlock Text="Disk Encryption" Foreground="#777"/><TextBlock Name="stBit" Text="UNKNOWN" HorizontalAlignment="Right" Foreground="#444"/></Grid>
                                    </StackPanel>
                                </Border>

                                <Border Grid.Column="1" Background="#0D0D0F" Margin="4" CornerRadius="10" Padding="15" BorderBrush="#222" BorderThickness="1">
                                    <StackPanel>
                                        <TextBlock Text="NETWORK TOPOLOGY" Foreground="#007ACC" FontSize="10" FontWeight="Bold" Margin="0,0,0,10"/>
                                        <TextBlock Text="Primary Gateway" FontSize="9" Foreground="#555"/><TextBlock Name="stGW" Text="--.--.--.--" Margin="0,0,0,5" Foreground="#BBB"/>
                                        <TextBlock Text="Active DNS" FontSize="9" Foreground="#555"/><TextBlock Name="stDNS" Text="--.--.--.--" Foreground="#BBB"/>
                                    </StackPanel>
                                </Border>

                                <Border Grid.Column="2" Background="#140A0A" Margin="4" CornerRadius="10" Padding="15" BorderBrush="#331111" BorderThickness="1">
                                    <StackPanel>
                                        <TextBlock Text="USER SESSION" Foreground="#F44336" FontSize="10" FontWeight="Bold" Margin="0,0,0,10"/>
                                        <TextBlock Name="stUser" Text="NO SESSION" FontSize="18" Foreground="White" Margin="0,0,0,2"/>
                                        <TextBlock Name="stLogon" Text="Logon: --:--" FontSize="10" Foreground="#666"/>
                                        <TextBlock Name="stIdle" Text="Idle Time: --" FontSize="10" Foreground="#666"/>
                                    </StackPanel>
                                </Border>
                            </Grid>
                        </StackPanel>
                    </ScrollViewer>
                </TabItem>

                <TabItem>
                    <Grid Margin="30">
                        <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                        <TextBlock Text="Critical System Events (24H)" FontSize="24" FontWeight="Bold" Margin="0,0,0,20"/>
                        <Border Grid.Row="1" Background="#050505" CornerRadius="10" Padding="15" BorderBrush="#1A1A1D" BorderThickness="1">
                            <DataGrid Name="dgEvents" AutoGenerateColumns="False" Background="Transparent" Foreground="#888" BorderThickness="0" IsReadOnly="True">
                                <DataGrid.Columns>
                                    <DataGridTextColumn Header="TIME" Binding="{Binding Time}" Width="150"/>
                                    <DataGridTextColumn Header="ID" Binding="{Binding ID}" Width="60"/>
                                    <DataGridTextColumn Header="SOURCE" Binding="{Binding Source}" Width="150"/>
                                    <DataGridTextColumn Header="MESSAGE" Binding="{Binding Message}" Width="*"/>
                                </DataGrid.Columns>
                            </DataGrid>
                        </Border>
                    </Grid>
                </TabItem>

                <TabItem>
                    <Grid Margin="30">
                        <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                        <TextBlock Text="Active Processes" FontSize="24" FontWeight="Bold" Margin="0,0,0,20"/>
                        <DataGrid Name="dgProcesses" Grid.Row="1" AutoGenerateColumns="False" IsReadOnly="True">
                            <DataGrid.Columns>
                                <DataGridTextColumn Header="PID" Binding="{Binding Id}" Width="80"/>
                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="250"/>
                                <DataGridTextColumn Header="CPU %" Binding="{Binding CPU}" Width="100"/>
                                <DataGridTextColumn Header="Mem (MB)" Binding="{Binding Mem}" Width="100"/>
                                <DataGridTextColumn Header="Title" Binding="{Binding Title}" Width="*"/>
                            </DataGrid.Columns>
                        </DataGrid>
                        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,15,0,0">
                            <Button Name="btnRefreshProc" Content="REFRESH" Width="120" Height="40" Margin="0,0,10,0"/>
                            <Button Name="btnKill" Content="TERMINATE" Width="120" Height="40" Background="#B71C1C" Foreground="White"/>
                        </StackPanel>
                    </Grid>
                </TabItem>

                <TabItem>
                    <Grid Margin="30">
                        <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                        <TextBlock Text="Remote File Explorer" FontSize="24" FontWeight="Bold" Margin="0,0,0,20"/>
                        <DockPanel Grid.Row="1" Margin="0,0,0,15">
                            <Button Name="btnGoUp" Content="DIR UP" Width="80" DockPanel.Dock="Left" Margin="0,0,5,0"/>
                            <Button Name="btnListFiles" Content="BROWSE" Width="100" DockPanel.Dock="Right" Background="#007ACC" Foreground="White"/>
                            <TextBox Name="txtFilePath" Text="C:\" VerticalContentAlignment="Center" Padding="10" Background="#111114" Foreground="White" BorderBrush="#333333"/>
                        </DockPanel>
                        <DataGrid Name="dgFiles" Grid.Row="2" AutoGenerateColumns="False" IsReadOnly="True">
                            <DataGrid.Columns>
                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="*"/>
                                <DataGridTextColumn Header="Type" Binding="{Binding Type}" Width="120"/>
                                <DataGridTextColumn Header="Size (MB)" Binding="{Binding Size}" Width="120"/>
                            </DataGrid.Columns>
                        </DataGrid>
                        <Button Name="btnDeleteFile" Grid.Row="3" Content="PERMANENTLY DELETE" Height="45" Background="#B71C1C" Foreground="White" Margin="0,15,0,0"/>
                    </Grid>
                </TabItem>

                <TabItem>
                    <Grid Margin="30">
                        <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                        <TextBlock Text="Network Audit" FontSize="24" FontWeight="Bold" Margin="0,0,0,20"/>
                        <UniformGrid Grid.Row="1" Columns="3" Margin="0,0,0,15">
                            <Button Name="btnNetstat" Content="ACTIVE CONNECTIONS" Height="40" Margin="0,0,5,0"/>
                            <Button Name="btnIPConfig" Content="INTERFACE DETAILS" Height="40" Margin="5,0,5,0"/>
                            <Button Name="btnDNSTest" Content="FLUSH DNS" Height="40" Margin="5,0,0,0"/>
                        </UniformGrid>
                        <TextBox Name="txtNetOutput" Grid.Row="2" IsReadOnly="True" Background="#050505" Foreground="#00FF00" FontFamily="Consolas" VerticalScrollBarVisibility="Auto" Padding="10"/>
                    </Grid>
                </TabItem>

                <TabItem>
                    <ScrollViewer VerticalScrollBarVisibility="Auto">
                        <StackPanel Margin="30">
                            <TextBlock Text="Security &amp; Intervention" FontSize="24" FontWeight="Bold" Margin="0,0,0,25"/>
                            <TextBlock Text="CRITICAL OVERRIDES" Foreground="#B71C1C" FontWeight="Bold" FontSize="12" Margin="0,0,0,10"/>
                            <Border Background="#1A1111" Padding="25" CornerRadius="10" BorderBrush="#331111" BorderThickness="1">
                                <StackPanel>
                                    <TextBlock Text="CUSTOM OVERLAY MESSAGE" FontSize="10" Foreground="#888" Margin="0,0,0,5"/>
                                    <TextBox Name="txtCustomMsg" Text="ADMINISTRATIVE ALERT: Maintenance in progress." 
                                            Padding="10" Background="#111" Foreground="White" BorderBrush="#444" Margin="0,0,0,10"/>
                                    
                                    <Button Name="btnPanicMsg" Content="SEND ADMINISTRATIVE OVERLAY MESSAGE" Height="50" 
                                            Background="#B71C1C" Foreground="White" FontWeight="Bold" BorderThickness="0"/>
                                    <UniformGrid Columns="2" Margin="0,15,0,0">
                                        <Button Name="btnBlockInput" Content="🔒 BLOCK INPUT (60s)" Height="60" Background="#E65100" Foreground="White" Margin="0,0,5,0" BorderThickness="0"/>
                                        <Button Name="btnBlackout" Content="🌑 SCREEN BLACKOUT" Height="60" Background="#212121" Foreground="White" Margin="5,0,0,0" BorderThickness="0"/>
                                    </UniformGrid>
                                </StackPanel>
                            </Border>
                            <TextBlock Text="SYSTEM ACCESS CONTROL" Foreground="#007ACC" FontWeight="Bold" FontSize="12" Margin="0,25,0,10"/>
                            <Border Background="#121214" Padding="25" CornerRadius="10">
                                <StackPanel>
                                    <UniformGrid Columns="2">
                                        <Button Name="btnDisableTools" Content="BLOCK TASKMGR/CMD/REG" Height="45" Background="#4E342E" Foreground="White" Margin="0,0,5,0" BorderThickness="0"/>
                                        <Button Name="btnEnableTools" Content="ALLOW TASKMGR/CMD/REG" Height="45" Background="#333333" Foreground="#007ACC" Margin="5,0,0,0" BorderThickness="0"/>
                                    </UniformGrid>
                                    <UniformGrid Columns="3" Margin="0,15,0,0">
                                        <Button Name="btnLock" Content="LOCK STATION" Height="50" Background="#1E1E1E" Foreground="White" Margin="0,0,5,0" BorderThickness="0"/>
                                        <Button Name="btnLogoff" Content="FORCE LOGOFF" Height="50" Background="#BF360C" Foreground="White" Margin="5,0,5,0" BorderThickness="0"/>
                                        <Button Name="btnRestart" Content="FORCE RESTART" Height="50" Background="#B71C1C" Foreground="White" Margin="5,0,0,0" BorderThickness="0"/>
                                    </UniformGrid>
                                    <Button Name="btnBuzzer" Content="SEND REMOTE BUZZER (BEEP)" Height="40" Background="#2E7D32" Foreground="White" Margin="0,15,0,0" BorderThickness="0"/>
                                </StackPanel>
                            </Border>
                        </StackPanel>
                    </ScrollViewer>
                </TabItem>

                <TabItem>
                    <Grid Margin="30">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="250"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        
                        <TextBlock Text="Enterprise Task Management" FontSize="26" Foreground="White" Margin="0,0,0,20"/>
                        
                        <Border Grid.Row="1" Background="#0A0A10" Padding="20" CornerRadius="8" Margin="0,0,0,20" BorderBrush="#1A1A25" BorderThickness="1">
                            <Grid>
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                <StackPanel Grid.Column="0" Margin="0,0,10,0">
                                    <TextBlock Text="TASK NAME" FontSize="10" Foreground="#00A2FF" Margin="0,0,0,5"/>
                                    <TextBox Name="txtSchedName" Text="ApexWatchdog" Padding="8" Background="#15151A" Foreground="White" BorderThickness="1" BorderBrush="#333"/>
                                    <TextBlock Text="EXECUTABLE / COMMAND" FontSize="10" Foreground="#00A2FF" Margin="0,10,0,5"/>
                                    <TextBox Name="txtSchedPath" Text="powershell.exe" Padding="8" Background="#15151A" Foreground="White" BorderThickness="1" BorderBrush="#333"/>
                                </StackPanel>
                                <StackPanel Grid.Column="1" Margin="10,0,0,0">
                                    <TextBlock Text="ARGUMENTS" FontSize="10" Foreground="#00A2FF" Margin="0,0,0,5"/>
                                    <TextBox Name="txtSchedArgs" Text="-NoProfile -WindowStyle Hidden" Padding="8" Background="#15151A" Foreground="White" BorderThickness="1" BorderBrush="#333"/>
                                    <Button Name="btnCreateTask" Content="REGISTER NEW TASK" Height="42" Margin="0,20,0,0" Background="#2E7D32" Foreground="White" FontWeight="Bold" BorderThickness="0"/>
                                </StackPanel>
                            </Grid>
                        </Border>

                        <DataGrid Name="dgTasks" Grid.Row="2" AutoGenerateColumns="False" IsReadOnly="True" SelectionMode="Single">
                            <DataGrid.Columns>
                                <DataGridTextColumn Header="TASK NAME" Binding="{Binding Name}" Width="250"/>
                                <DataGridTextColumn Header="STATE" Binding="{Binding State}" Width="100"/>
                                <DataGridTextColumn Header="LAST RESULT" Binding="{Binding LastResult}" Width="120"/>
                                <DataGridTextColumn Header="NEXT RUN" Binding="{Binding NextRun}" Width="180"/>
                                <DataGridTextColumn Header="AUTHOR" Binding="{Binding Author}" Width="*"/>
                            </DataGrid.Columns>
                        </DataGrid>

                        <UniformGrid Grid.Row="3" Columns="5" Margin="0,15,0,0">
                            <Button Name="btnSchedRefresh" Content="🔄 REFRESH" Height="45" Margin="0,0,5,0" Background="#1A1A25" Foreground="White"/>
                            <Button Name="btnSchedStart"   Content="▶️ RUN" Height="45" Margin="5,0,5,0" Background="#0D47A1" Foreground="White"/>
                            <Button Name="btnSchedStop"    Content="⏹️ STOP" Height="45" Margin="5,0,5,0" Background="#B71C1C" Foreground="White"/>
                            <Button Name="btnSchedEnable"  Content="🔓 ENABLE" Height="45" Margin="5,0,5,0" Background="#2E7D32" Foreground="White"/>
                            <Button Name="btnSchedDelete"  Content="🗑️ DELETE" Height="45" Margin="5,0,0,0" Background="#D32F2F" Foreground="White"/>
                        </UniformGrid>
                    </Grid>
                </TabItem>

                <TabItem>
                    <Grid Margin="30">
                        <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
                        <TextBlock Text="System Services" FontSize="24" FontWeight="Bold" Margin="0,0,0,20"/>
                        <DataGrid Name="dgServices" Grid.Row="1" AutoGenerateColumns="False">
                            <DataGrid.Columns>
                                <DataGridTextColumn Header="Name" Binding="{Binding Name}" Width="200"/>
                                <DataGridTextColumn Header="Display Name" Binding="{Binding Display}" Width="*"/>
                                <DataGridTextColumn Header="Status" Binding="{Binding Status}" Width="120"/>
                            </DataGrid.Columns>
                        </DataGrid>
                        <UniformGrid Grid.Row="2" Columns="3" Margin="0,15,0,0">
                            <Button Name="btnSvcStart" Content="START" Height="45" Background="#2E7D32" Foreground="White" Margin="0,0,5,0"/>
                            <Button Name="btnSvcStop" Content="STOP" Height="45" Background="#B71C1C" Foreground="White" Margin="5,0,5,0"/>
                            <Button Name="btnSvcRefresh" Content="REFRESH" Height="45" Margin="5,0,0,0"/>
                        </UniformGrid>
                    </Grid>
                </TabItem>

                <TabItem>
                    <Grid Margin="30">
                        <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="200"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/></Grid.RowDefinitions>
                        <TextBlock Text="PowerShell Console" FontSize="24" FontWeight="Bold" Margin="0,0,0,20"/>
                        <TextBox Name="txtCommand" Grid.Row="1" Background="#1E1E1E" Foreground="#2ECC71" FontFamily="Consolas" AcceptsReturn="True" VerticalScrollBarVisibility="Auto" Padding="10"/>
                        <Button Name="btnRunShell" Grid.Row="2" Content="EXECUTE SCRIPT" Height="40" Background="#007ACC" Foreground="White" Margin="0,15"/>
                        <TextBox Name="txtOutput" Grid.Row="3" IsReadOnly="True" Background="#050505" Foreground="#DCDCDC" FontFamily="Consolas" VerticalScrollBarVisibility="Auto" Padding="10"/>
                    </Grid>
                </TabItem>

                <TabItem>
                    <StackPanel Margin="100,50">
                        <TextBlock Text="Remote Authentication Config" FontSize="24" FontWeight="Bold" Margin="0,0,0,30"/>
                        <TextBlock Text="Target IP / Hostname"/><TextBox Name="txtHost" Text="127.0.0.1" Margin="0,5,0,20" Padding="12" Background="#111114" Foreground="White"/>
                        <TextBlock Text="Admin Username"/><TextBox Name="txtUser" Text="Administrator" Margin="0,5,0,20" Padding="12" Background="#111114" Foreground="White"/>
                        <TextBlock Text="Access Password"/><PasswordBox Name="txtPass" Margin="0,5,0,30" Padding="12" Background="#111114" Foreground="White"/>
                    </StackPanel>
                </TabItem>
            </TabControl>
        </DockPanel>
    </Grid>
</Window>
"@

$reader = (New-Object System.Xml.XmlNodeReader $xaml)
$window = [Windows.Markup.XamlReader]::Load($reader)
$xaml.SelectNodes("//*[@Name]") | ForEach-Object { Set-Variable -Name $_.Name -Value $window.FindName($_.Name) -Scope Global }

function Get-Cred { 
    $sec = ConvertTo-SecureString $txtPass.Password -AsPlainText -Force
    return New-Object System.Management.Automation.PSCredential($txtUser.Text, $sec) 
}

function Exec-R ($SB, $Param) {
    try {
        $mainStatus.Text = "Connecting to $($txtHost.Text)..."
        $res = Invoke-Command -ComputerName $txtHost.Text -Credential (Get-Cred) -ScriptBlock $SB -ArgumentList $Param -ErrorAction Stop
        $mainStatus.Text = "Ready."
        $statusDot.Fill = "#2ECC71"
        return $res
    }
    catch {
        if ($_.Exception.Message -like "*TrustedHosts*") {
            if (Add-ToTrustedHosts -IP $txtHost.Text) {
                return Exec-R $SB $Param 
            }
        }
        $mainStatus.Text = "Connection Failed: $($_.Exception.Message)"
        $statusDot.Fill = "#FF5555"
        return $null
    }
}

function Add-ToTrustedHosts {
    param ([string]$IP)
    $current = (Get-Item WSMan:\localhost\Client\TrustedHosts).Value
    if ($current -split ',' -contains $IP -or $current -eq '*') { return $true }
    $msg = "The host '$IP' is not in your TrustedHosts list. WinRM requires this for non-domain connections.`n`nDo you want to add it automatically?"
    $confirm = [System.Windows.MessageBox]::Show($msg, "Security Authorization", 'YesNo', 'Warning')
    if ($confirm -eq 'Yes') {
        try {
            $newVal = if ([string]::IsNullOrWhiteSpace($current)) { $IP } else { "$current,$IP" }
            Set-Item WSMan:\localhost\Client\TrustedHosts -Value $newVal -Force -Confirm:$false
            $mainStatus.Text = "Added $IP to Trusted Hosts."
            return $true
        }
        catch {
            [System.Windows.MessageBox]::Show("Failed to update TrustedHosts. Please run PowerShell as Administrator.", "Access Denied")
            return $false
        }
    }
    return $false
}

$nodes = @(
    "lblNodeName", "lblNodeIP", "dashCPU", "pbCPU", "dashRAM", "pbRAM", 
    "dashDisk", "pbDisk", "dashPing", "stFW", "stAV", "stBit", 
    "stGW", "stDNS", "stUser", "stLogon", "stIdle", "dgEvents", "txtStatus", "elStatus"
)

foreach ($node in $nodes) {
    Set-Variable -Name $node -Value $window.FindName($node) -Scope Global
}

$navDash.Add_Click({ $MainTabs.SelectedIndex = 0 })
$navEvents.Add_Click({ $MainTabs.SelectedIndex = 1 })
$navProc.Add_Click({ $MainTabs.SelectedIndex = 2 })
$navFile.Add_Click({ $MainTabs.SelectedIndex = 3 })
$navNet.Add_Click({ $MainTabs.SelectedIndex = 4 })
$navSec.Add_Click({ $MainTabs.SelectedIndex = 5 })
$navSched.Add_Click({ $MainTabs.SelectedIndex = 6 })
$navSvc.Add_Click({ $MainTabs.SelectedIndex = 7 })
$navCons.Add_Click({ $MainTabs.SelectedIndex = 8 })
$navConfig.Add_Click({ $MainTabs.SelectedIndex = 9 })

$btnGlobalSync.Add_Click({
        $target = $txtHost.Text
        $txtStatus.Text = "POLLING..."
        $elStatus.Fill = [System.Windows.Media.Brushes]::Orange
        $p = Test-Connection -ComputerName $target -Count 1 -ErrorAction SilentlyContinue
        $latency = if ($p) { $p.ResponseTime } else { 999 }
        $data = Exec-R {
            try {
                $os = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
                $cpu = Get-CimInstance Win32_Processor
                $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
                $net = Get-NetIPConfiguration | Where-Object { $_.IPv4Address -ne $null } | Select-Object -First 1
                $mp = Get-MpComputerStatus
                $bit = Get-BitLockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue
                $u = "None"; $l = "N/A"; $i = "N/A"
                $q = quser 2>$null
                if ($q) { $f = $q[1] -split '\s+'; $u = $f[1]; $l = "$($f[5]) $($f[6])"; $i = $f[7] }
                $ev = Get-WinEvent -FilterHashtable @{LogName = 'System'; Level = 1, 2 } -MaxEvents 10 -ErrorAction SilentlyContinue | ForEach-Object {
                    [PSCustomObject]@{ Time = $_.TimeCreated.ToString("HH:mm"); ID = $_.Id; Source = $_.ProviderName; Message = $_.Message.Trim() }
                }
                return @{
                    Name = $env:COMPUTERNAME; IP = $net.IPv4Address[0].IPAddress;
                    CPU = $cpu.LoadPercentage;
                    RAM = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize * 100), 0);
                    Disk = [math]::Round((1 - ($disk.FreeSpace / $disk.Size)) * 100, 0);
                    GW = $net.IPv4DefaultGateway.NextHop; DNS = $net.DNSServer.ServerAddresses[0];
                    FW = (Get-NetFirewallProfile -Profile Domain).Enabled;
                    AV = $mp.RealTimeProtectionEnabled; Bit = ($bit.ProtectionStatus -eq "On");
                    User = $u; Logon = $l; Idle = $i; Events = $ev; Success = $true
                }
            }
            catch { return @{ Success = $false; Msg = $_.Exception.Message } }
        }
        if ($data.Success) {
            $lblNodeName.Text = "NODE: $($data.Name)"
            $lblNodeIP.Text = "$($data.IP) | Latency: $($latency)ms"
            $dashCPU.Text = "$($data.CPU)%"; $pbCPU.Value = $data.CPU
            $dashRAM.Text = "$($data.RAM)%"; $pbRAM.Value = $data.RAM
            $dashDisk.Text = "$($data.Disk)%"; $pbDisk.Value = $data.Disk
            $dashPing.Text = "$($latency)ms"
            $stFW.Text = if ($data.FW) { "SECURE" }else { "OFF" }; $stFW.Foreground = if ($data.FW) { "#2ECC71" }else { "#F44336" }
            $stAV.Text = if ($data.AV) { "ACTIVE" }else { "DISABLED" }; $stAV.Foreground = if ($data.AV) { "#2ECC71" }else { "#F44336" }
            $stBit.Text = if ($data.Bit) { "ENCRYPTED" }else { "PLAIN" }; $stBit.Foreground = if ($data.Bit) { "#2ECC71" }else { "#E65100" }
            $stGW.Text = $data.GW; $stDNS.Text = $data.DNS
            $stUser.Text = $data.User; $stLogon.Text = "Logon: $($data.Logon)"; $stIdle.Text = "Idle: $($data.Idle)"
            $dgEvents.ItemsSource = $data.Events
            $txtStatus.Text = "ONLINE"; $elStatus.Fill = [System.Windows.Media.Brushes]::LimeGreen
        }
        else {
            $txtStatus.Text = "ERROR"; $elStatus.Fill = [System.Windows.Media.Brushes]::Red
            $lblNodeName.Text = "CONNECTION FAILED"
        }
    })

$btnRefreshProc.Add_Click({
        $pList = Exec-R { Get-Process | Select-Object Id, ProcessName, @{N = 'CPU'; E = { [math]::Round($_.CPU, 1) } }, @{N = 'WS'; E = { [math]::Round($_.WorkingSet / 1MB, 1) } }, MainWindowTitle }
        $dgProcesses.ItemsSource = foreach ($p in $pList) { [PSCustomObject]@{ Id = $p.Id; Name = $p.ProcessName; CPU = $p.CPU; Mem = $p.WS; Title = $p.MainWindowTitle } }
    })
$btnKill.Add_Click({
        if ($dgProcesses.SelectedItem) { Exec-R { param($id) Stop-Process -Id $id -Force } $dgProcesses.SelectedItem.Id; $btnRefreshProc.RaiseEvent((New-Object RoutedEventArgs([Button]::ClickEvent))) }
    })

$btnListFiles.Add_Click({
        $path = $txtFilePath.Text
        $mainStatus.Text = "Fetching file list..."
        $results = Exec-R { 
            param($p) 
            Get-ChildItem -Path $p -ErrorAction SilentlyContinue | ForEach-Object { 
                [PSCustomObject]@{ 
                    Name = $_.Name
                    Type = if ($_.PSIsContainer) { "Folder" } else { "File" }
                    Size = if ($_.PSIsContainer) { "--" } else { [math]::Round($_.Length / 1MB, 2) }
                } 
            } 
        } $path
        if ($results) {
            $dgFiles.ItemsSource = $null # Clear old data
            $dgFiles.ItemsSource = [System.Collections.ArrayList]@($results)
            $mainStatus.Text = "Displayed $($results.Count) items."
        }
        else {
            $mainStatus.Text = "No items found or path inaccessible."
        }
    })

$btnNetstat.Add_Click({ $txtNetOutput.Text = Exec-R { netstat -ano | Select-Object -First 50 | Out-String } })

$btnIPConfig.Add_Click({ $txtNetOutput.Text = Exec-R { ipconfig /all | Out-String } })

$btnPanicMsg.Add_Click({
        $customMessage = $txtCustomMsg.Text
        if ([string]::IsNullOrWhiteSpace($customMessage)) {
            $mainStatus.Text = "Error: Message cannot be empty."
            return
        }
        Exec-R { 
            param($msg) 
            msg * "$msg" 
        } $customMessage
        $mainStatus.Text = "Message sent to all sessions."
    })

$btnBlockInput.Add_Click({
        Exec-R {
            $code = '[DllImport("user32.dll")] public static extern bool BlockInput(bool fBlockIt);'
            $type = Add-Type -MemberDefinition $code -Name "Win32BlockInput" -Namespace Win32Functions -PassThru
            $type::BlockInput($true)
            Start-Sleep -Seconds 60
            $type::BlockInput($false)
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

$btnRestart.Add_Click({ Exec-R { Restart-Computer -Force } })

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

$btnRunShell.Add_Click({ $cmd = $txtCommand.Text; $txtOutput.Text = Exec-R { param($c) Invoke-Expression $c 2>&1 | Out-String } $cmd })

$btnSvcRefresh.Add_Click({
        $svcs = Exec-R { Get-Service | Select-Object Name, DisplayName, Status }
        $dgServices.ItemsSource = foreach ($s in $svcs) { [PSCustomObject]@{ Name = $s.Name; Display = $s.DisplayName; Status = $s.Status.ToString() } }
    })

$window.ShowDialog() | Out-Null