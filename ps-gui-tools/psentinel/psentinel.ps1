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
                    <Button Name="navSoftware" Style="{StaticResource NavBtn}" Content="📦 Software Audit"/>
                    <Button Name="navDrivers" Style="{StaticResource NavBtn}" Content="🔌 Driver Manager"/>
                    <Button Name="navScreen" Style="{StaticResource NavBtn}" Content="📸 Remote View"/>
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
                        <StackPanel VerticalAlignment="Center">
                            <TextBlock Name="lblGlobalHost" Text="REMOTE HOST: DISCONNECTED" FontWeight="Bold" FontSize="14"/>
                            <TextBlock Name="lblSubStatus" Text="Awaiting initial synchronization..." FontSize="10" Foreground="#555"/>
                        </StackPanel>
                    </StackPanel>
                    <Button Name="btnGlobalSync" HorizontalAlignment="Right" Content="CONNECT / SYNC" Width="160" Height="35" Background="#007ACC" Foreground="White" BorderThickness="0" FontWeight="Bold"/>
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

                            <UniformGrid Columns="3" Height="110" Margin="0,15,0,0">
                                <Border Background="#121214" Margin="4" CornerRadius="10" BorderBrush="#1A1A1D" BorderThickness="1">
                                    <StackPanel VerticalAlignment="Center" Margin="15,0">
                                        <TextBlock Text="SYSTEM UPTIME" Foreground="#00BCD4" FontSize="10" FontWeight="Bold"/>
                                        <TextBlock Name="dashUptime" Text="-- d -- h" FontSize="24" FontWeight="Bold" Foreground="White"/>
                                        <TextBlock Text="Continuous Operation" FontSize="9" Foreground="#444" Margin="0,5,0,0"/>
                                    </StackPanel>
                                </Border>
                                <Border Background="#121214" Margin="4" CornerRadius="10" BorderBrush="#1A1A1D" BorderThickness="1">
                                    <StackPanel VerticalAlignment="Center" Margin="15,0">
                                        <TextBlock Text="LAST BOOT TIME" Foreground="#FFEB3B" FontSize="10" FontWeight="Bold"/>
                                        <TextBlock Name="dashBoot" Text="--:--:--" FontSize="18" FontWeight="Bold" Foreground="White"/>
                                        <TextBlock Name="dashBootDate" Text="--/--/----" FontSize="10" Foreground="#666"/>
                                    </StackPanel>
                                </Border>
                                <Border Background="#121214" Margin="4" CornerRadius="10" BorderBrush="#1A1A1D" BorderThickness="1">
                                    <StackPanel VerticalAlignment="Center" Margin="15,0">
                                        <TextBlock Text="OS ARCHITECTURE" Foreground="#9C27B0" FontSize="10" FontWeight="Bold"/>
                                        <TextBlock Name="dashOS" Text="--" FontSize="18" FontWeight="Bold" Foreground="White" TextWrapping="Wrap"/>
                                        <TextBlock Name="dashBuild" Text="Build: ----" FontSize="9" Foreground="#444"/>
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
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/> <RowDefinition Height="Auto"/> <RowDefinition Height="Auto"/> <RowDefinition Height="*"/>    </Grid.RowDefinitions>

                        <StackPanel Grid.Row="0" Margin="0,0,0,20">
                            <TextBlock Text="System Forensics &amp; Audit" FontSize="28" FontWeight="ExtraBold" Foreground="White"/>
                            <TextBlock Text="Real-time event analysis across System, Security, and Application logs." Foreground="#666"/>
                        </StackPanel>

                        <UniformGrid Grid.Row="1" Columns="4" Height="100" Margin="0,0,0,20">
                            <Border Background="#1A0A0A" BorderBrush="#FF4444" BorderThickness="1" CornerRadius="10" Margin="5">
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Text="CRITICAL ERRORS" Foreground="#FF4444" FontSize="10" FontWeight="Bold" HorizontalAlignment="Center"/>
                                    <TextBlock Name="cntCritical" Text="0" FontSize="32" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold"/>
                                    <TextBlock Text="System Stability" FontSize="9" Foreground="#444444" HorizontalAlignment="Center"/>
                                </StackPanel>
                            </Border>
                            <Border Background="#1A150A" BorderBrush="#FFA500" BorderThickness="1" CornerRadius="10" Margin="5">
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Text="AUTH FAILURES" Foreground="#FFA500" FontSize="10" FontWeight="Bold" HorizontalAlignment="Center"/>
                                    <TextBlock Name="cntSecurity" Text="0" FontSize="32" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold"/>
                                    <TextBlock Text="Security Log 4625" FontSize="9" Foreground="#444444" HorizontalAlignment="Center"/>
                                </StackPanel>
                            </Border>
                            <Border Background="#0A121A" BorderBrush="#007ACC" BorderThickness="1" CornerRadius="10" Margin="5">
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Text="DISK WARNINGS" Foreground="#007ACC" FontSize="10" FontWeight="Bold" HorizontalAlignment="Center"/>
                                    <TextBlock Name="cntDisk" Text="0" FontSize="32" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold"/>
                                    <TextBlock Text="I/O &amp; Controller" FontSize="9" Foreground="#444444" HorizontalAlignment="Center"/>
                                </StackPanel>
                            </Border>
                            <Border Background="#0A1A0F" BorderBrush="#2ECC71" BorderThickness="1" CornerRadius="10" Margin="5">
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Text="APP CRASHES" Foreground="#2ECC71" FontSize="10" FontWeight="Bold" HorizontalAlignment="Center"/>
                                    <TextBlock Name="cntApp" Text="0" FontSize="32" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold"/>
                                    <TextBlock Text="Faulting Modules" FontSize="9" Foreground="#444444" HorizontalAlignment="Center"/>
                                </StackPanel>
                            </Border>
                        </UniformGrid>

                        <Border Grid.Row="2" Background="#111" CornerRadius="5" Padding="15,10" Margin="5,0,5,15" BorderBrush="#222" BorderThickness="1">
                            <DockPanel>
                                <TextBlock Text="🔍 FILTER LOGS:" VerticalAlignment="Center" Margin="0,0,15,0" Foreground="#007ACC" FontWeight="Bold" FontSize="11"/>
                                <TextBox Name="txtEventFilter" VerticalContentAlignment="Center" Background="Transparent" Foreground="White" BorderThickness="0" CaretBrush="White"/>
                            </DockPanel>
                        </Border>

                        <Border Grid.Row="3" Background="#050505" CornerRadius="10" Padding="10" BorderBrush="#1A1A1D" BorderThickness="1">
                            <DataGrid Name="dgEvents" AutoGenerateColumns="False" Background="Transparent" Foreground="#BBB" BorderThickness="0" IsReadOnly="True" RowHeight="35">
                                <DataGrid.Columns>
                                    <DataGridTextColumn Header="TIME" Binding="{Binding Time}" Width="140"/>
                                    <DataGridTextColumn Header="ID" Binding="{Binding ID}" Width="70"/>
                                    <DataGridTextColumn Header="SOURCE" Binding="{Binding Source}" Width="180"/>
                                    <DataGridTextColumn Header="MESSAGE" Binding="{Binding Message}" Width="*"/>
                                </DataGrid.Columns>
                            </DataGrid>
                        </Border>
                    </Grid>
                </TabItem>

                <TabItem>
                    <Grid Margin="30">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/> <RowDefinition Height="Auto"/> <RowDefinition Height="Auto"/> <RowDefinition Height="*"/>    <RowDefinition Height="Auto"/> </Grid.RowDefinitions>

                        <StackPanel Grid.Row="0" Margin="0,0,0,20">
                            <TextBlock Text="Process Intelligence" FontSize="28" FontWeight="ExtraBold" Foreground="White"/>
                            <TextBlock Text="Real-time telemetry of active execution threads and resource consumption." Foreground="#666"/>
                        </StackPanel>

                        <UniformGrid Grid.Row="1" Columns="4" Height="100" Margin="0,0,0,20">
                            <Border Background="#0A121A" BorderBrush="#007ACC" BorderThickness="1" CornerRadius="10" Margin="5">
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Text="TOTAL PROCESSES" Foreground="#007ACC" FontSize="10" FontWeight="Bold" HorizontalAlignment="Center"/>
                                    <TextBlock Name="cntTotalProc" Text="0" FontSize="32" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold"/>
                                    <TextBlock Text="Active Threads" FontSize="9" Foreground="#444444" HorizontalAlignment="Center"/>
                                </StackPanel>
                            </Border>
                            <Border Background="#1A0A0A" BorderBrush="#FF4444" BorderThickness="1" CornerRadius="10" Margin="5">
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Text="HIGH CPU LOAD" Foreground="#FF4444" FontSize="10" FontWeight="Bold" HorizontalAlignment="Center"/>
                                    <TextBlock Name="cntHighCPU" Text="0" FontSize="32" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold"/>
                                    <TextBlock Text="> 20% Utilization" FontSize="9" Foreground="#444444" HorizontalAlignment="Center"/>
                                </StackPanel>
                            </Border>
                            <Border Background="#1A150A" BorderBrush="#FFA500" BorderThickness="1" CornerRadius="10" Margin="5">
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Text="SYSTEM SHELLS" Foreground="#FFA500" FontSize="10" FontWeight="Bold" HorizontalAlignment="Center"/>
                                    <TextBlock Name="cntShells" Text="0" FontSize="32" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold"/>
                                    <TextBlock Text="PS / CMD / Bash" FontSize="9" Foreground="#444444" HorizontalAlignment="Center"/>
                                </StackPanel>
                            </Border>
                            <Border Background="#0A1A0F" BorderBrush="#2ECC71" BorderThickness="1" CornerRadius="10" Margin="5">
                                <StackPanel VerticalAlignment="Center">
                                    <TextBlock Text="ORPHANED/SUSP" Foreground="#2ECC71" FontSize="10" FontWeight="Bold" HorizontalAlignment="Center"/>
                                    <TextBlock Name="cntSuspicious" Text="0" FontSize="32" Foreground="White" HorizontalAlignment="Center" FontWeight="Bold"/>
                                    <TextBlock Text="Non-Responsive" FontSize="9" Foreground="#444444" HorizontalAlignment="Center"/>
                                </StackPanel>
                            </Border>
                        </UniformGrid>

                        <Border Grid.Row="2" Background="#111" CornerRadius="5" Padding="15,10" Margin="5,0,5,15" BorderBrush="#222" BorderThickness="1">
                            <DockPanel>
                                <TextBlock Text="🔍 SEARCH PROCESS:" VerticalAlignment="Center" Margin="0,0,15,0" Foreground="#007ACC" FontWeight="Bold" FontSize="11"/>
                                <TextBox Name="txtProcFilter" VerticalContentAlignment="Center" Background="Transparent" Foreground="White" BorderThickness="0" CaretBrush="White"/>
                            </DockPanel>
                        </Border>

                        <DataGrid Name="dgProcesses" Grid.Row="3" AutoGenerateColumns="False" IsReadOnly="True" Background="Transparent" BorderThickness="0">
                            <DataGrid.Columns>
                                <DataGridTextColumn Header="PID" Binding="{Binding Id}" Width="80"/>
                                <DataGridTextColumn Header="NAME" Binding="{Binding Name}" Width="250"/>
                                <DataGridTextColumn Header="CPU %" Binding="{Binding CPU}" Width="100"/>
                                <DataGridTextColumn Header="MEM (MB)" Binding="{Binding Mem}" Width="100"/>
                                <DataGridTextColumn Header="PATH" Binding="{Binding Path}" Width="*"/>
                            </DataGrid.Columns>
                        </DataGrid>

                        <StackPanel Grid.Row="4" Orientation="Horizontal" HorizontalAlignment="Right" Margin="0,15,0,0">
                            <Button Name="btnRefreshProc" Content="REFRESH" Width="120" Height="40" Margin="0,0,10,0" Background="#1A1A25" Foreground="White"/>
                            <Button Name="btnKill" Content="TERMINATE PROCESS" Width="160" Height="40" Background="#B71C1C" Foreground="White" FontWeight="Bold" BorderThickness="0"/>
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
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/> <RowDefinition Height="150"/> <RowDefinition Height="Auto"/> </Grid.RowDefinitions>

                        <StackPanel Grid.Row="0" Margin="0,0,0,20">
                            <TextBlock Text="Network Intelligence Audit" FontSize="26" FontWeight="ExtraBold" Foreground="White"/>
                            <TextBlock Text="Live TCP/UDP socket monitoring and interface diagnostics." Foreground="#666"/>
                        </StackPanel>

                        <Border Grid.Row="1" Background="#0D0D0F" CornerRadius="10" Padding="10" BorderBrush="#1A1A1D" BorderThickness="1">
                            <DataGrid Name="dgNetstat" AutoGenerateColumns="False" Background="Transparent" Foreground="#BBB" BorderThickness="0" IsReadOnly="True">
                                <DataGrid.Columns>
                                    <DataGridTextColumn Header="PROCESS" Binding="{Binding ProcessName}" Width="120">
                                        <DataGridTextColumn.ElementStyle>
                                            <Style TargetType="TextBlock">
                                                <Setter Property="ToolTip" Value="{Binding Path}"/> </Style>
                                        </DataGridTextColumn.ElementStyle>
                                    </DataGridTextColumn>
                                        <DataGridTextColumn Header="PROTOCOL" Binding="{Binding Protocol}" Width="120"/>
                                        <DataGridTextColumn Header="USER" Binding="{Binding User}" Width="100"/>
                                        <DataGridTextColumn Header="LOCAL PORT" Binding="{Binding LocalPort}" Width="80"/>
                                        <DataGridTextColumn Header="REMOTE IP" Binding="{Binding RemoteAddress}" Width="120"/>
                                        <DataGridTextColumn Header="HOSTNAME" Binding="{Binding Hostname}" Width="180"/>
                                        <DataGridTextColumn Header="STATE" Binding="{Binding State}" Width="100"/>
                                        <DataGridTextColumn Header="EXE PATH" Binding="{Binding Path}" Width="250"/>
                                </DataGrid.Columns>
                            </DataGrid>
                        </Border>

                        <TextBox Name="txtNetOutput" Grid.Row="2" Margin="0,15,0,0" IsReadOnly="True" Background="#050505" Foreground="#00FF00" FontFamily="Consolas" VerticalScrollBarVisibility="Auto" Padding="10" BorderBrush="#222"/>

                        <UniformGrid Grid.Row="3" Columns="4" Margin="0,15,0,0">
                            <Button Name="btnNetstat" Content="🔍 SCAN CONNECTIONS" Height="45" Margin="0,0,5,0" Background="#007ACC" Foreground="White" FontWeight="Bold" BorderThickness="0"/>
                            <Button Name="btnIPConfig" Content="📋 INTERFACE DETAILS" Height="45" Margin="5,0,5,0" Background="#1A1A25" Foreground="White" BorderThickness="0"/>
                            <Button Name="btnRoutePrint" Content="🛤️ ROUTING TABLE" Height="45" Margin="5,0,5,0" Background="#1A1A25" Foreground="White" BorderThickness="0"/>
                            <Button Name="btnDNSFlush" Content="🧹 FLUSH DNS" Height="45" Margin="5,0,0,0" Background="#B71C1C" Foreground="White" BorderThickness="0"/>
                        </UniformGrid>
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
                                    <TextBox Name="txtCustomMsg" Text="ALERT" 
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
                        
                        <TextBlock Text="Task Management" FontSize="26" Foreground="White" Margin="0,0,0,20"/>
                        
                        <Border Grid.Row="1" Background="#0A0A10" Padding="20" CornerRadius="8" Margin="0,0,0,20" BorderBrush="#1A1A25" BorderThickness="1">
                            <Grid>
                                <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
                                <StackPanel Grid.Column="0" Margin="0,0,10,0">
                                    <TextBlock Text="TASK NAME" FontSize="10" Foreground="#00A2FF" Margin="0,0,0,5"/>
                                    <TextBox Name="txtSchedName" Text="watchDog" Padding="8" Background="#15151A" Foreground="White" BorderThickness="1" BorderBrush="#333"/>
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

                        <UniformGrid Grid.Row="3" Columns="6" Margin="0,15,0,0">
                            <Button Name="btnSchedRefresh" Content="🔄 REFRESH" Height="45" Margin="0,0,3,0" Background="#1A1A25" Foreground="White" BorderThickness="0"/>
                            <Button Name="btnSchedStart"   Content="▶️ RUN"     Height="45" Margin="3,0,3,0" Background="#0D47A1" Foreground="White" BorderThickness="0"/>
                            <Button Name="btnSchedStop"    Content="⏹️ STOP"    Height="45" Margin="3,0,3,0" Background="#B71C1C" Foreground="White" BorderThickness="0"/>
                            <Button Name="btnSchedEnable"  Content="🔓 ENABLE"  Height="45" Margin="3,0,3,0" Background="#2E7D32" Foreground="White" BorderThickness="0"/>
                            <Button Name="btnSchedDisable" Content="🔒 DISABLE" Height="45" Margin="3,0,3,0" Background="#424242" Foreground="White" BorderThickness="0"/>
                            <Button Name="btnSchedDelete"  Content="🗑️ DELETE"  Height="45" Margin="3,0,0,0" Background="#D32F2F" Foreground="White" BorderThickness="0"/>
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
                        <TextBlock Text="Target IP / Hostname"/><TextBox Name="txtHost" Text="remote_host" Margin="0,5,0,20" Padding="12" Background="#111114" Foreground="White"/>
                        <TextBlock Text="Admin Username"/><TextBox Name="txtUser" Text="remote_user" Margin="0,5,0,20" Padding="12" Background="#111114" Foreground="White"/>
                        <TextBlock Text="Access Password"/><PasswordBox Name="txtPass" Margin="0,5,0,30" Padding="12" Background="#111114" Foreground="White"/>
                    </StackPanel>
                </TabItem>
                
                <TabItem>
                    <Grid Margin="30">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        
                        <StackPanel Grid.Row="0" Margin="0,0,0,20">
                            <TextBlock Text="Live Screen Capture" FontSize="28" FontWeight="ExtraBold" Foreground="White"/>
                            <TextBlock Text="Visualizes the active user's desktop session via GDI+ capture." Foreground="#666"/>
                        </StackPanel>

                        <Border Grid.Row="1" Background="#050505" BorderBrush="#1A1A1D" BorderThickness="1" CornerRadius="10" Padding="5">
                            <Image Name="imgScreenshot" Stretch="Uniform" RenderOptions.BitmapScalingMode="HighQuality">
                                <Image.Effect>
                                    <DropShadowEffect BlurRadius="15" ShadowDepth="0" Color="Black" Opacity="0.5"/>
                                </Image.Effect>
                            </Image>
                        </Border>

                        <Button Name="btnTakeScreenshot" Grid.Row="2" Content="GENERATE REMOTE SCREENSHOT" 
                                Height="50" Margin="0,20,0,0" Background="#007ACC" Foreground="White" FontWeight="Bold" BorderThickness="0"/>
                    </Grid>
                </TabItem>

                <TabItem Header="📦 Software Audit">
                    <Grid Margin="30">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="*"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>
                        
                        <StackPanel Grid.Row="0" Margin="0,0,0,20">
                            <TextBlock Text="Software &amp; Package Inventory" FontSize="28" FontWeight="ExtraBold" Foreground="White"/>
                            <TextBlock Text="Comprehensive audit of Win32 Apps, Appx Packages, and System Features." Foreground="#666"/>
                        </StackPanel>

                        <Border Grid.Row="1" Background="#0D0D0F" CornerRadius="10" Padding="10" BorderBrush="#1A1A1D" BorderThickness="1">
                            <DataGrid Name="dgSoftware" AutoGenerateColumns="False" Background="Transparent" Foreground="#BBB" BorderThickness="0" IsReadOnly="True" SelectionMode="Single">
                                <DataGrid.Columns>
                                    <DataGridTextColumn Header="STATUS" Binding="{Binding Status}" Width="85">
                                        <DataGridTextColumn.ElementStyle>
                                            <Style TargetType="TextBlock">
                                                <Style.Triggers>
                                                    <DataTrigger Binding="{Binding Status}" Value="ACTIVE">
                                                        <Setter Property="Foreground" Value="#00FF00"/>
                                                        <Setter Property="FontWeight" Value="Bold"/>
                                                    </DataTrigger>
                                                    <DataTrigger Binding="{Binding Status}" Value="Idle">
                                                        <Setter Property="Foreground" Value="#666"/>
                                                    </DataTrigger>
                                                </Style.Triggers>
                                            </Style>
                                        </DataGridTextColumn.ElementStyle>
                                    </DataGridTextColumn>

                                    <DataGridTextColumn Header="APPLICATION NAME" Binding="{Binding Name}" Width="*"/>
                                    <DataGridTextColumn Header="VERSION" Binding="{Binding Version}" Width="100"/>
                                    <DataGridTextColumn Header="PUBLISHER" Binding="{Binding Publisher}" Width="120"/>
                                    <DataGridTextColumn Header="ARCH" Binding="{Binding Arch}" Width="60"/>
                                    <DataGridTextColumn Header="SOURCE" Binding="{Binding Source}" Width="70"/>
                                    <DataGridTextColumn Header="INSTALL DATE" Binding="{Binding InstallDate}" Width="100"/>
                                </DataGrid.Columns>
                            </DataGrid>
                        </Border>

                        <UniformGrid Grid.Row="2" Columns="4" Margin="0,15,0,0">
                            <Button Name="btnScanSoftware" Content="🔍 FULL INVENTORY SCAN" Height="50" Background="#007ACC" Foreground="White" FontWeight="Bold" BorderThickness="0"/>
                            <Button Name="btnListUpdates" Content="🛡️ VIEW PENDING UPDATES" Height="50" Margin="10,0" Background="#1A1A25" Foreground="White" BorderThickness="0"/>
                            <Button Name="btnGetFeatures" Content="⚙️ WINDOWS FEATURES" Height="50" Margin="0,0,10,0" Background="#1A1A25" Foreground="White" BorderThickness="0"/>
                            <Button Name="btnUninstallApp" Content="❌ UNINSTALL SELECTED" Height="50" Background="#B71C1C" Foreground="White" FontWeight="Bold" BorderThickness="0"/>
                        </UniformGrid>
                    </Grid>
                </TabItem>

                <TabItem Header="🔌 Driver Manager">
                    <Grid Margin="30">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/> <RowDefinition Height="*"/>    <RowDefinition Height="Auto"/> </Grid.RowDefinitions>

                        <StackPanel Grid.Row="0" Margin="0,0,0,15">
                            <TextBlock Text="Hardware &amp; Driver Audit" FontSize="26" FontWeight="Bold" Foreground="White"/>
                            <DockPanel Margin="0,5,0,0">
                                <TextBlock Text="Complete inventory of PnP devices." Foreground="#666"/>
                                <StackPanel Orientation="Horizontal" HorizontalAlignment="Right">
                                    <TextBlock Text="🔍 FILTER:" VerticalAlignment="Center" Margin="0,0,10,0" Foreground="#007ACC" FontSize="10"/>
                                    <TextBox Name="txtDriverFilter" Width="200" Background="#111" Foreground="White" BorderBrush="#333" Padding="4"/>
                                </StackPanel>
                            </DockPanel>
                        </StackPanel>

                        <Border Grid.Row="1" Background="#0D0D0F" CornerRadius="8" BorderBrush="#1A1A1D" BorderThickness="1">
                            <DataGrid Name="dgDrivers" AutoGenerateColumns="False" Background="Transparent" 
                                    Foreground="#BBB" BorderThickness="0" IsReadOnly="True" 
                                    SelectionMode="Single" VerticalScrollBarVisibility="Auto">
                                <DataGrid.Columns>
                                    <DataGridTextColumn Header="CLASS" Binding="{Binding Class}" Width="120"/>
                                    <DataGridTextColumn Header="DEVICE NAME" Binding="{Binding FriendlyName}" Width="*"/>
                                    <DataGridTextColumn Header="STATUS" Binding="{Binding Status}" Width="80"/>
                                    <DataGridTextColumn Header="VERSION" Binding="{Binding DriverVersion}" Width="120"/>
                                    <DataGridTextColumn Header="INSTANCE ID" Binding="{Binding InstanceId}" Visibility="Collapsed"/>
                                </DataGrid.Columns>
                            </DataGrid>
                        </Border>
                        
                        <UniformGrid Grid.Row="2" Columns="4" Margin="0,15,0,0" Height="45">
                            <Button Name="btnScanDrivers" Content="🔍 FULL SCAN" Background="#007ACC" Foreground="White" FontWeight="Bold"/>
                            <Button Name="btnDriverProps" Content="📄 PROPERTIES" Margin="10,0" Background="#1A1A25" Foreground="White"/>
                            <Button Name="btnRestartDevice" Content="🔄 RESTART DEVICE" Margin="0,0,10,0" Background="#1A1A25" Foreground="White"/>
                            <Button Name="btnUninstallDriver" Content="❌ UNINSTALL" Background="#B71C1C" Foreground="White" FontWeight="Bold"/>
                        </UniformGrid>
                    </Grid>
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

