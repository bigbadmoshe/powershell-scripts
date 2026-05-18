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

$appDataFolder = Join-Path $env:APPDATA "NetPulse"
if (-not (Test-Path $appDataFolder)) { New-Item -ItemType Directory -Path $appDataFolder -Force | Out-Null }
$configPath = Join-Path $appDataFolder "NetPulse.json"

$defaultLogPath = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "NetPulse_Log.csv")

$config = if (Test-Path $configPath) { 
    try { Get-Content $configPath -Raw | ConvertFrom-Json } catch { $null }
} 

if ($null -eq $config) {
    $config = [PSCustomObject]@{ 
        Host      = "8.8.8.8"
        Threshold = 100 
        LogPath   = $defaultLogPath
        Interval  = 1000
        AutoStart = $false
    }
    $config | ConvertTo-Json | Set-Content $configPath
}

if ([string]::IsNullOrWhiteSpace($config.LogPath)) { $config.LogPath = $defaultLogPath }

$pingHistory = [System.Collections.Generic.Queue[int]]::new()
$jitterHistory = [System.Collections.Generic.Queue[int]]::new()
$eventLog = New-Object System.Collections.ObjectModel.ObservableCollection[PSCustomObject]
$sessionStats = [PSCustomObject]@{ 
    TotalPings = 0; FailedPings = 0; MaxLat = 0; MinLat = 9999; LastLat = 0; StartTime = Get-Date; Jitter = 0 
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="NetPulse" Height="750" Width="1150" 
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
                        <Button Name="navTrace" Content="&#xE909;" ToolTip="Visual Traceroute" FontFamily="Segoe MDL2 Assets" Height="70" Background="Transparent" BorderThickness="0" Foreground="#555" FontSize="26"/>
                        <Button Name="navSpeed" Content="&#xE945;" ToolTip="Speed Test" FontFamily="Segoe MDL2 Assets" Height="70" Background="Transparent" BorderThickness="0" Foreground="#555" FontSize="26"/>
                        <Button Name="navInfo" Content="&#xE946;" ToolTip="Advanced Diagnostics" FontFamily="Segoe MDL2 Assets" Height="70" Background="Transparent" BorderThickness="0" Foreground="#555" FontSize="26"/>
                        <Button Name="navSet" Content="&#xE713;" ToolTip="Engine Settings" FontFamily="Segoe MDL2 Assets" Height="70" Background="Transparent" BorderThickness="0" Foreground="#555" FontSize="26"/>
                    </StackPanel>
                    <Button Name="btnExit" Content="&#xE711;" FontFamily="Segoe MDL2 Assets" Height="70" Background="Transparent" BorderThickness="0" Foreground="#E81123" Opacity="0.5" FontSize="22" VerticalAlignment="Bottom" Margin="0,0,0,30"/>
                </Grid>
            </Border>

            <!-- Main Workspace -->
            <Grid Grid.Column="1" Margin="45,35">
                <StackPanel Panel.ZIndex="99" VerticalAlignment="Top" HorizontalAlignment="Right" Orientation="Horizontal">
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
                        <TextBlock Text="Network" FontSize="38" FontWeight="Bold" Foreground="White"/>
                        <StackPanel Orientation="Horizontal" Margin="2,5,0,0">
                             <TextBlock Name="lblHostSub" Text="Host: 8.8.8.8" Foreground="#666" FontSize="14" FontWeight="SemiBold"/>
                             <TextBlock Text=" • " Foreground="#333" Margin="8,0"/>
                             <TextBlock Name="lblStatus" Text="IDLE" Foreground="#0078D7" FontSize="14" FontWeight="Bold"/>
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
                                
                                <Ellipse Name="ringProgress" Width="230" Height="230" Stroke="#2A2A2E" StrokeThickness="18" StrokeDashArray="8,2">
                                    <Ellipse.Triggers>
                                        <EventTrigger RoutedEvent="Loaded">
                                            <BeginStoryboard>
                                                <Storyboard>
                                                    <DoubleAnimation Storyboard.TargetProperty="Opacity"
                                                                    From="1.0" To="0.3" Duration="0:0:1.5" 
                                                                    AutoReverse="True" RepeatBehavior="Forever" />
                                                </Storyboard>
                                            </BeginStoryboard>
                                        </EventTrigger>
                                    </Ellipse.Triggers>
                                </Ellipse>

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
                                    <Grid Margin="0,0,0,10">
                                        <TextBlock Text="STABILITY TREND" FontSize="11" Foreground="#0078D7" FontWeight="Bold"/>
                                        <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                                            <Rectangle Width="8" Height="2" Fill="#0078D7" Margin="0,0,4,0" VerticalAlignment="Center"/>
                                            <TextBlock Text="PING" Foreground="#666" FontSize="9" Margin="0,0,10,0"/>
                                            <Rectangle Width="8" Height="2" Fill="#FFB900" Margin="0,0,4,0" VerticalAlignment="Center"/>
                                            <TextBlock Text="JITTER" Foreground="#666" FontSize="9" Margin="0,0,10,0"/>
                                            <Line X1="0" X2="8" Y1="0" Y2="0" Stroke="Red" StrokeThickness="1" StrokeDashArray="2,2" Margin="0,0,4,0" VerticalAlignment="Center"/>
                                            <TextBlock Text="LIMIT" Foreground="#666" FontSize="9"/>
                                        </StackPanel>
                                    </Grid>
                                    <Grid Name="graphContainer" Height="150">
                                        <Canvas Name="canvasLabels" HorizontalAlignment="Left" Width="30" Panel.ZIndex="5" IsHitTestVisible="False"/>
                                        
                                        <Canvas Name="canvas" Background="Transparent" ClipToBounds="True" Margin="30,0,0,0">
                                            <Canvas Name="canvasGrid" IsHitTestVisible="False" Opacity="0.1"/>
                                            <Polygon Name="polyFill" Fill="#0078D7" Opacity="0.15" />
                                            <Line Name="limitLine" Stroke="Red" StrokeThickness="1" StrokeDashArray="4,4" Opacity="0.4" Visibility="Collapsed"/>
                                            <Polyline Name="polylineJitter" Stroke="#FFB900" StrokeThickness="1" StrokeDashArray="2,2" Opacity="0.5"/>
                                            <Polyline Name="polyline" Stroke="#0078D7" StrokeThickness="2.5" StrokeLineJoin="Round">
                                                <Polyline.Effect>
                                                    <DropShadowEffect BlurRadius="10" Color="#0078D7" Opacity="0.4" ShadowDepth="0"/>
                                                </Polyline.Effect>
                                            </Polyline>
                                        </Canvas>
                                    </Grid>
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
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                        <RowDefinition Height="Auto"/>
                    </Grid.RowDefinitions>

                    <StackPanel Grid.Row="0" Margin="0,0,0,20">
                        <TextBlock Text="Event Timeline" FontSize="34" Foreground="White" FontWeight="Bold"/>
                        <TextBlock Text="Detailed telemetry and packet lifecycle analysis." Foreground="#555"/>
                    </StackPanel>

                    <Border Grid.Row="1" Background="#0C0C0F" CornerRadius="15" BorderBrush="#1F1F24" BorderThickness="1">
                        <ListView Name="lstLogs" Background="Transparent" BorderThickness="0" Foreground="#AAA" FontFamily="Consolas">
                            <ListView.View>
                                <GridView>
                                    <GridViewColumn Header="TIME" Width="100">
                                        <GridViewColumn.CellTemplate>
                                            <DataTemplate><TextBlock Text="{Binding TimestampShort}" Foreground="#555"/></DataTemplate>
                                        </GridViewColumn.CellTemplate>
                                    </GridViewColumn>
                                    <GridViewColumn Header="EVENT" Width="120">
                                        <GridViewColumn.CellTemplate>
                                            <DataTemplate><TextBlock Text="{Binding Status}" Foreground="{Binding Color}" FontWeight="Bold"/></DataTemplate>
                                        </GridViewColumn.CellTemplate>
                                    </GridViewColumn>
                                    <GridViewColumn Header="LATENCY" Width="100">
                                        <GridViewColumn.CellTemplate>
                                            <DataTemplate><TextBlock Text="{Binding Latency}" Foreground="White"/></DataTemplate>
                                        </GridViewColumn.CellTemplate>
                                    </GridViewColumn>
                                    <GridViewColumn Header="DIAGNOSTIC MESSAGE" Width="400">
                                        <GridViewColumn.CellTemplate>
                                            <DataTemplate><TextBlock Text="{Binding Message}" Foreground="#777" FontSize="11"/></DataTemplate>
                                        </GridViewColumn.CellTemplate>
                                    </GridViewColumn>
                                </GridView>
                            </ListView.View>
                        </ListView>
                    </Border>

                    <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="0,20,0,0">
                        <Button Name="btnExport" Content="Export CSV" Width="140" Height="40" Background="#0078D7" Foreground="White"/>
                        <Button Name="btnClearLogs" Content="Clear Buffer" Width="120" Height="40" Background="#1A1A1F" Foreground="#666" Margin="10,0"/>
                    </StackPanel>
                </Grid>

                <!-- PAGE 3: TRACEROUTE -->
                <Grid Name="pageTrace" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <Grid Grid.Row="0" Margin="0,0,0,25">
                        <StackPanel>
                            <TextBlock Text="Path Analysis" FontSize="34" Foreground="White" FontWeight="Bold"/>
                            <TextBlock Text="Hop-by-hop telemetry to destination" Foreground="#555" Margin="2,0,0,10"/>
                            <Border Background="#121218" CornerRadius="12" Padding="5" BorderBrush="#25252A" BorderThickness="1" HorizontalAlignment="Left">
                                <StackPanel Orientation="Horizontal">
                                    <TextBox Name="editTraceHost" Text="8.8.8.8" Width="250" VerticalAlignment="Center" Background="Transparent" Foreground="White" BorderThickness="0" Margin="10,0" FontFamily="Consolas" FontSize="16"/>
                                    <Button Name="btnStartTrace" Content="INITIATE TRACE" Width="140" Height="40" Background="#0078D7" Foreground="White" FontWeight="Bold">
                                        <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="8"/></Style></Button.Resources>
                                    </Button>
                                </StackPanel>
                            </Border>
                        </StackPanel>
                    </Grid>

                    <Border Grid.Row="1" Background="#0C0C0F" CornerRadius="20" BorderBrush="#1F1F24" BorderThickness="1">
                        <ScrollViewer VerticalScrollBarVisibility="Auto" Padding="20">
                            <ItemsControl Name="lstTrace">
                                <ItemsControl.ItemTemplate>
                                    <DataTemplate>
                                        <Grid Margin="0,0,0,12">
                                            <Grid.ColumnDefinitions>
                                                <ColumnDefinition Width="40"/> <ColumnDefinition Width="*"/>  </Grid.ColumnDefinitions>
                                            
                                            <Rectangle Grid.Column="0" Width="2" Fill="#1F1F24" HorizontalAlignment="Center" Margin="0,20,0,-15"/>
                                            <Ellipse Grid.Column="0" Width="12" Height="12" Fill="{Binding Color}" VerticalAlignment="Top" Margin="0,14,0,0">
                                                <Ellipse.Effect>
                                                    <DropShadowEffect BlurRadius="10" Color="{Binding ColorHex}" Opacity="0.6" ShadowDepth="0"/>
                                                </Ellipse.Effect>
                                            </Ellipse>

                                            <Border Grid.Column="1" Background="#121218" CornerRadius="12" Padding="15" BorderBrush="#1F1F24" BorderThickness="1">
                                                <Grid>
                                                    <Grid.ColumnDefinitions>
                                                        <ColumnDefinition Width="50"/>
                                                        <ColumnDefinition Width="*"/>
                                                        <ColumnDefinition Width="Auto"/>
                                                    </Grid.ColumnDefinitions>
                                                    
                                                    <TextBlock Text="{Binding Hop}" Foreground="#333" FontSize="24" FontWeight="Black" VerticalAlignment="Center"/>
                                                    
                                                    <StackPanel Grid.Column="1" Margin="15,0">
                                                        <TextBlock Text="{Binding IP}" Foreground="White" FontSize="15" FontWeight="Bold" FontFamily="Consolas"/>
                                                        <TextBlock Text="{Binding Hostname}" Foreground="#555" FontSize="11" TextWrapping="Wrap"/>
                                                    </StackPanel>

                                                    <StackPanel Grid.Column="2" VerticalAlignment="Center">
                                                        <TextBlock Text="{Binding Latency}" Foreground="{Binding Color}" FontSize="18" FontWeight="Bold" HorizontalAlignment="Right" FontFamily="Consolas"/>
                                                        <TextBlock Text="LATENCY" Foreground="#333" FontSize="8" FontWeight="Bold" HorizontalAlignment="Right"/>
                                                    </StackPanel>
                                                </Grid>
                                            </Border>
                                        </Grid>
                                    </DataTemplate>
                                </ItemsControl.ItemTemplate>
                            </ItemsControl>
                        </ScrollViewer>
                    </Border>
                </Grid>

                <!-- PAGE 4: SPEED TEST -->
                <Grid Name="pageSpeed" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <StackPanel Grid.Row="0" Margin="0,0,0,25">
                        <TextBlock Text="Performance" FontSize="34" Foreground="White" FontWeight="Bold"/>
                        <TextBlock Text="Network bandwidth and throughput verification" Foreground="#555"/>
                    </StackPanel>

                    <Grid Grid.Row="1">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*"/>
                            <ColumnDefinition Width="*"/>
                        </Grid.ColumnDefinitions>

                        <StackPanel Grid.Column="0" Margin="0,0,20,0">
                            <Border Background="#121218" CornerRadius="20" Padding="30" BorderBrush="#1F1F24" BorderThickness="1">
                                <StackPanel>
                                    <TextBlock Text="DOWNLOAD" Foreground="#0078D7" FontWeight="Bold" FontSize="12" HorizontalAlignment="Center"/>
                                    <TextBlock Name="txtDownSpeed" Text="0.0" FontSize="64" FontWeight="Black" Foreground="White" HorizontalAlignment="Center"/>
                                    <TextBlock Text="Mbps" Foreground="#444" FontSize="14" HorizontalAlignment="Center" Margin="0,-10,0,20"/>
                                    <ProgressBar Name="pbDown" Height="8" Background="#1A1A1F" Foreground="#0078D7" BorderThickness="0"/>
                                </StackPanel>
                            </Border>

                            <Border Background="#121218" CornerRadius="20" Padding="30" BorderBrush="#1F1F24" BorderThickness="1" Margin="0,20,0,0">
                                <StackPanel>
                                    <TextBlock Text="UPLOAD" Foreground="#44E811" FontWeight="Bold" FontSize="12" HorizontalAlignment="Center"/>
                                    <TextBlock Name="txtUpSpeed" Text="0.0" FontSize="64" FontWeight="Black" Foreground="White" HorizontalAlignment="Center"/>
                                    <TextBlock Text="Mbps" Foreground="#444" FontSize="14" HorizontalAlignment="Center" Margin="0,-10,0,20"/>
                                    <ProgressBar Name="pbUp" Height="8" Background="#1A1A1F" Foreground="#44E811" BorderThickness="0"/>
                                </StackPanel>
                            </Border>
                        </StackPanel>

                        <StackPanel Grid.Column="1">
                            <Button Name="btnRunSpeed" Content="RUN TEST" Height="80" Background="#0078D7" Foreground="White" FontSize="20" FontWeight="Bold">
                                <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="15"/></Style></Button.Resources>
                            </Button>
                            
                            <Border Background="#0C0C0F" Margin="0,20,0,0" CornerRadius="15" Padding="20" BorderBrush="#1F1F24" BorderThickness="1">
                                <StackPanel>
                                    <TextBlock Text="TEST PARAMETERS" Foreground="#555" FontWeight="Bold" FontSize="11" Margin="0,0,0,15"/>
                                    <Grid Margin="0,5">
                                        <TextBlock Text="Server" Foreground="#888"/>
                                        <TextBlock Text="Ookla®" Foreground="White" HorizontalAlignment="Right"/>
                                    </Grid>
                                    <Grid Margin="0,5">
                                        <TextBlock Text="Provider" Foreground="#888"/>
                                        <TextBlock Text="Ookla Speedtest CLI" Foreground="White" HorizontalAlignment="Right"/>
                                    </Grid>
                                    <Separator Background="#1F1F24" Margin="0,15"/>
                                    <TextBlock Name="txtSpeedStatus" Text="Ready to analyze..." Foreground="#0078D7" HorizontalAlignment="Center" FontWeight="SemiBold"/>
                                </StackPanel>
                            </Border>
                        </StackPanel>
                    </Grid>
                </Grid>

                <!-- PAGE 5: ADVANCED DIAGNOSTICS (EXPANDED) -->
                <Grid Name="pageInfo" Visibility="Collapsed">
                    <Grid.RowDefinitions>
                        <RowDefinition Height="Auto"/>
                        <RowDefinition Height="*"/>
                    </Grid.RowDefinitions>

                    <!-- Header Area -->
                    <StackPanel Grid.Row="0" Margin="0,0,0,25">
                        <TextBlock Text="Diagnostics" FontSize="34" Foreground="White" FontWeight="Bold"/>
                        <TextBlock Text="Hardware telemetry and real-time socket analysis." Foreground="#555" FontSize="14"/>
                    </StackPanel>

                    <Grid Grid.Row="1">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="1.2*"/> <!-- Hardware -->
                            <ColumnDefinition Width="1.5*"/> <!-- Traffic -->
                            <ColumnDefinition Width="180"/>  <!-- Sidebar -->
                        </Grid.ColumnDefinitions>

                        <!-- COLUMN 1: HARDWARE & IP -->
                        <ScrollViewer Grid.Column="0" VerticalScrollBarVisibility="Auto" Margin="0,0,15,0">
                            <StackPanel>
                                <TextBlock Text="INTERFACE TELEMETRY" Foreground="#0078D7" FontWeight="Bold" FontSize="11" Margin="5,0,0,10"/>
                                
                                <Border Background="#121218" Padding="15" CornerRadius="15" BorderBrush="#1F1F24" BorderThickness="1" Margin="0,0,0,10">
                                    <StackPanel>
                                        <TextBlock Name="txtAdapterName" Text="Network Controller" Foreground="White" FontWeight="Bold" FontSize="14" TextWrapping="Wrap"/>
                                        <TextBlock Name="txtMAC" Text="MAC: --:--:--:--:--:--" Foreground="#555" FontSize="11" Margin="0,5,0,0"/>
                                        <Separator Background="#1F1F24" Margin="0,10"/>
                                        <UniformGrid Columns="2">
                                            <StackPanel><TextBlock Text="STATUS" Foreground="#444" FontSize="9"/><TextBlock Name="txtNetStatus" Text="UP" Foreground="#44E811" FontWeight="Bold"/></StackPanel>
                                            <StackPanel><TextBlock Text="SPEED" Foreground="#444" FontSize="9"/><TextBlock Name="txtLinkSpeed" Text="--- Mbps" Foreground="White"/></StackPanel>
                                        </UniformGrid>
                                    </StackPanel>
                                </Border>

                                <StackPanel>
                                    <Border Background="#121218" Margin="0,5" Padding="15" CornerRadius="12">
                                        <StackPanel><TextBlock Text="IPV4 ADDRESS" Foreground="#0078D7" FontSize="10"/><TextBlock Name="txtLocalIP" Text="---" Foreground="White" FontSize="16" FontFamily="Consolas"/></StackPanel>
                                    </Border>
                                    <Border Background="#121218" Margin="0,5" Padding="15" CornerRadius="12">
                                        <StackPanel><TextBlock Text="GATEWAY" Foreground="#0078D7" FontSize="10"/><TextBlock Name="txtGateway" Text="---" Foreground="White" FontSize="16" FontFamily="Consolas"/></StackPanel>
                                    </Border>
                                    <Border Background="#121218" Margin="0,5" Padding="15" CornerRadius="12">
                                        <StackPanel><TextBlock Text="DHCP SERVER" Foreground="#0078D7" FontSize="10"/><TextBlock Name="txtDHCPServer" Text="---" Foreground="White" FontSize="16" FontFamily="Consolas"/></StackPanel>
                                    </Border>
                                </StackPanel>
                            </StackPanel>
                        </ScrollViewer>

                        <!-- COLUMN 2: TRAFFIC & ISP -->
                        <Grid Grid.Column="1" Margin="0,0,15,0">
                            <Grid.RowDefinitions>
                                <RowDefinition Height="Auto"/>
                                <RowDefinition Height="*"/>
                            </Grid.RowDefinitions>

                            <Border Grid.Row="0" Background="#1A1A24" Padding="20" CornerRadius="15" BorderBrush="#2A2A35" BorderThickness="1" Margin="0,0,0,15">
                                <Grid>
                                    <StackPanel>
                                        <TextBlock Text="WAN IP" Foreground="#FFB900" FontWeight="Bold" FontSize="11" Margin="0,0,0,8"/>
                                        <TextBlock Name="txtPublicIP" Text="0.0.0.0" Foreground="White" FontSize="22" FontWeight="Bold" FontFamily="Consolas"/>
                                        <TextBlock Name="txtISPName" Text="ISP: Detecting..." Foreground="#888" FontSize="13"/>
                                        <TextBlock Name="txtISPCity" Text="Location: ---" Foreground="#666" FontSize="11"/>
                                    </StackPanel>
                                    <TextBlock Text="&#xEC05;" FontFamily="Segoe MDL2 Assets" Foreground="#FFB900" FontSize="32" HorizontalAlignment="Right" VerticalAlignment="Center" Opacity="0.3"/>
                                </Grid>
                            </Border>

                            <StackPanel Grid.Row="1">
                                <TextBlock Text="LIVE SOCKET MONITOR" Foreground="#555" FontWeight="Bold" FontSize="11" Margin="5,0,0,10"/>
                                <Border Background="#0A0A0C" CornerRadius="12" Padding="5" BorderBrush="#1F1F24" BorderThickness="1">
                                    <ListBox Name="lstActiveConns" Height="280" Background="Transparent" BorderThickness="0">
                                        <ListBox.ItemTemplate>
                                            <DataTemplate>
                                                <Border BorderBrush="#16161D" BorderThickness="0,0,0,1" Padding="8,4">
                                                    <Grid>
                                                        <Grid.ColumnDefinitions><ColumnDefinition Width="120"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                                        <TextBlock Text="{Binding ProcessName}" Foreground="#0078D7" FontWeight="Bold" FontSize="12"/>
                                                        <TextBlock Grid.Column="1" Text="{Binding RemoteAddr}" Foreground="#666" FontSize="11" HorizontalAlignment="Right" FontFamily="Consolas"/>
                                                    </Grid>
                                                </Border>
                                            </DataTemplate>
                                        </ListBox.ItemTemplate>
                                    </ListBox>
                                </Border>
                            </StackPanel>
                        </Grid>

                        <!-- COLUMN 3: SIDEBAR TOOLS -->
                        <StackPanel Grid.Column="2">
                            <TextBlock Text="QUICK REPAIR" Foreground="#555" FontWeight="Bold" FontSize="11" Margin="5,0,0,10"/>
                            <Button Name="btnFlushDNS" Content="Flush DNS" Height="40" Background="#1A1A1F" Foreground="White" Margin="0,0,0,8"/>
                            <Button Name="btnResetStack" Content="Reset IP Stack" Height="40" Background="#1A1A1F" Foreground="White" Margin="0,0,0,8"/>
                            <Button Name="btnRefreshNet" Content="Full Re-Scan" Height="50" Background="#0078D7" Foreground="White" FontWeight="Bold" Margin="0,10,0,20">
                                <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="10"/></Style></Button.Resources>
                            </Button>

                            <Border Background="#121218" CornerRadius="12" Padding="15" BorderBrush="#1F1F24" BorderThickness="1">
                                <StackPanel>
                                    <TextBlock Text="DNS SERVERS" Foreground="#555" FontSize="10" FontWeight="Bold" Margin="0,0,0,5"/>
                                    <TextBlock Name="txtDNS" Text="---" Foreground="#AAA" FontSize="11" TextWrapping="Wrap" FontFamily="Consolas"/>
                                </StackPanel>
                            </Border>
                        </StackPanel>
                    </Grid>
                </Grid>

                <!-- PAGE 6: SETTINGS -->
                <StackPanel Name="pageSet" Visibility="Collapsed">
                    <TextBlock Text="Settings" FontSize="34" Foreground="White" FontWeight="Bold" Margin="0,0,0,25"/>
                    
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

[xml]$splashXaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Loading" Height="200" Width="400" 
        WindowStyle="None" AllowsTransparency="True" Background="Transparent"
        WindowStartupLocation="CenterScreen" Topmost="True">
    <Border CornerRadius="20" Background="#121218" BorderBrush="#0078D7" BorderThickness="2">
        <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
            <TextBlock Text="NetPulse" FontSize="28" FontWeight="Bold" Foreground="White" HorizontalAlignment="Center"/>
            <TextBlock Text="Initializing..." FontSize="14" Foreground="#555" HorizontalAlignment="Center" Margin="0,10,0,10"/>
        </StackPanel>
    </Border>
</Window>
"@

$splashReader = New-Object System.Xml.XmlNodeReader $splashXaml
$splashScreen = [Windows.Markup.XamlReader]::Load($splashReader)

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$ui = @{}
"navDash", "navLogs", "navInfo", "navSet", "pageDash", "pageLogs", "pageInfo", "pageSet", 
"btnAction", "editHost", "lblBigPing", "lblHostSub", "ringProgress", "polyline", "canvas", "btnClearLogs",
"txtMin", "txtAvg", "txtMax", "lstLogs", "btnExport", "txtLocalIP", "txtGateway", "txtPublicIP", "txtDNS",
"sldThresh", "lblThreshVal", "btnSave", "btnExit", "btnMin", "lblAlert", "txtUptime", "btnRefreshNet",
"txtJitter", "txtLoss", "txtQuality", "lblStatus", "txtSendRate", "txtRecvRate", 
"txtAdapterName", "txtLinkSpeed", "editInterval", "chkAutoStart", "chkMinimizeToTray", "editLogPath", 
"btnBrowseLog", "txtMAC", "txtNetStatus", "txtDHCPServer", "txtISPName", "txtISPCity", "lstActiveConns", 
"btnFlushDNS", "btnResetStack", "polylineJitter", "limitLine", "polyFill", "canvasGrid", "canvasLabels",
"navTrace", "pageTrace", "editTraceHost", "btnStartTrace", "lstTrace",
"navSpeed", "pageSpeed", "txtDownSpeed", "txtUpSpeed", "pbDown", "pbUp", "btnRunSpeed", "txtSpeedStatus" | ForEach-Object { $ui[$_] = $window.FindName($_) }

function Add-LogEntry {
    param(
        [string]$Status, 
        [int]$Latency, 
        [string]$Color = "#888",
        [string]$Message = "Telemetry heartbeat OK"
    )
    $path = $ui.editLogPath.Text
    if ([string]::IsNullOrWhiteSpace($path)) {
        $path = "$env:USERPROFILE\Desktop\NetPulse_Log.csv"
    }
    $dir = Split-Path $path -Parent
    if (-not (Test-Path $dir)) {
        try { 
            New-Item -ItemType Directory -Path $dir -Force | Out-Null 
        }
        catch {
            Write-Host "Failed to create directory: $dir" -ForegroundColor Red
            return
        }
    }
    $timestamp = Get-Date -f "HH:mm:ss"
    $latText = if ($Latency -eq -1) { "LOST" } else { "$Latency ms" }
    $diagMsg = $Message
    if ($Status -eq "SPIKE") { $diagMsg = "Latency exceeded threshold ($($ui.sldThresh.Value)ms)" }
    if ($Status -eq "LOSS") { $diagMsg = "Request timed out or destination unreachable" }
    $entry = [PSCustomObject]@{
        TimestampFull  = (Get-Date -f "yyyy-MM-dd HH:mm:ss")
        TimestampShort = $timestamp
        Status         = $Status.ToUpper()
        Latency        = $latText
        Message        = $diagMsg
        Color          = $Color
    }
    $window.Dispatcher.Invoke({
            $eventLog.Insert(0, $entry)
            if ($eventLog.Count -gt 500) { $eventLog.RemoveAt(500) }
        })
    try {
        $exportRow = [PSCustomObject]@{
            Date_Time          = $entry.TimestampFull
            Event_Status       = $entry.Status
            Latency_MS         = $entry.Latency
            Diagnostic_Details = $entry.Message
        }
        $exportRow | Export-Csv -Path $config.LogPath -Append -NoTypeInformation -Encoding UTF8
    }
    catch {
        $ui.lblAlert.Text = "LOG WRITE ERROR"
    }
}

function Get-NetworkSummary {
    try {
        $net = Get-NetIPConfiguration | Where-Object { 
            $null -ne $_.IPv4Address -and 
            $_.InterfaceDescription -notmatch "Hyper-V|Virtual|Pseudo|Loopback" -and
            $null -ne $_.IPv4DefaultGateway
        } | Select-Object -First 1
        if ($null -eq $net) {
            $net = Get-NetIPConfiguration | Where-Object { $null -ne $_.IPv4DefaultGateway } | Select-Object -First 1
        }
        $adapter = $net.NetAdapter
        $wmi = Get-CimInstance Win32_NetworkAdapterConfiguration | Where-Object { $_.InterfaceIndex -eq $net.InterfaceIndex }
        $ui.txtLocalIP.Text = $net.IPv4Address.IPAddress
        $ui.txtGateway.Text = $net.IPv4DefaultGateway.NextHop
        $ui.txtDNS.Text = ($net.DNSServer.ServerAddresses -join "`n")
        $ui.txtMAC.Text = "MAC: $($adapter.LinkLayerAddress)"
        $ui.txtAdapterName.Text = $adapter.InterfaceDescription
        $ui.txtNetStatus.Text = $adapter.Status.ToString().ToUpper()
        $ui.txtLinkSpeed.Text = $adapter.LinkSpeed
        $ui.txtDHCPServer.Text = if ($wmi.DHCPEnabled) { $wmi.DHCPServer } else { "Static IP" }
        $ui.txtPublicIP.Text = "Resolving..."
        $ui.txtISPName.Text = "ISP: Querying..."
        $ispTask = {
            try {
                $data = Invoke-RestMethod -Uri "http://ip-api.com/json/?fields=status,message,country,regionName,city,isp,query" -TimeoutSec 2
                return $data
            }
            catch {
                return "ERROR"
            }
        }
        $result = Start-Job -ScriptBlock $ispTask | Wait-Job -Timeout 3 | Receive-Job
        if ($null -ne $result -and $result -ne "ERROR") {
            $ui.txtPublicIP.Text = $result.query
            $ui.txtISPName.Text = "ISP: $($result.isp)"
            $ui.txtISPCity.Text = "Location: $($result.city), $($result.regionName)"
        }
        else {
            $ui.txtPublicIP.Text = "Offline/Timed Out"
            $ui.txtISPName.Text = "ISP: Connection Failed"
        }
        $t = New-Object System.Windows.Threading.DispatcherTimer
        $t.Interval = [TimeSpan]::FromSeconds(1)
        $t.Add_Tick({
                if ($async.IsCompleted) {
                    $res = $ps.EndInvoke($async)
                    if ($res) {
                        $ui.txtPublicIP.Text = $res.query
                        $ui.txtISPName.Text = "ISP: $($res.isp)"
                        $ui.txtISPCity.Text = "Location: $($res.city), $($res.regionName)"
                    }
                    $this.Stop(); $ps.Dispose()
                }
            })
        $t.Start()
    }
    catch { $ui.txtLocalIP.Text = "Scan Error" }
}

function Start-StabilityGraph {
    $latArr = $pingHistory.ToArray()
    $jitArr = $jitterHistory.ToArray()
    if ($latArr.Count -lt 2) { return }
    $w = $ui.canvas.ActualWidth
    $h = $ui.canvas.ActualHeight
    $thresh = $ui.sldThresh.Value
    $maxObserved = ($latArr + $jitArr | Measure-Object -Maximum).Maximum
    $maxVal = [Math]::Max($maxObserved, $thresh) * 1.2
    if ($maxVal -lt 50) { $maxVal = 50 }
    $scaleY = $h / $maxVal
    $step = $w / ($latArr.Count - 1)
    $latPoints = New-Object System.Windows.Media.PointCollection
    $fillPoints = New-Object System.Windows.Media.PointCollection
    $jitPoints = New-Object System.Windows.Media.PointCollection
    $fillPoints.Add((New-Object System.Windows.Point(0, $h)))
    for ($i = 0; $i -lt $latArr.Count; $i++) {
        $x = $i * $step
        $val = if ($latArr[$i] -eq -1) { $maxVal } else { $latArr[$i] }
        $yLat = $h - ($val * $scaleY)
        $p = New-Object System.Windows.Point($x, $yLat)
        $latPoints.Add($p)
        $fillPoints.Add($p)
        $yJit = $h - ($jitArr[$i] * $scaleY)
        $jitPoints.Add((New-Object System.Windows.Point($x, $yJit)))
    }
    $fillPoints.Add((New-Object System.Windows.Point($w, $h)))
    $window.Dispatcher.Invoke({
            $ui.polyline.Points = $latPoints
            $ui.polyFill.Points = $fillPoints
            $ui.polylineJitter.Points = $jitPoints
            $ui.limitLine.Visibility = "Visible"
            $ui.limitLine.X1 = 0; $ui.limitLine.X2 = $w
            $yLimit = $h - ($thresh * $scaleY)
            $ui.limitLine.Y1 = $ui.limitLine.Y2 = $yLimit
            $ui.canvasGrid.Children.Clear()
            $ui.canvasLabels.Children.Clear()
            $interval = if ($maxVal -gt 500) { 200 } elseif ($maxVal -gt 200) { 100 } elseif ($maxVal -gt 100) { 50 } else { 25 }
            for ($g = 0; $g -lt $maxVal; $g += $interval) {
                if ($g -eq 0) { continue }
                $yGrid = $h - ($g * $scaleY)
                $line = New-Object System.Windows.Shapes.Line
                $line.X1 = 0; $line.X2 = $w; $line.Y1 = $line.Y2 = $yGrid
                $line.Stroke = [System.Windows.Media.Brushes]::White
                $line.StrokeThickness = 0.5
                [void]$ui.canvasGrid.Children.Add($line)
                $lbl = New-Object System.Windows.Controls.TextBlock
                $lbl.Text = "$($g)ms"
                $lbl.FontSize = 9
                $lbl.Foreground = [System.Windows.Media.Brushes]::Gray
                [System.Windows.Controls.Canvas]::SetTop($lbl, $yGrid - 6)
                [void]$ui.canvasLabels.Children.Add($lbl)
            }
        })
}

function Get-ActiveConnections {
    try {
        $conns = Get-NetTCPConnection -State Established -ErrorAction SilentlyContinue | 
        Select-Object -First 15 | 
        ForEach-Object {
            $proc = Get-Process -Id $_.OwningProcess -ErrorAction SilentlyContinue
            [PSCustomObject]@{
                ProcessName = if ($proc) { $proc.Name.ToUpper() } else { "SYSTEM/PID:$($_.OwningProcess)" }
                RemoteAddr  = "$($_.RemoteAddress):$($_.RemotePort)"
            }
        }
        $window.Dispatcher.Invoke({
                $ui.lstActiveConns.ItemsSource = $null
                $ui.lstActiveConns.ItemsSource = $conns
            })
    }
    catch {
        Write-Host "Socket Monitor Error: $_"
    }
}

function Show-Page ($pageToShow, $navButton) {
    $allPages = $ui.pageDash, $ui.pageLogs, $ui.pageInfo, $ui.pageSet, $ui.pageTrace, $ui.pageSpeed
    foreach ($page in $allPages) { 
        if ($null -ne $page) { $page.Visibility = "Collapsed" } 
    }
    $allNavs = $ui.navDash, $ui.navLogs, $ui.navInfo, $ui.navSet, $ui.navTrace, $ui.navSpeed
    foreach ($nav in $allNavs) { 
        if ($null -ne $nav) { $nav.Foreground = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#555") } 
    }
    $pageToShow.Visibility = "Visible"
    $navButton.Foreground = [System.Windows.Media.Brushes]::White
}

$pingProvider = New-Object System.Net.NetworkInformation.Ping
$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(1)
$prevSent = 0; $prevRecv = 0

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$signature = @"
[DllImport("shell32.dll", CharSet = CharSet.Auto)]
public static extern IntPtr ExtractIcon(IntPtr hInst, string lpszExeFileName, int nIconIndex);
"@
Add-Type -MemberDefinition $signature -Name "IconExtractor" -Namespace "Win32" -PassThru | Out-Null
$iconHandle = [Win32.IconExtractor]::ExtractIcon(0, "shell32.dll", 14)
if ($iconHandle -ne [IntPtr]::Zero) {
    $notifyIcon.Icon = [System.Drawing.Icon]::FromHandle($iconHandle)
}
else {
    $notifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -Id $PID).Path)
}
$notifyIcon.Text = "NetPulse"
$notifyIcon.Visible = $false
$contextMenu = New-Object System.Windows.Forms.ContextMenuStrip
$restoreItem = New-Object System.Windows.Forms.ToolStripMenuItem
$restoreItem.Text = "Restore"
$restoreItem.Add_Click({
        $window.Dispatcher.Invoke([Action] {
                $window.Show()
                $window.WindowState = "Normal"
                $window.Activate()
                $notifyIcon.Visible = $false
            })
    })

