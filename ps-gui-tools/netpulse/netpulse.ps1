Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

if (-not ([System.Management.Automation.PSTypeName]'IconHelper').Type) {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class IconHelper {
        [DllImport("user32.dll")]
        public static extern bool DestroyIcon(IntPtr handle);
    }
"@
}

$configPath = "$env:TEMP\NetPulse_Ultra_V2.json"
$config = if (Test-Path $configPath) { 
    try { Get-Content $configPath -Raw | ConvertFrom-Json } catch { $null }
} 

if ($null -eq $config) {
    $config = [PSCustomObject]@{ 
        Host      = "8.8.8.8"
        Threshold = 100 
        LogPath   = "$env:USERPROFILE\Desktop\NetPulse_Log.csv"
        Interval  = 1000
        AutoStart = $false
    }
}

$pingHistory = [System.Collections.Generic.Queue[int]]::new()
$eventLog = New-Object System.Collections.ObjectModel.ObservableCollection[PSCustomObject]
$sessionStats = [PSCustomObject]@{ 
    TotalPings = 0; FailedPings = 0; MaxLat = 0; MinLat = 9999; LastLat = 0; StartTime = Get-Date; Jitter = 0 
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="NetPulse Ultra" Height="750" Width="1150" 
        WindowStartupLocation="CenterScreen" Background="Transparent" AllowsTransparency="True" WindowStyle="None"
        FontFamily="Segoe UI Variable Text">
    
    <Border Name="MainBorder" CornerRadius="28" Background="#0C0C0F" BorderBrush="#25252A" BorderThickness="1.5">
        <Grid>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="90"/>
                <ColumnDefinition Width="*"/>
            </Grid.ColumnDefinitions>

            <!-- Navigation Sidebar -->
            <Border Grid.Column="0" Background="#121218" CornerRadius="28,0,0,28">
                <Grid>
                    <StackPanel Margin="0,40,0,0">
                        <TextBlock Text="&#xEB55;" FontFamily="Segoe MDL2 Assets" FontSize="32" Foreground="#0078D7" HorizontalAlignment="Center" Margin="0,0,0,50"/>
                        <Button Name="navDash" Content="&#xE80F;" ToolTip="Command Center" FontFamily="Segoe MDL2 Assets" Height="70" Background="Transparent" BorderThickness="0" Foreground="White" FontSize="26"/>
                        <Button Name="navLogs" Content="&#xE81C;" ToolTip="Traffic Logs" FontFamily="Segoe MDL2 Assets" Height="70" Background="Transparent" BorderThickness="0" Foreground="#555" FontSize="26"/>
                        <Button Name="navInfo" Content="&#xE946;" ToolTip="Advanced Diagnostics" FontFamily="Segoe MDL2 Assets" Height="70" Background="Transparent" BorderThickness="0" Foreground="#555" FontSize="26"/>
                        <Button Name="navSet" Content="&#xE713;" ToolTip="Engine Settings" FontFamily="Segoe MDL2 Assets" Height="70" Background="Transparent" BorderThickness="0" Foreground="#555" FontSize="26"/>
                    </StackPanel>
                    <Button Name="btnExit" Content="&#xE711;" FontFamily="Segoe MDL2 Assets" Height="70" Background="Transparent" BorderThickness="0" Foreground="#E81123" Opacity="0.5" FontSize="22" VerticalAlignment="Bottom" Margin="0,0,0,30"/>
                </Grid>
            </Border>

            <!-- Main Workspace -->
            <Grid Grid.Column="1" Margin="45,35">
                <StackPanel VerticalAlignment="Top" HorizontalAlignment="Right" Orientation="Horizontal">
                    <Button Name="btnMin" Content="&#xE949;" FontFamily="Segoe MDL2 Assets" Background="Transparent" BorderThickness="0" Foreground="#444" FontSize="18" Margin="0,0,15,0"/>
                </StackPanel>

                <!-- PAGE 1: DASHBOARD -->
                <Grid Name="pageDash" Visibility="Visible">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <StackPanel Grid.Row="0">
                        <TextBlock Text="Network Intelligence" FontSize="38" FontWeight="Bold" Foreground="White"/>
                        <StackPanel Orientation="Horizontal" Margin="2,5,0,0">
                             <TextBlock Name="lblHostSub" Text="Host: 8.8.8.8" Foreground="#666" FontSize="14" FontWeight="SemiBold"/>
                             <TextBlock Text=" • " Foreground="#333" Margin="8,0"/>
                             <TextBlock Name="lblStatus" Text="CORE IDLE" Foreground="#0078D7" FontSize="14" FontWeight="Bold"/>
                        </StackPanel>
                    </StackPanel>

                    <Grid Grid.Row="1" Margin="0,30">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="1.3*"/>
                            <ColumnDefinition Width="2*"/>
                        </Grid.ColumnDefinitions>

                        <!-- Primary Gauge -->
                        <StackPanel Grid.Column="0" VerticalAlignment="Center">
                            <Grid HorizontalAlignment="Center">
                                <Ellipse Width="230" Height="230" Stroke="#16161D" StrokeThickness="18"/>
                                <Ellipse Name="ringProgress" Width="230" Height="230" Stroke="#2A2A2E" StrokeThickness="18" StrokeDashArray="8,2"/>
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Name="lblBigPing" Text="--" FontSize="76" FontWeight="Black" Foreground="White" HorizontalAlignment="Center"/>
                                    <TextBlock Text="MILLISECONDS" FontSize="11" Foreground="#444" FontWeight="Bold" HorizontalAlignment="Center"/>
                                </StackPanel>
                            </Grid>
                            
                            <UniformGrid Columns="2" Margin="0,35,0,0" Width="240">
                                <StackPanel HorizontalAlignment="Center">
                                    <TextBlock Text="&#xE898;" FontFamily="Segoe MDL2 Assets" Foreground="#0078D7" FontSize="18" HorizontalAlignment="Center"/>
                                    <TextBlock Text="UPLOAD" Foreground="#444" FontSize="9" FontWeight="Bold" HorizontalAlignment="Center" Margin="0,2,0,4"/>
                                    <TextBlock Name="txtSendRate" Text="0 Kbps" Foreground="White" FontSize="16" FontWeight="Bold" HorizontalAlignment="Center" FontFamily="Consolas"/>
                                </StackPanel>
                                <StackPanel HorizontalAlignment="Center">
                                    <TextBlock Text="&#xE896;" FontFamily="Segoe MDL2 Assets" Foreground="#44E811" FontSize="18" HorizontalAlignment="Center"/>
                                    <TextBlock Text="DOWNLOAD" Foreground="#444" FontSize="9" FontWeight="Bold" HorizontalAlignment="Center" Margin="0,2,0,4"/>
                                    <TextBlock Name="txtRecvRate" Text="0 Kbps" Foreground="White" FontSize="16" FontWeight="Bold" HorizontalAlignment="Center" FontFamily="Consolas"/>
                                </StackPanel>
                            </UniformGrid>
                        </StackPanel>

                        <!-- Analytics Side -->
                        <StackPanel Grid.Column="1" Margin="45,0,0,0">
                            <Border Background="#121218" CornerRadius="20" Padding="25" BorderBrush="#1F1F24" BorderThickness="1">
                                <StackPanel>
                                    <TextBlock Text="STABILITY TREND" FontSize="11" Foreground="#0078D7" FontWeight="Bold" Margin="0,0,0,20"/>
                                    <Canvas Name="canvas" Height="150" Background="Transparent" ClipToBounds="True">
                                        <Polyline Name="polyline" Stroke="#0078D7" StrokeThickness="3.5" StrokeLineJoin="Round"/>
                                    </Canvas>
                                </StackPanel>
                            </Border>
                            
                            <UniformGrid Columns="3" Margin="0,30,0,0">
                                <StackPanel Margin="0,0,0,20"><TextBlock Text="MINIMUM" Foreground="#444" FontSize="11" FontWeight="Bold"/><TextBlock Name="txtMin" Text="---" Foreground="White" FontSize="20" FontWeight="SemiBold" FontFamily="Consolas"/></StackPanel>
                                <StackPanel Margin="0,0,0,20"><TextBlock Text="AVERAGE" Foreground="#444" FontSize="11" FontWeight="Bold"/><TextBlock Name="txtAvg" Text="---" Foreground="#0078D7" FontSize="20" FontWeight="SemiBold" FontFamily="Consolas"/></StackPanel>
                                <StackPanel Margin="0,0,0,20"><TextBlock Text="MAXIMUM" Foreground="#444" FontSize="11" FontWeight="Bold"/><TextBlock Name="txtMax" Text="---" Foreground="White" FontSize="20" FontWeight="SemiBold" FontFamily="Consolas"/></StackPanel>
                                
                                <StackPanel><TextBlock Text="JITTER" Foreground="#444" FontSize="11" FontWeight="Bold"/><TextBlock Name="txtJitter" Text="---" Foreground="#FFB900" FontSize="20" FontWeight="SemiBold" FontFamily="Consolas"/></StackPanel>
                                <StackPanel><TextBlock Text="LOSS" Foreground="#444" FontSize="11" FontWeight="Bold"/><TextBlock Name="txtLoss" Text="0" Foreground="#E81123" FontSize="20" FontWeight="SemiBold" FontFamily="Consolas"/></StackPanel>
                                <StackPanel><TextBlock Text="RANKING" Foreground="#444" FontSize="11" FontWeight="Bold"/><TextBlock Name="txtQuality" Text="IDLE" Foreground="#555" FontSize="20" FontWeight="Bold"/></StackPanel>
                            </UniformGrid>
                        </StackPanel>
                    </Grid>

                    <!-- Control Strip -->
                    <Grid Grid.Row="2">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="Auto"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>
                        <Button Name="btnAction" Content="START CORE" Width="220" Height="55" Background="#0078D7" Foreground="White" FontWeight="Bold" FontSize="15">
                            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="27"/></Style></Button.Resources>
                        </Button>
                        <StackPanel Grid.Column="1" Margin="30,0,0,0" VerticalAlignment="Center">
                             <TextBlock Name="lblAlert" Text="" Foreground="#E81123" FontWeight="Bold" FontSize="14"/>
                             <TextBlock Name="txtUptime" Text="System Ready" Foreground="#555" FontSize="12"/>
                        </StackPanel>
                    </Grid>
                </Grid>

                <!-- PAGE 2: LOGS -->
                <Grid Name="pageLogs" Visibility="Collapsed">
                    <StackPanel>
                        <TextBlock Text="Event Timeline" FontSize="34" Foreground="White" FontWeight="Bold"/>
                        <TextBlock Text="Detailed packet-by-packet analysis and anomaly detection." Foreground="#555" Margin="0,5,0,20"/>
                        <ListBox Name="lstLogs" Height="420" Background="#121218" Foreground="#888" BorderThickness="0" FontFamily="Consolas" FontSize="13">
                             <ListBox.ItemTemplate>
                                <DataTemplate>
                                    <Border BorderBrush="#1A1A1F" BorderThickness="0,0,0,1" Padding="5">
                                        <TextBlock Text="{Binding Display}" Foreground="{Binding Color}"/>
                                    </Border>
                                </DataTemplate>
                             </ListBox.ItemTemplate>
                        </ListBox>
                        <StackPanel Orientation="Horizontal" Margin="0,20,0,0">
                            <Button Name="btnExport" Content="Export Data" Width="160" Height="40" Background="#0078D7" Foreground="White" FontWeight="SemiBold"/>
                            <Button Name="btnClearLogs" Content="Purge History" Width="130" Height="40" Background="#1A1A1F" Foreground="#666" Margin="10,0"/>
                        </StackPanel>
                    </StackPanel>
                </Grid>

                <!-- PAGE 3: EXPANDED INFO -->
                <Grid Name="pageInfo" Visibility="Collapsed">
                    <StackPanel>
                        <TextBlock Text="Diagnostic Context" FontSize="34" Foreground="White" FontWeight="Bold" Margin="0,0,0,25"/>
                        <UniformGrid Columns="2">
                            <Border Background="#121218" Margin="8" Padding="25" CornerRadius="20" BorderBrush="#1F1F24" BorderThickness="1">
                                <StackPanel><TextBlock Text="LOCAL GATEWAY" Foreground="#0078D7" FontWeight="Bold" FontSize="11" Margin="0,0,0,8"/><TextBlock Name="txtLocalIP" Text="---" Foreground="White" FontSize="22" FontFamily="Consolas"/></StackPanel>
                            </Border>
                            <Border Background="#121218" Margin="8" Padding="25" CornerRadius="20" BorderBrush="#1F1F24" BorderThickness="1">
                                <StackPanel><TextBlock Text="DEFAULT ROUTER" Foreground="#0078D7" FontWeight="Bold" FontSize="11" Margin="0,0,0,8"/><TextBlock Name="txtGateway" Text="---" Foreground="White" FontSize="22" FontFamily="Consolas"/></StackPanel>
                            </Border>
                            <Border Background="#121218" Margin="8" Padding="25" CornerRadius="20" BorderBrush="#1F1F24" BorderThickness="1">
                                <StackPanel><TextBlock Text="EXTERNAL WAN IP" Foreground="#FFB900" FontWeight="Bold" FontSize="11" Margin="0,0,0,8"/><TextBlock Name="txtPublicIP" Text="Detecting..." Foreground="White" FontSize="22" FontFamily="Consolas"/></StackPanel>
                            </Border>
                            <Border Background="#121218" Margin="8" Padding="25" CornerRadius="20" BorderBrush="#1F1F24" BorderThickness="1">
                                <StackPanel><TextBlock Text="PRIMARY DNS" Foreground="#0078D7" FontWeight="Bold" FontSize="11" Margin="0,0,0,8"/><TextBlock Name="txtDNS" Text="---" Foreground="White" FontSize="22" FontFamily="Consolas"/></StackPanel>
                            </Border>
                        </UniformGrid>
                        
                        <Border Background="#1A1A1F" CornerRadius="15" Padding="20" Margin="8,20,8,0">
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="Auto"/>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>
                                <TextBlock Grid.Column="0" Name="txtAdapterType" Text="&#xE839;" FontFamily="Segoe MDL2 Assets" Foreground="#0078D7" FontSize="24" VerticalAlignment="Center"/>
                                <StackPanel Grid.Column="1" Margin="20,0">
                                    <TextBlock Name="txtAdapterName" Text="Network Controller" Foreground="White" FontSize="16" FontWeight="Bold"/>
                                    <TextBlock Text="HARDWARE INTERFACE" Foreground="#444" FontSize="10" FontWeight="Black"/>
                                </StackPanel>
                                <TextBlock Grid.Column="2" Name="txtLinkSpeed" Text="--- Mbps" Foreground="#44E811" FontWeight="Bold" FontSize="18" VerticalAlignment="Center" FontFamily="Consolas"/>
                            </Grid>
                        </Border>
                        
                        <Button Name="btnRefreshNet" Content="Re-Scan Network Topology" Margin="8,30,0,0" Width="240" Height="45" Background="#0078D7" Foreground="White" FontWeight="Bold">
                            <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="10"/></Style></Button.Resources>
                        </Button>
                    </StackPanel>
                </Grid>

                <!-- PAGE 4: SETTINGS -->
                <StackPanel Name="pageSet" Visibility="Collapsed">
                    <TextBlock Text="Engine Config" FontSize="34" Foreground="White" FontWeight="Bold" Margin="0,0,0,25"/>
                    
                    <ScrollViewer Height="480" VerticalScrollBarVisibility="Auto">
                        <StackPanel Margin="0,0,15,0">
                            <!-- Section: Connection -->
                            <TextBlock Text="TARGET ENDPOINT" Foreground="#0078D7" FontWeight="Bold" FontSize="12" Margin="0,0,0,8"/>
                            <TextBox Name="editHost" Text="8.8.8.8" Padding="15" Background="#121218" Foreground="White" BorderThickness="1" BorderBrush="#25252A" Margin="0,0,0,20" FontFamily="Consolas" FontSize="16"/>
                            
                            <!-- Section: Timing -->
                            <Grid Margin="0,0,0,20">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="*"/>
                                </Grid.ColumnDefinitions>
                                <StackPanel Grid.Column="0" Margin="0,0,10,0">
                                    <TextBlock Text="POLLING INTERVAL (ms)" Foreground="#555" FontWeight="Bold" FontSize="11" Margin="0,0,0,8"/>
                                    <TextBox Name="editInterval" Text="1000" Padding="10" Background="#121218" Foreground="White" BorderThickness="1" BorderBrush="#25252A" FontFamily="Consolas"/>
                                </StackPanel>
                                <StackPanel Grid.Column="1" Margin="10,0,0,0">
                                    <TextBlock Text="ALARM THRESHOLD" Foreground="#555" FontWeight="Bold" FontSize="11" Margin="0,0,0,8"/>
                                    <TextBlock Name="lblThreshVal" Text="100 ms" Foreground="#0078D7" FontWeight="Bold" HorizontalAlignment="Right"/>
                                    <Slider Name="sldThresh" Minimum="20" Maximum="1000" Value="100"/>
                                </StackPanel>
                            </Grid>

                            <!-- Section: Automation -->
                            <TextBlock Text="ENGINE BEHAVIOR" Foreground="#0078D7" FontWeight="Bold" FontSize="12" Margin="0,20,0,12"/>
                            <CheckBox Name="chkAutoStart" Content="Start Engine on Launch" Foreground="White" Margin="0,0,0,10"/>
                            <CheckBox Name="chkMinimizeToTray" Content="Minimize to System Tray" Foreground="White" Margin="0,0,0,20"/>

                            <!-- Section: Logging -->
                            <TextBlock Text="LOG MANAGEMENT" Foreground="#555" FontWeight="Bold" FontSize="12" Margin="0,10,0,8"/>
                            <Grid>
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*"/>
                                    <ColumnDefinition Width="Auto"/>
                                </Grid.ColumnDefinitions>
                                <TextBox Name="editLogPath" Text="..." Padding="10" Background="#121218" Foreground="#888" BorderThickness="1" BorderBrush="#25252A" IsReadOnly="True"/>
                                <Button Name="btnBrowseLog" Grid.Column="1" Content="BROWSE" Width="80" Margin="5,0,0,0" Background="#25252A" Foreground="White" FontSize="10"/>
                            </Grid>
                            
                            <Button Name="btnSave" Content="Apply Configuration" Width="220" Height="50" Background="#0078D7" Foreground="White" FontWeight="Bold" Margin="0,40,0,20" HorizontalAlignment="Left">
                                <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="10"/></Style></Button.Resources>
                            </Button>
                        </StackPanel>
                    </ScrollViewer>
                </StackPanel>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$ui = @{}
"MainBorder", "navDash", "navLogs", "navInfo", "navSet", "pageDash", "pageLogs", "pageInfo", "pageSet", 
"btnAction", "editHost", "lblBigPing", "lblHostSub", "ringProgress", "polyline", "canvas", "btnClearLogs",
"txtMin", "txtAvg", "txtMax", "lstLogs", "btnExport", "txtLocalIP", "txtGateway", "txtPublicIP", "txtDNS",
"sldThresh", "lblThreshVal", "btnSave", "btnExit", "btnMin", "lblAlert", "txtUptime", "btnRefreshNet",
"txtJitter", "txtLoss", "txtQuality", "lblStatus", "txtSendRate", "txtRecvRate", "txtAdapterType", 
"txtAdapterName", "txtLinkSpeed", "editInterval", "chkAutoStart", "chkMinimizeToTray", "editLogPath", 
"btnBrowseLog" | ForEach-Object { $ui[$_] = $window.FindName($_) }

function Add-LogEntry {
    param($Status, $Latency, $Color = "#888")
    $timestamp = Get-Date -f "HH:mm:ss"
    $latText = if ($Latency -eq -1) { "LOST" } else { "$Latency ms" }
    
    $entry = [PSCustomObject]@{
        Timestamp = (Get-Date -f "yyyy-MM-dd HH:mm:ss")
        Status    = $Status
        Latency   = $latText
        Display   = "[$timestamp] $Status >> $latText"
        Color     = $Color
    }

    $window.Dispatcher.Invoke({
            $eventLog.Insert(0, $entry)
            if ($eventLog.Count -gt 500) { $eventLog.RemoveAt(500) }
        })

    $entry | Select-Object Timestamp, Status, Latency | 
    Export-Csv -Path $config.LogPath -Append -NoTypeInformation
}

function Get-NetworkSummary {
    try {
        $net = Get-NetIPConfiguration | Where-Object { $null -ne $_.IPv4Address } | Select-Object -First 1
        if ($null -ne $net) {
            $ui.txtLocalIP.Text = $net.IPv4Address.IPAddress
            $ui.txtGateway.Text = $net.IPv4DefaultGateway.NextHop
            $ui.txtDNS.Text = ($net.DNSServer.ServerAddresses | Out-String).Trim()
        }
        
        $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
        if ($null -ne $adapter) {
            $ui.txtAdapterName.Text = $adapter.InterfaceDescription
            $ui.txtLinkSpeed.Text = "$($adapter.LinkSpeed)"
            $ui.txtAdapterType.Text = if ($adapter.MediaType -like "*802.11*") { [char]0xE701 } else { [char]0xE839 }
        }

        $ui.txtPublicIP.Text = "Querying..."
        $ps = [powershell]::Create().AddScript({
                try { (Invoke-RestMethod -Uri "https://api.ipify.org" -TimeoutSec 2).Trim() } catch { "Offline" }
            })
        $async = $ps.BeginInvoke()
        
        $checkTimer = New-Object System.Windows.Threading.DispatcherTimer
        $checkTimer.Interval = [TimeSpan]::FromMilliseconds(500)
        $checkTimer.Add_Tick({
                if ($async.IsCompleted) {
                    $res = $ps.EndInvoke($async)
                    $ui.txtPublicIP.Text = $res
                    $ps.Dispose()
                    $this.Stop()
                }
            })
        $checkTimer.Start()
    }
    catch { $ui.txtLocalIP.Text = "Discovery Error" }
}

function Start-StabilityGraph {
    $arr = $pingHistory.ToArray()
    if ($arr.Count -lt 2) { return }
    
    $pts = New-Object System.Windows.Media.PointCollection
    $maxVal = ($arr | Measure-Object -Maximum).Maximum
    if ($maxVal -lt $ui.sldThresh.Value) { $maxVal = $ui.sldThresh.Value }
    
    $w = $ui.canvas.ActualWidth
    $h = $ui.canvas.ActualHeight
    $step = if ($arr.Count -gt 1) { $w / ($arr.Count - 1) } else { 0 }
    
    for ($i = 0; $i -lt $arr.Count; $i++) {
        $x = $i * $step
        $y = $h - (($arr[$i] / ($maxVal * 1.2)) * $h)
        $pts.Add((New-Object System.Windows.Point($x, $y)))
    }
    $ui.polyline.Points = $pts
}

$pingProvider = New-Object System.Net.NetworkInformation.Ping
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(1)
$prevSent = 0; $prevRecv = 0

$timer.Add_Tick({
        $sessionStats.TotalPings++
    
        try {
            $adapter = Get-NetAdapter | Where-Object { $_.Status -eq "Up" } | Select-Object -First 1
            $perf = Get-NetAdapterStatistics -Name $adapter.Name
            if ($prevSent -gt 0) {
                $ui.txtSendRate.Text = "$([Math]::Round(($perf.SentBytes - $prevSent) / 1024, 1)) Kbps"
                $ui.txtRecvRate.Text = "$([Math]::Round(($perf.ReceivedBytes - $prevRecv) / 1024, 1)) Kbps"
            }
            $script:prevSent = $perf.SentBytes; $script:prevRecv = $perf.ReceivedBytes
        }
        catch {}

        try {
            $reply = $pingProvider.Send($ui.editHost.Text, 900)
            if ($reply.Status -eq "Success") {
                $ms = [int]$reply.RoundtripTime
                $ui.lblBigPing.Text = $ms
            
                if ($sessionStats.LastLat -gt 0) {
                    $jitter = [Math]::Abs($ms - $sessionStats.LastLat)
                    $sessionStats.Jitter = $jitter
                    $ui.txtJitter.Text = "$($jitter)ms"
                }
                $sessionStats.LastLat = $ms
                if ($ms -gt $sessionStats.MaxLat) { $sessionStats.MaxLat = $ms }
                if ($ms -lt $sessionStats.MinLat) { $sessionStats.MinLat = $ms }

                if ($ms -gt $ui.sldThresh.Value) {
                    $ui.ringProgress.Stroke = [System.Windows.Media.Brushes]::Crimson
                    $ui.lblAlert.Text = "LATENCY SPIKE"
                    Add-LogEntry "SPIKE" $ms "#E81123"
                }
                else {
                    $ui.ringProgress.Stroke = New-Object System.Windows.Media.SolidColorBrush([System.Windows.Media.Color]::FromRgb(0, 120, 215))
                    $ui.lblAlert.Text = ""
                    Add-LogEntry "OK" $ms "#666"
                }

                $quality = "EXCELLENT"; $qColor = "#44E811"
                if ($ms -gt 100 -or $sessionStats.Jitter -gt 20) { $quality = "FAIR"; $qColor = "#FFB900" }
                if ($ms -gt 250 -or $sessionStats.Jitter -gt 50) { $quality = "POOR"; $qColor = "#E81123" }
                $ui.txtQuality.Text = $quality
                $ui.txtQuality.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString($qColor)
            
                $ui.lblStatus.Text = "CORE ACTIVE"
                $ui.lblStatus.Foreground = [System.Windows.Media.Brushes]::LimeGreen

                $pingHistory.Enqueue($ms)
                if ($pingHistory.Count -gt 25) { [void]$pingHistory.Dequeue() }
            
                $ui.txtMin.Text = "$($sessionStats.MinLat)ms"
                $ui.txtMax.Text = "$($sessionStats.MaxLat)ms"
                $ui.txtLoss.Text = $sessionStats.FailedPings
                $ui.txtAvg.Text = "$([Math]::Round(($pingHistory.ToArray() | Measure-Object -Average).Average))ms"
                Start-StabilityGraph
            }
            else { throw "Timeout" }
        }
        catch {
            $sessionStats.FailedPings++; Add-LogEntry "LOSS" -1 "#E81123"
            $ui.lblBigPing.Text = "!!"; $ui.ringProgress.Stroke = [System.Windows.Media.Brushes]::Red
            $ui.lblStatus.Text = "PACKET LOSS"; $ui.txtQuality.Text = "CRITICAL"
        }
    
        $uptime = 100 - ($sessionStats.FailedPings / $sessionStats.TotalPings * 100)
        $ui.txtUptime.Text = "Stability: $([Math]::Round($uptime, 2))% | Packets: $($sessionStats.TotalPings)"
    })

$ui.btnBrowseLog.Add_Click({
        $dialog = New-Object System.Windows.Forms.SaveFileDialog
        $dialog.Filter = "CSV Files (*.csv)|*.csv"
        $dialog.InitialDirectory = [System.Environment]::GetFolderPath("Desktop")
        if ($dialog.ShowDialog() -eq "OK") {
            $ui.editLogPath.Text = $dialog.FileName
        }
    })

$ui.btnAction.Add_Click({
        if ($timer.IsEnabled) { 
            $timer.Stop()
            $ui.btnAction.Content = "START MONITORING"
            $ui.btnAction.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0078D7")
            $ui.lblStatus.Text = "CORE IDLE"
            $ui.lblStatus.Foreground = [System.Windows.Media.Brushes]::Gray
        }
        else { 
            $timer.Start()
            $ui.btnAction.Content = "STOP MONITORING"
            $ui.btnAction.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1A1A1F")
            $ui.lblStatus.Text = "INITIALIZING..."
        }
    })

$ui.navDash.Add_Click({ $ui.pageDash.Visibility = "Visible"; $ui.pageLogs.Visibility = $ui.pageInfo.Visibility = $ui.pageSet.Visibility = "Collapsed" })
$ui.navLogs.Add_Click({ $ui.pageLogs.Visibility = "Visible"; $ui.pageDash.Visibility = $ui.pageInfo.Visibility = $ui.pageSet.Visibility = "Collapsed" })
$ui.navInfo.Add_Click({ Get-NetworkSummary; $ui.pageInfo.Visibility = "Visible"; $ui.pageDash.Visibility = $ui.pageLogs.Visibility = $ui.pageSet.Visibility = "Collapsed" })
$ui.navSet.Add_Click({ $ui.pageSet.Visibility = "Visible"; $ui.pageDash.Visibility = $ui.pageLogs.Visibility = $ui.pageInfo.Visibility = "Collapsed" })

$ui.btnSave.Add_Click({
        if (-not (Get-Member -InputObject $config -Name "Interval")) {
            $config | Add-Member -MemberType NoteProperty -Name "Interval" -Value 1000
        }
        if (-not (Get-Member -InputObject $config -Name "AutoStart")) {
            $config | Add-Member -MemberType NoteProperty -Name "AutoStart" -Value $false
        }

        $config.Host = $ui.editHost.Text
        $config.Threshold = $ui.sldThresh.Value
        $config.Interval = [int]$ui.editInterval.Text
        $config.AutoStart = $ui.chkAutoStart.IsChecked
        $config.LogPath = $ui.editLogPath.Text

        $timer.Interval = [TimeSpan]::FromMilliseconds($config.Interval)
    
        $config | ConvertTo-Json | Set-Content $configPath
        $ui.lblHostSub.Text = "Host: $($ui.editHost.Text)"
        [System.Windows.MessageBox]::Show("Configuration saved successfully.")
    })

if ($ui.editInterval.Text -match '^\d+$') {
    $config.Interval = [int]$ui.editInterval.Text
}
else {
    $config.Interval = 1000
}

$ui.btnRefreshNet.Add_Click({ Get-NetworkSummary })
$ui.btnExport.Add_Click({ 
        if ($eventLog.Count -eq 0) {
            [System.Windows.MessageBox]::Show("No data to export!")
            return
        }
        $eventLog | Select-Object Timestamp, Status, Latency | 
        Export-Csv -Path $config.LogPath -NoTypeInformation
        [System.Windows.MessageBox]::Show("Log exported to: $($config.LogPath)") 
    })

$ui.lstLogs.ItemsSource = $eventLog
$ui.btnClearLogs.Add_Click({ $eventLog.Clear() })
$ui.sldThresh.Add_ValueChanged({ $ui.lblThreshVal.Text = "$([Math]::Round($ui.sldThresh.Value)) ms" })
$ui.btnExit.Add_Click({ $window.Close() })
$ui.btnMin.Add_Click({ $window.WindowState = "Minimized" })
$window.Add_MouseLeftButtonDown({ $window.DragMove() })

Get-NetworkSummary
$window.ShowDialog()