function Invoke-RExec ($SB, $Param) {
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
                return Invoke-RExec $SB $Param 
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

function Get-ActualPing {
    param([string]$Hostname)
    try {
        $ping = New-Object System.Net.NetworkInformation.Ping
        $reply = $ping.Send($Hostname, 1000)
        if ($reply.Status -eq "Success") {
            return $reply.RoundtripTime
        }
        else {
            return -1
        }
    }
    catch {
        return -1
    }
}

$nodes = @(
    "lblNodeName", "lblNodeIP", "dashCPU", "pbCPU", "dashRAM", "pbRAM", 
    "dashDisk", "pbDisk", "dashPing", "stFW", "stAV", "stBit", 
    "stGW", "stDNS", "stUser", "stLogon", "stIdle", "dgEvents", "txtStatus", "elStatus",
    "cntCritical", "cntSecurity", "cntDisk", "cntApp", "txtEventFilter",
    "navScreen", "imgScreenshot", "btnTakeScreenshot",
    "dgNetstat", "btnNetstat", "btnIPConfig", "btnRoutePrint", "btnDNSFlush",
    "dgSoftware", "btnScanSoftware", "btnListUpdates", "btnGetFeatures", "btnUninstallApp",
    "dgDrivers", "txtDriverFilter", "btnScanDrivers",
    "dgProcesses", "txtProcFilter", "btnRefreshProc", "btnKill", "btnUninstallDriver",
    "btnDriverProps", "btnRestartDevice"
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
$navScreen.Add_Click({ $MainTabs.SelectedIndex = 10 })
$navSoftware.Add_Click({ $MainTabs.SelectedIndex = 11 })
$navDrivers.Add_Click({ $MainTabs.SelectedIndex = 12 })

$btnGlobalSync.Add_Click({
        $target = $txtHost.Text
        if ([string]::IsNullOrWhitespace($target)) { return }
        $mainStatus.Foreground = [System.Windows.Media.Brushes]::White
        $statusDot.Fill = [System.Windows.Media.Brushes]::Orange
        $elStatus.Fill = [System.Windows.Media.Brushes]::Orange
        $txtStatus.Text = "CONNECTING..."
        [System.Windows.Forms.Application]::DoEvents()
        $mainStatus.Text = "📡 Step 1/3: Pinging $target..."
        [System.Windows.Forms.Application]::DoEvents()
        $ms = Get-ActualPing -Hostname $target
        if ($ms -ge 0) {
            $latency = $ms
            $dashPing.Text = "$ms ms"
            $dashPing.Foreground = if ($ms -lt 100) { [System.Windows.Media.Brushes]::LightGreen } else { [System.Windows.Media.Brushes]::Orange }
            $mainStatus.Text = "📡 Step 1 Success ($ms ms). Authenticating..."
        }
        else {
            $latency = 999
            $dashPing.Text = "TIMEOUT"
            $dashPing.Foreground = [System.Windows.Media.Brushes]::Red
            $mainStatus.Text = "⚠️ Step 1: Timeout. Attempting WinRM anyway..."
        }
        [System.Windows.Forms.Application]::DoEvents()
        $lblGlobalHost.Text = "CONNECTING: $target..."
        $lblGlobalHost.Foreground = [System.Windows.Media.Brushes]::Orange
        $mainStatus.Text = "🚀 Step 3/3: Establishing WinRM Session & Fetching Data..."
        $txtStatus.Text = "POLLING..."
        [System.Windows.Forms.Application]::DoEvents()
        $data = Invoke-RExec {
            try {
                $comp = Get-CimInstance Win32_OperatingSystem -ErrorAction Stop
                $uptimeSpan = (Get-Date) - $comp.LastBootUpTime
                $cpu = Get-CimInstance Win32_Processor
                $disk = Get-CimInstance Win32_LogicalDisk -Filter "DeviceID='C:'"
                $net = Get-NetIPConfiguration | Where-Object { $_.IPv4Address -ne $null } | Select-Object -First 1
                $mp = Get-MpComputerStatus
                $bit = Get-BitLockerVolume -MountPoint "C:" -ErrorAction SilentlyContinue
                $u = "None"; $l = "N/A"; $i = "N/A"
                $q = quser 2>$null
                if ($q) { $f = $q[1] -split '\s+'; $u = $f[1]; $l = "$($f[5]) $($f[6])"; $i = $f[7] }
                $sysLogs = Get-WinEvent -FilterHashtable @{LogName = 'System'; Level = 1, 2; StartTime = (Get-Date).AddDays(-1) } -ErrorAction SilentlyContinue
                $secLogs = Get-WinEvent -FilterHashtable @{LogName = 'Security'; Id = 4625; StartTime = (Get-Date).AddDays(-1) } -ErrorAction SilentlyContinue
                $diskLogs = Get-WinEvent -FilterHashtable @{LogName = 'System'; ProviderName = 'Disk'; StartTime = (Get-Date).AddDays(-7) } -ErrorAction SilentlyContinue
                $appLogs = Get-WinEvent -FilterHashtable @{LogName = 'Application'; Level = 2 } -MaxEvents 50 -ErrorAction SilentlyContinue
                $ev = Get-WinEvent -FilterHashtable @{LogName = 'System'; Level = 1, 2 } -MaxEvents 16 -ErrorAction SilentlyContinue | ForEach-Object {
                    [PSCustomObject]@{ Time = $_.TimeCreated.ToString("HH:mm"); ID = $_.Id; Source = $_.ProviderName; Message = $_.Message.Trim() }
                }
                return @{
                    Success = $true;
                    HostName = $env:COMPUTERNAME;
                    IP = $net.IPv4Address[0].IPAddress;
                    CPU = $cpu.LoadPercentage;
                    RAM = [math]::Round((($comp.TotalVisibleMemorySize - $comp.FreePhysicalMemory) / $comp.TotalVisibleMemorySize * 100), 0);
                    Disk = [math]::Round((1 - ($disk.FreeSpace / $disk.Size)) * 100, 0);
                    GW = $net.IPv4DefaultGateway.NextHop; 
                    DNS = $net.DNSServer.ServerAddresses[0];
                    FW = (Get-NetFirewallProfile -Profile Domain).Enabled;
                    AV = $mp.RealTimeProtectionEnabled; 
                    Bit = ($bit.ProtectionStatus -eq "On");
                    User = $u; Logon = $l; Idle = $i; 
                    Events = $ev;
                    CritCount = ($sysLogs | Where-Object { $_.Level -eq 1 }).Count;
                    SecCount = $secLogs.Count;
                    DiskCount = $diskLogs.Count;
                    AppCount = $appLogs.Count;
                    OS = $comp.Caption;
                    Build = $comp.Version;
                    Uptime = "$($uptimeSpan.Days)d $($uptimeSpan.Hours)h $($uptimeSpan.Minutes)m";
                    BootTime = $comp.LastBootUpTime.ToString("HH:mm:ss");
                    BootDate = $comp.LastBootUpTime.ToString("MM/dd/yyyy");
                }
            }
            catch { return @{ Success = $false; Msg = $_.Exception.Message } }
        }
        if ($data.Success) {
            $lblNodeName.Text = "NODE: $($data.HostName)"
            $lblNodeIP.Text = "$($data.IP) | Latency: $($latency)ms"
            $dashCPU.Text = "$($data.CPU)%"; $pbCPU.Value = $data.CPU
            $dashRAM.Text = "$($data.RAM)%"; $pbRAM.Value = $data.RAM
            $dashDisk.Text = "$($data.Disk)%"; $pbDisk.Value = $data.Disk
            $dashPing.Text = "$($latency)ms"
            $stFW.Text = if ($data.FW) { "SECURE" } else { "OFF" }; $stFW.Foreground = if ($data.FW) { "#2ECC71" } else { "#F44336" }
            $stAV.Text = if ($data.AV) { "ACTIVE" } else { "DISABLED" }; $stAV.Foreground = if ($data.AV) { "#2ECC71" } else { "#F44336" }
            $stBit.Text = if ($data.Bit) { "ENCRYPTED" } else { "PLAIN" }; $stBit.Foreground = if ($data.Bit) { "#2ECC71" } else { "#E65100" }       
            $dashUptime.Text = $data.Uptime
            $dashBoot.Text = $data.BootTime
            $dashBootDate.Text = $data.BootDate
            $dashOS.Text = $data.OS.Replace("Microsoft ", "")
            $dashBuild.Text = "Build: $($data.Build)"        
            $stGW.Text = $data.GW; $stDNS.Text = $data.DNS
            $stUser.Text = $data.User; $stLogon.Text = "Logon: $($data.Logon)"; $stIdle.Text = "Idle: $($data.Idle)"
            if ($data.Events) { $dgEvents.ItemsSource = @($data.Events) } else { $dgEvents.ItemsSource = @() }
            $cntCritical.Text = $data.CritCount; $cntSecurity.Text = $data.SecCount; $cntDisk.Text = $data.DiskCount; $cntApp.Text = $data.AppCount
            $cntCritical.Foreground = if ([int]$data.CritCount -gt 0) { "#F44336" } else { "White" }
            $txtStatus.Text = "ONLINE"; $elStatus.Fill = "#2ECC71"; $statusDot.Fill = "#2ECC71"
            $lblGlobalHost.Text = "REMOTE HOST: $($data.HostName.ToUpper())"; $lblGlobalHost.Foreground = "White"
            $lblSubStatus.Text = "Online | User: $($data.User) | Time: $(Get-Date -Format "HH:mm:ss")"
            $mainStatus.Text = "✅ Synchronization Successful."
            $mainStatus.Foreground = [System.Windows.Media.Brushes]::LightGreen
        }
        else {
            $txtStatus.Text = "ERROR"; $elStatus.Fill = "#F44336"; $statusDot.Fill = "#F44336"
            $lblGlobalHost.Text = "REMOTE HOST: OFFLINE"; $lblGlobalHost.Foreground = "#F44336"
            $mainStatus.Text = "❌ Sync Failed: $($data.Msg)"
            $mainStatus.Foreground = [System.Windows.Media.Brushes]::Red
        }
    })

$btnRefreshProc.Add_Click({
        $procData = Invoke-RExec {
            $allProcs = Get-Process | Select-Object Id, ProcessName, CPU, WorkingSet, Path, Responding
            $total = $allProcs.Count
            $highUsage = ($allProcs | Where-Object { $_.CPU -gt 500 -or ($_.WorkingSet / 1MB) -gt 500 }).Count
            $shells = ($allProcs | Where-Object { $_.ProcessName -match "powershell|pwsh|cmd|bash|wsl" }).Count
            $orphans = ($allProcs | Where-Object { $_.Responding -eq $false }).Count
            $gridItems = $allProcs | ForEach-Object {
                [PSCustomObject]@{
                    Id   = $_.Id
                    Name = $_.ProcessName.ToUpper()
                    CPU  = if ($_.CPU) { [math]::Round($_.CPU, 2) } else { 0 }
                    Mem  = [math]::Round($_.WorkingSet / 1MB, 2)
                    Path = $_.Path
                }
            }
            return @{
                Items   = $gridItems
                Total   = $total
                HighCPU = $highUsage
                Shells  = $shells
                Orphans = $orphans
            }
        }
        if ($procData) {
            $list = New-Object System.Collections.Generic.List[PSObject]
            foreach ($p in $procData.Items) { $list.Add($p) }
            $dgProcesses.ItemsSource = $list
            $cntTotalProc.Text = [string]$procData.Total
            $cntHighCPU.Text = [string]$procData.HighCPU
            $cntShells.Text = [string]$procData.Shells
            $cntSuspicious.Text = [string]$procData.Orphans
            if ([int]$procData.HighCPU -gt 0) {
                $cntHighCPU.Foreground = [System.Windows.Media.Brushes]::Red
            }
            else {
                $cntHighCPU.Foreground = [System.Windows.Media.Brushes]::White
            }
        }
    })

$btnKill.Add_Click({
        if ($dgProcesses.SelectedItem) { Invoke-RExec { param($id) Stop-Process -Id $id -Force } $dgProcesses.SelectedItem.Id; $btnRefreshProc.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent))) }
    })