$contextMenu.Items.Add($restoreItem)
$exitItem = New-Object System.Windows.Forms.ToolStripMenuItem
$exitItem.Text = "Exit"

$exitItem.Add_Click({
        $window.Dispatcher.Invoke([Action] {
                $timer.Stop()
                $notifyIcon.Visible = $false
                if ($iconHandle) { [IconHelper]::DestroyIcon($iconHandle) }
                $notifyIcon.Dispose()
                $window.Close()
            })
    })

$contextMenu.Items.Add($exitItem)
$notifyIcon.ContextMenuStrip = $contextMenu

$notifyIcon.Add_DoubleClick({
        $window.Dispatcher.Invoke([Action] {
                if (-not $window.IsVisible) {
                    $window.Show()
                }
                $window.WindowState = "Normal"
                $window.Activate()
                $notifyIcon.Visible = $false
            })
    })

$ui.btnMin.Add_Click({
        if ($ui.chkMinimizeToTray.IsChecked -eq $true) {
            $window.Hide()
            $notifyIcon.Visible = $true
            $notifyIcon.ShowBalloonTip(2000, "NetPulse", "Application minimized to tray. Double-click to restore.", [System.Windows.Forms.ToolTipIcon]::Info)
        }
        else {
            $window.WindowState = "Minimized"
        }
    })