$btnListFiles.Add_Click({
        $path = $txtFilePath.Text
        $mainStatus.Text = "Fetching file list..."
        $results = Invoke-RExec { 
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
            $dgFiles.ItemsSource = $null
            $dgFiles.ItemsSource = [System.Collections.ArrayList]@($results)
            $mainStatus.Text = "Displayed $($results.Count) items."
        }
        else {
            $mainStatus.Text = "No items found or path inaccessible."
        }
    })

$btnSchedRefresh.Add_Click({
        $mainStatus.Text = "Fetching tasks..."
        $tasks = Invoke-RExec { 
            Get-ScheduledTask | ForEach-Object {
                $info = Get-ScheduledTaskInfo -TaskName $_.TaskName -TaskPath $_.TaskPath -ErrorAction SilentlyContinue
                [PSCustomObject]@{
                    Name       = $_.TaskName
                    Path       = $_.TaskPath
                    State      = $_.State.ToString()
                    LastResult = if ($info) { $info.LastTaskResult } else { "0" }
                }
            }
        }
        $dgTasks.ItemsSource = $tasks
        $mainStatus.Text = "Tasks Loaded."
    })

$btnCreateTask.Add_Click({
        $n = $txtSchedName.Text
        $e = $txtSchedPath.Text
        $a = $txtSchedArgs.Text
        Invoke-RExec {
            param($name, $exe, $tArgs) 
            $action = New-ScheduledTaskAction -Execute $exe -Argument $tArgs
            $trigger = New-ScheduledTaskTrigger -AtLogOn
            Register-ScheduledTask -Action $action -Trigger $trigger -TaskName $name -User "SYSTEM" -Force
        } $n, $e, $a
        $btnSchedRefresh.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
    })

$btnSchedStart.Add_Click({
        if ($dgTasks.SelectedItem) {
            $sel = $dgTasks.SelectedItem
            Invoke-RExec { param($name, $path) Start-ScheduledTask -TaskName $name -TaskPath $path } $sel.Name, $sel.Path
            $mainStatus.Text = "Task Started: $($sel.Name)"
        }
    })

$btnSchedStop.Add_Click({
        if ($dgTasks.SelectedItem) {
            $sel = $dgTasks.SelectedItem
            Invoke-RExec { param($name, $path) Stop-ScheduledTask -TaskName $name -TaskPath $path } $sel.Name, $sel.Path
            $mainStatus.Text = "Task Stopped: $($sel.Name)"
        }
    })

$btnSchedEnable.Add_Click({
        if ($dgTasks.SelectedItem) {
            Invoke-RExec { param($n, $p) Enable-ScheduledTask -TaskName $n -TaskPath $p } $dgTasks.SelectedItem.Name, $dgTasks.SelectedItem.Path
            $btnSchedRefresh.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
        }
    })

$btnSchedDisable.Add_Click({
        if ($dgTasks.SelectedItem) {
            $sel = $dgTasks.SelectedItem
            $mainStatus.Text = "Disabling task: $($sel.Name)..."
            Invoke-RExec { 
                param($name, $path) 
                Disable-ScheduledTask -TaskName $name -TaskPath $path -ErrorAction Stop
            } $sel.Name, $sel.Path
            $mainStatus.Text = "Task Disabled: $($sel.Name)"
            $btnSchedRefresh.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
        }
        else {
            $mainStatus.Text = "Warning: No task selected to disable."
        }
    })