$window.Add_Closing({
        param($closingSender, $e)
        if ($ui.chkMinimizeToTray.IsChecked -eq $true -and $notifyIcon.Visible) {
            $e.Cancel = $true
            $window.Hide()
        }
    })

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
                $currentJitter = if ($sessionStats.LastLat -gt 0) { [Math]::Abs($ms - $sessionStats.LastLat) } else { 0 }
                $pingHistory.Enqueue($ms)
                $jitterHistory.Enqueue($currentJitter)
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
                $ui.lblStatus.Text = "ACTIVE"
                $ui.lblStatus.Foreground = [System.Windows.Media.Brushes]::LimeGreen
                $pingHistory.Enqueue($ms)
                if ($pingHistory.Count -gt 25) { [void]$pingHistory.Dequeue() }
                $ui.txtMin.Text = "$($sessionStats.MinLat)ms"
                $ui.txtMax.Text = "$($sessionStats.MaxLat)ms"
                $ui.txtLoss.Text = $sessionStats.FailedPings
                $ui.txtAvg.Text = "$([Math]::Round(($pingHistory.ToArray() | Measure-Object -Average).Average))ms"
                if ($pingHistory.Count -gt 30) { [void]$pingHistory.Dequeue(); [void]$jitterHistory.Dequeue() }
                Start-StabilityGraph
            }
            else { throw "Timeout" }
        }
        catch {
            $sessionStats.FailedPings++; Add-LogEntry "LOSS" -1 "#E81123"
            $ui.lblBigPing.Text = "!!"; $ui.ringProgress.Stroke = [System.Windows.Media.Brushes]::Red
            $ui.lblStatus.Text = "PACKET LOSS"; $ui.txtQuality.Text = "CRITICAL"
            $pingHistory.Enqueue(-1) 
            $jitterHistory.Enqueue(0)
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
            $ui.lblStatus.Text = "IDLE"
            $ui.lblStatus.Foreground = [System.Windows.Media.Brushes]::Gray
        }
        else { 
            $timer.Start()
            $ui.btnAction.Content = "STOP MONITORING"
            $ui.btnAction.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1A1A1F")
            $ui.lblStatus.Text = "INITIALIZING..."
        }
    })

$ui.navDash.Add_Click({ Show-Page $ui.pageDash $ui.navDash })
$ui.navLogs.Add_Click({ Show-Page $ui.pageLogs $ui.navLogs })
$ui.navInfo.Add_Click({ 
        Get-NetworkSummary
        Get-ActiveConnections
        Show-Page $ui.pageInfo $ui.navInfo 
    })
$ui.navSet.Add_Click({ Show-Page $ui.pageSet $ui.navSet })
$ui.navTrace.Add_Click({ Show-Page $ui.pageTrace $ui.navTrace })
$ui.navSpeed.Add_Click({ Show-Page $ui.pageSpeed $ui.navSpeed })

$ui.btnSave.Add_Click({
        $currentPath = $ui.editLogPath.Text
        if (Test-Path $currentPath -PathType Container) {
            $currentPath = Join-Path $currentPath "NetPulse_Log.csv"
            $ui.editLogPath.Text = $currentPath
        }
        $config.Host = $ui.editHost.Text
        $config.Threshold = $ui.sldThresh.Value
        $config.Interval = [int]$ui.editInterval.Text
        $config.AutoStart = $ui.chkAutoStart.IsChecked
        $config.LogPath = $currentPath
        $timer.Interval = [TimeSpan]::FromMilliseconds($config.Interval)
        $config | ConvertTo-Json | Set-Content $configPath
        $ui.lblHostSub.Text = "Host: $($ui.editHost.Text)"
        [System.Windows.MessageBox]::Show("Configuration saved to: $currentPath")
    })