$btnSchedDelete.Add_Click({
        if ($dgTasks.SelectedItem) {
            $sel = $dgTasks.SelectedItem
            $confirm = [System.Windows.MessageBox]::Show("Are you sure you want to delete task: $($sel.Name)?", "Confirm", "YesNo", "Warning")
            if ($confirm -eq "Yes") {
                Invoke-RExec { param($name, $path) Unregister-ScheduledTask -TaskName $name -TaskPath $path -Confirm:$false } $sel.Name, $sel.Path
                $btnSchedRefresh.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
            }
        }
    })

$txtEventFilter.Add_TextChanged({
        $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView($dgEvents.ItemsSource)
        if ($view) {
            $searchTerm = $txtEventFilter.Text.ToLower()
            $view.Filter = [Predicate[Object]] {
                param($item)
                if ([string]::IsNullOrWhiteSpace($searchTerm)) { return $true }
                return ($item.Message -like "*$searchTerm*") -or 
                ($item.Source -like "*$searchTerm*") -or 
                ($item.ID.ToString() -like "*$searchTerm*")
            }
            $view.Refresh()
        }
    })

$txtProcFilter.Add_TextChanged({
        $view = [System.Windows.Data.CollectionViewSource]::GetDefaultView($dgProcesses.ItemsSource)
        if ($view) {
            $searchTerm = $txtProcFilter.Text.ToLower()
            $view.Filter = [Predicate[Object]] {
                param($item)
                if ([string]::IsNullOrWhiteSpace($searchTerm)) { return $true }
                return ($item.Name -like "*$searchTerm*") -or ($item.Id.ToString() -eq $searchTerm)
            }
            $view.Refresh()
        }
    })