if ($ui.editInterval.Text -match '^\d+$') {
    $config.Interval = [int]$ui.editInterval.Text
}
else {
    $config.Interval = 1000
}

$ui.btnRefreshNet.Add_Click({ 
        Get-NetworkSummary
        Get-ActiveConnections 
    })

$ui.btnExport.Add_Click({ 
        if ($eventLog.Count -eq 0) {
            [System.Windows.MessageBox]::Show("No data to export!")
            return
        }
        try {
            $eventLog | Select-Object `
            @{Name = "Date_Time"; Expression = { $_.TimestampFull } }, 
            @{Name = "Event_Status"; Expression = { $_.Status } }, 
            @{Name = "Latency_MS"; Expression = { $_.Latency } }, 
            @{Name = "Diagnostic_Details"; Expression = { $_.Message } } | 
            Export-Csv -Path $config.LogPath -NoTypeInformation -Encoding UTF8
            [System.Windows.MessageBox]::Show("Telemetry log exported successfully to:`n$($config.LogPath)", "Export Complete") 
        }
        catch {
            [System.Windows.MessageBox]::Show("Export failed! Is the file open in Excel?`n`nError: $($_.Exception.Message)", "File Error", "OK", "Error")
        }
    })

$ui.lstLogs.ItemsSource = $eventLog
$ui.btnClearLogs.Add_Click({ $eventLog.Clear() })
$ui.sldThresh.Add_ValueChanged({ 
        $ui.lblThreshVal.Text = "$([Math]::Round($ui.sldThresh.Value)) ms"
    })
    