$btnNetstat.Add_Click({
        $mainStatus.Text = "Deep-scanning network stack and resolving hostnames..."
        $dgNetstat.ItemsSource = $null
        $netData = Invoke-RExec {
            $tcp = Get-NetTCPConnection -ErrorAction SilentlyContinue
            $udp = Get-NetUDPEndpoint -ErrorAction SilentlyContinue
            $procMap = Get-Process -IncludeUserName -ErrorAction SilentlyContinue | 
            Select-Object Id, ProcessName, Path, UserName
            $allConns = @($tcp) + @($udp)
            $allConns | ForEach-Object {
                $currPID = $_.OwningProcess
                $pInfo = $procMap | Where-Object { $_.Id -eq $currPID }
                $rAddr = $_.RemoteAddress
                $dnsName = "N/A"
                if ($rAddr -and $rAddr -notmatch "0.0.0.0|::|127.0.0.1") {
                    try { $dnsName = [System.Net.Dns]::GetHostEntry($rAddr).HostName } catch { $dnsName = "Unresolved" }
                }
                [PSCustomObject]@{
                    Protocol      = if ($_.GetType().Name -match "TCP") { "TCP" } else { "UDP" }
                    ProcessName   = if ($pInfo.ProcessName) { $pInfo.ProcessName.ToUpper() } else { "SYSTEM" }
                    PID           = $currPID
                    User          = $pInfo.UserName
                    LocalPort     = $_.LocalPort
                    RemoteAddress = if ($rAddr -eq "0.0.0.0" -or $rAddr -eq "::") { "LISTENING" } else { $rAddr }
                    Hostname      = $dnsName
                    State         = if ($_.State) { $_.State.ToString() } else { "ACTIVE" }
                    Path          = $pInfo.Path
                }
            } | Sort-Object State, ProcessName
        }
        if ($netData) {
            $dgNetstat.ItemsSource = $netData
            $mainStatus.Text = "Deep Audit Successful: $($netData.Count) sockets analyzed."
        }
        else {
            $mainStatus.Text = "Audit Failed. Check WinRM permissions."
        }
    })

$btnIPConfig.Add_Click({
        $txtNetOutput.Text = Invoke-RExec { ipconfig /all | Out-String }
    })

$btnRoutePrint.Add_Click({
        $txtNetOutput.Text = Invoke-RExec { route print -4 | Out-String }
    })

$btnDNSFlush.Add_Click({
        Invoke-RExec { ipconfig /flushdns }
        $txtNetOutput.Text = "DNS Resolver Cache Flushed Successfully."
    })

$btnPanicMsg.Add_Click({
        $customMessage = $txtCustomMsg.Text
        if ([string]::IsNullOrWhiteSpace($customMessage)) {
            $mainStatus.Text = "Error: Message cannot be empty."
            return
        }
        Invoke-RExec { 
            param($msg) 
            msg * "$msg" 
        } $customMessage
        $mainStatus.Text = "Message sent to all sessions."
    })

$btnBlockInput.Add_Click({
        Invoke-RExec {
            $code = '[DllImport("user32.dll")] public static extern bool BlockInput(bool fBlockIt);'
            $type = Add-Type -MemberDefinition $code -Name "Win32BlockInput" -Namespace Win32Functions -PassThru
            $type::BlockInput($true)
            Start-Sleep -Seconds 60
            $type::BlockInput($false)
        }
    })

$btnLock.Add_Click({
        Invoke-RExec {
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
        Invoke-RExec {
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
        Invoke-RExec {
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

$btnRestart.Add_Click({ Invoke-RExec { Restart-Computer -Force } })

$btnBuzzer.Add_Click({
        Invoke-RExec {
            #$sessionID = (quser | Select-String ">" | ForEach-Object { ($_ -split '\s+')[2] })
            $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -Command [console]::Beep(1000,1000)"
            $taskName = "RemoteBuzzer_$(Get-Random)"
            Register-ScheduledTask -TaskName $taskName -Action $action -Force -Settings (New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries) | Out-Null
            Start-ScheduledTask -TaskName $taskName
            Start-Sleep -Seconds 2
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        }
    })

$btnDisableTools.Add_Click({
        Invoke-RExec {
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
        Invoke-RExec {
            Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableTaskMgr" -Value 0
            Set-ItemProperty "HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\System" -Name "DisableRegistryTools" -Value 0
            Set-ItemProperty "HKCU:\Software\Policies\Microsoft\Windows\System" -Name "DisableCMD" -Value 0
        }
    })

$btnRunShell.Add_Click({ $cmd = $txtCommand.Text; $txtOutput.Text = Invoke-RExec { param($c) Invoke-Expression $c 2>&1 | Out-String } $cmd })

$btnSvcRefresh.Add_Click({
        $svcs = Invoke-RExec { Get-Service | Select-Object Name, DisplayName, Status }
        $dgServices.ItemsSource = foreach ($s in $svcs) { [PSCustomObject]@{ Name = $s.Name; Display = $s.DisplayName; Status = $s.Status.ToString() } }
    })

$btnTakeScreenshot.Add_Click({
        $mainStatus.Text = "Requesting Remote GDI+ Capture..."
        $btnTakeScreenshot.IsEnabled = $false
        $remoteCapScript = {
            $path = "$env:TEMP\rs_cap.png"
            Add-Type -AssemblyName System.Windows.Forms, System.Drawing
            $screen = [System.Windows.Forms.Screen]::PrimaryScreen
            $bmp = New-Object System.Drawing.Bitmap($screen.Bounds.Width, $screen.Bounds.Height)
            $gfx = [System.Drawing.Graphics]::FromImage($bmp)
            $gfx.CopyFromScreen($screen.Bounds.X, $screen.Bounds.Y, 0, 0, $bmp.Size)
            $bmp.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
            $gfx.Dispose()
            $bmp.Dispose()
        }
        $rawBytes = Invoke-RExec {
            param($sBlock)
            $tempFile = "$env:TEMP\cap_task.ps1"
            $sBlock.ToString() | Out-File $tempFile -Force
            $tName = "RC_Screenshot_$(Get-Random)"
            $action = New-ScheduledTaskAction -Execute "powershell.exe" -Argument "-WindowStyle Hidden -ExecutionPolicy Bypass -File $tempFile"
            Register-ScheduledTask -TaskName $tName -Action $action -Force | Out-Null
            Start-ScheduledTask -TaskName $tName
            $retry = 0
            while (!(Test-Path "$env:TEMP\rs_cap.png") -and $retry -lt 15) { Start-Sleep -Milliseconds 500; $retry++ }
            if (Test-Path "$env:TEMP\rs_cap.png") {
                $bytes = [System.IO.File]::ReadAllBytes("$env:TEMP\rs_cap.png")
                Remove-Item "$env:TEMP\rs_cap.png", $tempFile -Force -ErrorAction SilentlyContinue
                Unregister-ScheduledTask -TaskName $tName -Confirm:$false
                return $bytes
            }
        } $remoteCapScript
        if ($rawBytes) {
            $ms = New-Object System.IO.MemoryStream(, $rawBytes)
            $bi = New-Object System.Windows.Media.Imaging.BitmapImage
            $bi.BeginInit()
            $bi.StreamSource = $ms
            $bi.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
            $bi.EndInit()
            $bi.Freeze()
            $imgScreenshot.Source = $bi
            $mainStatus.Text = "Screenshot Received."
        }
        else {
            $mainStatus.Text = "Capture Failed: Ensure a user is logged in and active."
        }
        $btnTakeScreenshot.IsEnabled = $true
    })

$btnScanSoftware.Add_Click({
        $mainStatus.Text = "Deep-scanning Registry, Appx, and Running Processes..."
        $dgSoftware.ItemsSource = $null
        $softwareList = Invoke-RExec {
            $runningProcs = Get-Process | Select-Object -ExpandProperty Name
            $results = New-Object System.Collections.Generic.List[PSCustomObject]
            $regPaths = @(
                "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*",
                "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*"
            )
            foreach ($path in $regPaths) {
                $keys = Get-ItemProperty $path -ErrorAction SilentlyContinue
                foreach ($key in $keys) {
                    if ($key.DisplayName) {
                        $isRun = "Idle"
                        foreach ($p in $runningProcs) {
                            if ($key.DisplayName -like "*$p*") { $isRun = "ACTIVE"; break }
                        }
                        $results.Add([PSCustomObject]@{
                                Status      = $isRun
                                Name        = $key.DisplayName
                                Version     = $key.DisplayVersion
                                Publisher   = $key.Publisher
                                InstallDate = $key.InstallDate
                                Arch        = if ($key.PSPath -match "WOW6432Node") { "x86" } else { "x64" }
                                Source      = "Win32"
                                Location    = $key.InstallLocation
                                UninstallID = $key.PSChildName
                            })
                    }
                }
            }
            Get-AppxPackage -AllUsers | ForEach-Object {
                $results.Add([PSCustomObject]@{
                        Status      = "Modern"
                        Name        = $_.Name
                        Version     = $_.Version
                        Publisher   = ($_.Publisher -split ",")[0].Replace("CN=", "")
                        InstallDate = "N/A"
                        Arch        = "Appx"
                        Source      = "Store"
                        Location    = $_.InstallLocation
                        UninstallID = $_.PackageFullName
                    })
            }
            $results | Sort-Object Status, Name
        }
        $dgSoftware.ItemsSource = $softwareList
        $mainStatus.Text = "Inventory complete."
    })

$btnListUpdates.Add_Click({
        $mainStatus.Text = "📡 Connecting to Windows Update Agent... (This may take 30-60s)"
        $dgSoftware.ItemsSource = $null
        $updatesList = Invoke-RExec {
            try {
                $updateSession = New-Object -ComObject Microsoft.Update.Session
                $updateSearcher = $updateSession.CreateUpdateSearcher()
                $searchResult = $updateSearcher.Search("IsInstalled=0 and Type='Software'")
                $searchResult.Updates | ForEach-Object {
                    [PSCustomObject]@{
                        Status      = "PENDING"
                        Name        = $_.Title
                        Version     = "KB" + ($_.KBArticleIDs -join ", ")
                        Publisher   = "Microsoft (Windows Update)"
                        Arch        = if ($_.Categories.Name -contains "Critical Updates") { "CRITICAL" } else { "Optional" }
                        Source      = "WinUpdate"
                        InstallDate = "Waiting..."
                        UninstallID = $_.Identity.UpdateID
                    }
                }
            }
            catch {
                return $null
            }
        }
        if ($updatesList) {
            $dgSoftware.ItemsSource = $updatesList
            $mainStatus.Text = "Update Scan Complete: $($updatesList.Count) updates pending."
        }
        else {
            $mainStatus.Text = "No pending updates found or Service is disabled."
            $dgSoftware.ItemsSource = @() 
        }
    })

$btnGetFeatures.Add_Click({
        $mainStatus.Text = "Querying Windows Optional Features manifest..."
        $dgSoftware.ItemsSource = $null
        $featuresList = Invoke-RExec {
            Get-WindowsOptionalFeature -Online -ErrorAction SilentlyContinue | ForEach-Object {
                [PSCustomObject]@{
                    Status      = if ($_.State -eq "Enabled") { "ACTIVE" } else { "Disabled" }
                    Name        = $_.FeatureName
                    Version     = "OS Native"
                    Publisher   = "Microsoft Corporation"
                    Arch        = "System"
                    Source      = "WinFeature"
                    InstallDate = "N/A"
                    UninstallID = $_.FeatureName 
                }
            } | Sort-Object Status, Name
        }
        if ($featuresList) {
            $dgSoftware.ItemsSource = $featuresList
            $mainStatus.Text = "Windows Features Audit Complete: Found $($featuresList.Count) items."
        }
        else {
            $mainStatus.Text = "Error: Could not retrieve Windows Features. Try running as Admin."
        }
    })

$btnUninstallApp.Add_Click({
        $selected = $dgSoftware.SelectedItem
        if ($null -eq $selected) { 
            $mainStatus.Text = "⚠️ Error: No software selected for removal."
            $mainStatus.Foreground = "Red"
            return 
        }
        $appName = $selected.Name
        $appId = $selected.UninstallID
        $source = $selected.Source
        $msgText = "Are you absolutely sure you want to uninstall:`n`n[$appName]`n`nFrom the remote system? This action cannot be undone."
        $msgCaption = "Confirm Remote Uninstallation"
        $msgButtons = [System.Windows.MessageBoxButton]::YesNo
        $msgIcon = [System.Windows.MessageBoxImage]::Warning
        $response = [System.Windows.MessageBox]::Show($msgText, $msgCaption, $msgButtons, $msgIcon)
        if ($response -ne "Yes") {
            $mainStatus.Text = "❌ Uninstallation of $appName cancelled by user."
            $mainStatus.Foreground = "White"
            return
        }
        $mainStatus.Text = "⏳ Initializing deep-removal for: $appName..."
        $mainStatus.Foreground = "Orange"
        $result = Invoke-RExec {
            param($id, $type, $name)
            try {
                if ($type -match "Win32|Registry") {
                    $running = Get-Process | Where-Object { $_.ProcessName -match ($name -split " ")[0] } -ErrorAction SilentlyContinue
                    if ($running) {
                        Stop-Process -Name $running.ProcessName -Force -ErrorAction SilentlyContinue 
                    }
                }
                if ($type -match "Appx|Store") {
                    Remove-AppxPackage -Package $id -AllUsers -ErrorAction Stop
                    return "SUCCESS: Modern App '$name' purged."
                } 
                elseif ($type -eq "WinFeature") {
                    Disable-WindowsOptionalFeature -Online -FeatureName $id -NoRestart -ErrorAction Stop
                    return "SUCCESS: Feature '$id' disabled."
                }
                else {
                    $regPaths = @(
                        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$id",
                        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\$id",
                        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\$id"
                    )
                    $unString = ""
                    foreach ($path in $regPaths) {
                        $key = Get-ItemProperty $path -ErrorAction SilentlyContinue
                        if ($key.UninstallString) { $unString = $key.UninstallString; break }
                    }
                    if ($unString) {
                        if ($unString -match "MsiExec.exe") {
                            $silentArgs = $unString -replace "MsiExec.exe", "" -replace "/I", "/X"
                            $silentArgs += " /qn /norestart /L*V C:\Windows\Temp\Uninstall_$id.log"
                            $p = Start-Process MsiExec.exe -ArgumentList $silentArgs -Wait -PassThru
                            if ($p.ExitCode -eq 0) { return "SUCCESS: MSI Uninstalled." }
                            else { return "FAILED: MsiExec Exit Code $($p.ExitCode)" }
                        }
                        else {
                            $p = Start-Process cmd.exe -ArgumentList "/c $unString /S /SILENT /VERYSILENT /QUIET /NORESTART" -Wait -PassThru -WindowStyle Hidden
                            return "SUCCESS: Executed Uninstaller (Exit: $($p.ExitCode))."
                        }
                    }
                    return "ERROR: Registry string for $id is missing or malformed."
                }
            }
            catch {
                return "FAILED: $($_.Exception.Message)"
            }
        } $appId $source $appName
        if ($result -match "SUCCESS") {
            $mainStatus.Text = "✅ $result ($appName)"
            $mainStatus.Foreground = "LightGreen"
            $timer = New-Object System.Windows.Threading.DispatcherTimer
            $timer.Interval = [TimeSpan]::FromSeconds(2)
            $timer.Add_Tick({
                    $this.Stop() 
                    $peer = New-Object System.Windows.Automation.Peers.ButtonAutomationPeer($btnScanSoftware)
                    $invoker = $peer.GetPattern([System.Windows.Automation.Peers.PatternInterface]::Invoke)
                    $invoker.Invoke()
                    $mainStatus.Text = "Inventory refreshed."
                })
            $timer.Start()
        }
        else {
            $mainStatus.Text = "❌ $result"
            $mainStatus.Foreground = "Red"
        }
    })

<# $navDrivers.Add_Click({ 
        $MainTabs.SelectedIndex = 12 
        $mainStatus.Text = "Hardware Inventory Tab Selected."
    }) #>

$btnScanDrivers.Add_Click({
        $target = $txtHost.Text
        if ([string]::IsNullOrWhiteSpace($target)) { 
            $mainStatus.Text = "❌ Error: No target host specified."
            $mainStatus.Foreground = "Red"
            return 
        }
        $mainStatus.Text = "📡 Step 1/1: Fetching full hardware tree from $target..."
        $mainStatus.Foreground = "Orange"
        [System.Windows.Forms.Application]::DoEvents()
        $results = Invoke-RExec {
            try {
                $allDevices = Get-PnpDevice -ErrorAction SilentlyContinue 
                $list = foreach ($dev in $allDevices) {
                    $verProperty = $dev | Get-PnpDeviceProperty -KeyName "DEVPKEY_Device_DriverVersion" -ErrorAction SilentlyContinue
                    [PSCustomObject]@{
                        Class         = $dev.Class
                        FriendlyName  = if ($dev.FriendlyName) { $dev.FriendlyName } else { $dev.Name }
                        Manufacturer  = $dev.Manufacturer
                        Status        = $dev.Status
                        DriverVersion = if ($verProperty.Data) { $verProperty.Data } else { "---" }
                        InstanceId    = $dev.InstanceId
                    }
                }
                return $list | Sort-Object Class, FriendlyName
            }
            catch {
                return $null
            }
        }
        if ($null -ne $results) {
            $global:FullDriverList = $results
            $dgDrivers.ItemsSource = @($results)
            $mainStatus.Text = "✅ Success: $($results.Count) devices indexed from $target."
            $mainStatus.Foreground = "LightGreen"
        }
        else {
            $mainStatus.Text = "❌ Failed: Could not retrieve device list (Check WinRM/Permissions)."
            $mainStatus.Foreground = "Red"
            $dgDrivers.ItemsSource = @()
        }
    })

$btnDriverProps.Add_Click({
        $selected = $dgDrivers.SelectedItem
        if (-not $selected) { return }
        $mainStatus.Text = "📡 Fetching deep properties..."
        [System.Windows.Forms.Application]::DoEvents()
        $details = Invoke-RExec {
            param($id)
            $dev = Get-PnpDevice -InstanceId $id
            $ver = ($dev | Get-PnpDeviceProperty -KeyName "DEVPKEY_Device_DriverVersion").Data
            $date = ($dev | Get-PnpDeviceProperty -KeyName "DEVPKEY_Device_DriverDate").Data
            $inf = ($dev | Get-PnpDeviceProperty -KeyName "DEVPKEY_Device_DriverInfPath").Data
            $prov = ($dev | Get-PnpDeviceProperty -KeyName "DEVPKEY_Device_DriverProvider").Data
            return "Device: $($dev.FriendlyName)`n`nStatus: $($dev.Status)`nManufacturer: $($dev.Manufacturer)`nDriver Version: $ver`nDriver Date: $date`nINF Path: $inf`nProvider: $prov`nInstance ID: $id"
        } $selected.InstanceId
        [System.Windows.MessageBox]::Show($details, "Driver Technical Properties", "OK", "Information")
    })

$btnRestartDevice.Add_Click({
        $selected = $dgDrivers.SelectedItem
        if (-not $selected) { return }
        $mainStatus.Text = "🔄 Attempting to cycle device: $($selected.FriendlyName)"
        [System.Windows.Forms.Application]::DoEvents()
        $res = Invoke-RExec {
            param($id)
            try {
                Disable-PnpDevice -InstanceId $id -Confirm:$false
                Start-Sleep -Seconds 2
                Enable-PnpDevice -InstanceId $id -Confirm:$false
                return "SUCCESS"
            }
            catch { return $_.Exception.Message }
        } $selected.InstanceId
        if ($res -eq "SUCCESS") {
            $mainStatus.Text = "✅ Device restarted successfully."
            $mainStatus.Foreground = "LightGreen"
        }
        else {
            $mainStatus.Text = "❌ Restart Failed: $res"
            $mainStatus.Foreground = "Red"
        }
    })

$btnUninstallDriver.Add_Click({
        $selected = $dgDrivers.SelectedItem
        if (-not $selected) { return }
        $msg = "Confirm uninstallation of:`n$($selected.FriendlyName)"
        $ans = [System.Windows.MessageBox]::Show($msg, "Warning", "YesNo", "Exclamation")
        if ($ans -eq "Yes") {
            $id = $selected.InstanceId
            $res = Invoke-RExec {
                param($targetId)
                $process = Start-Process pnputil -ArgumentList "/remove-device ""$targetId""" -Wait -PassThru -WindowStyle Hidden
                if ($process.ExitCode -eq 0) { return "OK" } else { return "Error Code: $($process.ExitCode)" }
            } $id
            if ($res -eq "OK") {
                $mainStatus.Text = "✅ Device Removed. Refreshing..."
                $btnScanDrivers.RaiseEvent((New-Object System.Windows.RoutedEventArgs([System.Windows.Controls.Button]::ClickEvent)))
            }
            else {
                $mainStatus.Text = "❌ Failed: $res"
            }
        }
    })

$txtDriverFilter.Add_TextChanged({
        if ($global:FullDriverList) {
            $q = $txtDriverFilter.Text
            $dgDrivers.ItemsSource = @($global:FullDriverList | Where-Object { $_.FriendlyName -match $q -or $_.Class -match $q })
        }
    })

$window.ShowDialog() | Out-Null