$ui.btnExit.Add_Click({
        $timer.Stop()
        $notifyIcon.Visible = $false
        if ($iconHandle) { [IconHelper]::DestroyIcon($iconHandle) }
        $notifyIcon.Dispose()
        $window.Close()
        Stop-Process -Id $PID 
    })

$ui.btnStartTrace.Add_Click({
        $target = $ui.editTraceHost.Text
        $ui.btnStartTrace.IsEnabled = $false
        $ui.btnStartTrace.Content = "TRACING..."
        $traceCollection = New-Object System.Collections.ObjectModel.ObservableCollection[PSCustomObject]
        $ui.lstTrace.ItemsSource = $traceCollection
        $sBlock = {
            param($target, $traceCollection, $window)
            try {
                for ($hop = 1; $hop -le 30; $hop++) {
                    $ping = New-Object System.Net.NetworkInformation.Ping
                    $options = New-Object System.Net.NetworkInformation.PingOptions($hop, $true)
                    $sw = [System.Diagnostics.Stopwatch]::StartNew()
                    try {
                        $reply = $ping.Send($target, 1200, [byte[]](1..32), $options)
                        $sw.Stop()
                        $lat = $sw.ElapsedMilliseconds
                        $ip = if ($reply.Status -ne "TimedOut" -and $null -ne $reply.Address) { $reply.Address.ToString() } else { "???" }
                        $colorHex = "#0078D7"
                        if ($lat -gt 100) { $colorHex = "#FFB900" }
                        if ($lat -gt 250 -or $reply.Status -eq "TimedOut") { $colorHex = "#E81123" }
                        $hostName = "Resolving..."
                        if ($ip -ne "???") {
                            try { $hostName = [System.Net.Dns]::GetHostEntry($ip).HostName } catch { $hostName = "No PTR Record" }
                        }
                        $window.Dispatcher.Invoke({
                                $brush = [System.Windows.Media.BrushConverter]::new().ConvertFromString($colorHex)
                                $entry = [PSCustomObject]@{
                                    Hop      = $hop.ToString("00")
                                    IP       = $ip
                                    Latency  = if ($ip -eq "???") { "LOST" } else { "$($lat)ms" }
                                    Hostname = $hostName.ToUpper()
                                    ColorHex = $colorHex
                                    Color    = $brush
                                }
                                $traceCollection.Add($entry)
                            })
                        if ($reply.Status -eq "Success") { break }
                    }
                    catch { break }
                }
            }
            finally {
                $window.Dispatcher.Invoke({
                        $btn = $window.FindName("btnStartTrace")
                        $btn.IsEnabled = $true
                        $btn.Content = "INITIATE TRACE"
                    })
            }
        }
        $psInstance = [PowerShell]::Create().AddScript($sBlock).AddArgument($target).AddArgument($traceCollection).AddArgument($window)
        [void]$psInstance.BeginInvoke()
    })

$ui.btnRunSpeed.Add_Click({
        $ui.btnRunSpeed.IsEnabled = $false
        $ui.btnRunSpeed.Content = "PREPARING..."
        $ui.txtSpeedStatus.Text = "Checking engine..."
        $speedBlock = {
            param($window, $ui, $appDataFolder)
            $cliPath = Join-Path $appDataFolder "speedtest.exe"
            $zipPath = Join-Path $appDataFolder "ookla.zip"
            try {
                if (-not (Test-Path $cliPath)) {
                    $window.Dispatcher.Invoke({ $ui.txtSpeedStatus.Text = "Downloading engine..." })
                    $downloadUrl = "https://install.speedtest.net/app/cli/ookla-speedtest-1.2.0-win64.zip"
                    Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -UseBasicParsing
                    $window.Dispatcher.Invoke({ $ui.txtSpeedStatus.Text = "Extracting..." })
                    Expand-Archive -Path $zipPath -DestinationPath $appDataFolder -Force
                    Remove-Item $zipPath -Force
                }
                $window.Dispatcher.Invoke({ 
                        $ui.txtSpeedStatus.Text = "Finding server..." 
                        $ui.pbDown.Value = 20
                    })
                $ooklaRaw = & $cliPath --format=json --accept-license --accept-gdpr
                $res = $ooklaRaw | ConvertFrom-Json
                $downMbps = [Math]::Round(($res.download.bandwidth * 8) / 1000000, 1)
                $upMbps = [Math]::Round(($res.upload.bandwidth * 8) / 1000000, 1)
                $window.Dispatcher.Invoke({
                        $ui.txtDownSpeed.Text = $downMbps
                        $ui.txtUpSpeed.Text = $upMbps
                        $ui.pbDown.Value = 100
                        $ui.pbUp.Value = 100
                        $ui.txtSpeedStatus.Text = "Finished: $($res.isp)"
                    })
            }
            catch {
                $window.Dispatcher.Invoke({ 
                        $ui.txtSpeedStatus.Text = "Error: Speedtest failed" 
                        $ui.btnRunSpeed.IsEnabled = $true
                    })
            }
            finally {
                $window.Dispatcher.Invoke({
                        $ui.btnRunSpeed.IsEnabled = $true
                        $ui.btnRunSpeed.Content = "RUN TEST"
                    })
            }
        }
        $ps = [PowerShell]::Create().AddScript($speedBlock).AddArgument($window).AddArgument($ui).AddArgument($appDataFolder)
        [void]$ps.BeginInvoke()
    })

$window.Add_MouseLeftButtonDown({ $window.DragMove() })

$ui.btnFlushDNS.Add_Click({ 
        Clear-DnsClientCache
        [System.Windows.MessageBox]::Show("DNS Cache cleared successfully.") 
    })

$ui.btnResetStack.Add_Click({
        $confirm = [System.Windows.MessageBox]::Show("Reset IP stack? This will drop connection.", "Confirm", "YesNo")
        if ($confirm -eq "Yes") {
            netsh int ip reset
            [System.Windows.MessageBox]::Show("Reset complete. Restart highly recommended.")
        }
    })

$ui.editLogPath.Text = $config.LogPath
$ui.editHost.Text = $config.Host
$ui.sldThresh.Value = $config.Threshold
$ui.editInterval.Text = $config.Interval
$ui.chkAutoStart.IsChecked = $config.AutoStart

if ($config.AutoStart) {
    $timer.Start()
    $ui.btnAction.Content = "STOP MONITORING"
    $ui.btnAction.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#1A1A1F")
}

$splashScreen.Show()
[System.Windows.Forms.Application]::DoEvents()
Get-NetworkSummary
$window.Add_Loaded({
        $splashScreen.Close()
    })
    
$window.Show()

[System.Windows.Forms.Application]::Run()

while ($notifyIcon.Visible) {
    [System.Windows.Forms.Application]::DoEvents()
    Start-Sleep -Milliseconds 100
}