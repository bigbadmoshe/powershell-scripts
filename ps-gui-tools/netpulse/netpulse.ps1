Add-Type -AssemblyName PresentationFramework, System.Windows.Forms, System.Drawing

if (-not ([System.Management.Automation.PSTypeName]'IconHelper').Type) {
    Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class IconHelper {
        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern bool DestroyIcon(IntPtr handle);
    }
"@
}

[xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="NetPulse Pro" Height="450" Width="700" 
        WindowStartupLocation="CenterScreen" Background="Transparent" AllowsTransparency="True" WindowStyle="None">
    
    <Border Name="MainBorder" CornerRadius="15" Background="#1E1E1E" BorderBrush="#333" BorderThickness="1">
        <Grid>
            <Grid.ColumnDefinitions>
                <ColumnDefinition Width="70"/> <!-- Sidebar -->
                <ColumnDefinition Width="*"/>  <!-- Content -->
            </Grid.ColumnDefinitions>

            <!-- Sidebar / Navbar -->
            <StackPanel Grid.Column="0" Background="#2D2D30" Name="SideBar">
                <TextBlock Text="&#xE774;" FontFamily="Segoe MDL2 Assets" FontSize="24" Foreground="#0078D7" 
                           HorizontalAlignment="Center" Margin="0,20,0,40"/>
                
                <Button Name="navPing" Content="&#xE950;" FontFamily="Segoe MDL2 Assets" Height="50" Background="Transparent" BorderThickness="0" Foreground="White" FontSize="20" ToolTip="Monitor"/>
                <Button Name="navSettings" Content="&#xE713;" FontFamily="Segoe MDL2 Assets" Height="50" Background="Transparent" BorderThickness="0" Foreground="Gray" FontSize="20" ToolTip="Settings"/>
                
                <Separator Background="#444" Margin="10,20"/>
                
                <Button Name="btnExit" Content="&#xE7E8;" FontFamily="Segoe MDL2 Assets" Height="50" Background="Transparent" BorderThickness="0" Foreground="#E81123" FontSize="20" VerticalAlignment="Bottom"/>
            </StackPanel>

            <!-- Content Area -->
            <Grid Grid.Column="1" Margin="30">
                <!-- Header -->
                <StackPanel VerticalAlignment="Top" HorizontalAlignment="Right" Orientation="Horizontal">
                    <Button Name="btnMinimize" Content="&#xE921;" FontFamily="Segoe MDL2 Assets" Background="Transparent" BorderThickness="0" Foreground="Gray" Margin="0,0,10,0"/>
                </StackPanel>

                <!-- PING VIEW -->
                <StackPanel Name="viewPing" Visibility="Visible" VerticalAlignment="Center">
                    <TextBlock Name="lblTitle" Text="Network Monitor" FontSize="28" FontWeight="Bold" Foreground="White" Margin="0,0,0,5"/>
                    <TextBlock Name="lblHostDisplay" Text="Target: 8.8.8.8" Foreground="Gray" Margin="0,0,0,30"/>
                    
                    <Grid>
                        <Ellipse Name="statusRing" Width="180" Height="180" Stroke="#333" StrokeThickness="10"/>
                        <StackPanel VerticalAlignment="Center" HorizontalAlignment="Center">
                            <TextBlock Name="lblPingLarge" Text="--" FontSize="48" FontWeight="Black" Foreground="White" HorizontalAlignment="Center"/>
                            <TextBlock Text="ms" FontSize="14" Foreground="Gray" HorizontalAlignment="Center"/>
                        </StackPanel>
                    </Grid>

                    <Button Name="btnStartStop" Content="START SERVICE" Height="45" Width="200" Margin="0,40,0,0" Background="#0078D7" Foreground="White" FontWeight="Bold">
                        <Button.Resources><Style TargetType="Border"><Setter Property="CornerRadius" Value="22"/></Style></Button.Resources>
                    </Button>
                </StackPanel>

                <!-- SETTINGS VIEW -->
                <StackPanel Name="viewSettings" Visibility="Collapsed" VerticalAlignment="Center">
                    <TextBlock Text="Settings" FontSize="28" FontWeight="Bold" Foreground="White" Margin="0,0,0,20"/>
                    
                    <TextBlock Text="IP Address / Hostname" Foreground="Gray" Margin="0,10,0,5"/>
                    <TextBox Name="txtHost" Text="8.8.8.8" FontSize="16" Padding="8" Background="#333" Foreground="White" BorderThickness="0"/>
                    
                    <TextBlock Text="Theme Selection" Foreground="Gray" Margin="0,20,0,5"/>
                    <StackPanel Orientation="Horizontal">
                        <Button Name="btnDarkTheme" Content="Dark" Width="80" Height="30" Margin="0,0,10,0"/>
                        <Button Name="btnLightTheme" Content="Light" Width="80" Height="30"/>
                    </StackPanel>
                </StackPanel>
            </Grid>
        </Grid>
    </Border>
</Window>
"@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)

$nodes = "MainBorder", "SideBar", "navPing", "navSettings", "viewPing", "viewSettings", "btnStartStop", 
"txtHost", "lblPingLarge", "lblHostDisplay", "statusRing", "btnExit", "btnMinimize", 
"btnDarkTheme", "btnLightTheme", "lblTitle"
$nodes | ForEach-Object { Set-Variable -Name $_ -Value $window.FindName($_) }

function Set-Theme($theme) {
    if ($theme -eq "Dark") {
        $MainBorder.Background = "#1E1E1E"
        $SideBar.Background = "#2D2D30"
        $lblTitle.Foreground = "White"
        $lblPingLarge.Foreground = "White"
        $txtHost.Background = "#333"
        $txtHost.Foreground = "White"
    }
    else {
        $MainBorder.Background = "#F3F3F3"
        $SideBar.Background = "#E5E5E5"
        $lblTitle.Foreground = "#333"
        $lblPingLarge.Foreground = "#333"
        $txtHost.Background = "White"
        $txtHost.Foreground = "#333"
    }
}

$navPing.Add_Click({ 
        $viewPing.Visibility = "Visible"; $viewSettings.Visibility = "Collapsed"
        $navPing.Foreground = "White"; $navSettings.Foreground = "Gray"
    })
$navSettings.Add_Click({ 
        $viewPing.Visibility = "Collapsed"; $viewSettings.Visibility = "Visible"
        $navSettings.Foreground = "White"; $navPing.Foreground = "Gray"
    })


$btnExit.Add_Click({ $window.Close() })
$btnMinimize.Add_Click({ $window.WindowState = "Minimized" })
$window.Add_MouseLeftButtonDown({ $window.DragMove() }) # Window is draggable

$notifyIcon = New-Object System.Windows.Forms.NotifyIcon
$notifyIcon.Text = "NetPulse Pro"
$notifyIcon.Visible = $true
$notifyIcon.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -id $pid).Path)

$ctx = New-Object System.Windows.Forms.ContextMenuStrip
$ctx.Items.Add("Open", $null, { $window.Show(); $window.WindowState = "Normal" })
$ctx.Items.Add("Exit", $null, { $window.Close() })
$notifyIcon.ContextMenuStrip = $ctx

function Set-Tray([string]$val, $color) {
    $bmp = New-Object System.Drawing.Bitmap(16, 16)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $font = New-Object System.Drawing.Font("Arial", 8, [System.Drawing.FontStyle]::Bold)
    $g.Clear([System.Drawing.Color]::Transparent)
    $g.DrawString($val, $font, (New-Object System.Drawing.SolidBrush($color)), -1, 1)
    $h = $bmp.GetHicon()
    $old = $notifyIcon.Icon
    $notifyIcon.Icon = [System.Drawing.Icon]::FromHandle($h)
    if ($old) { [IconHelper]::DestroyIcon($old.Handle) }
    $g.Dispose(); $bmp.Dispose()
}

$timer = New-Object System.Windows.Threading.DispatcherTimer
$timer.Interval = [TimeSpan]::FromSeconds(1)
$timer.Add_Tick({
        $hostName = $txtHost.Text
        $lblHostDisplay.Text = "Target: $hostName"
    
        try {
            $res = Test-Connection -ComputerName $hostName -Count 1 -ErrorAction SilentlyContinue
            if ($res) {
                $ms = $res.ResponseTime
                $lblPingLarge.Text = $ms
                $statusRing.Stroke = "#0078D7"
                Set-Tray -val $ms -color ([System.Drawing.Color]::LimeGreen)
            }
            else {
                $lblPingLarge.Text = "!!"
                $statusRing.Stroke = "Red"
                Set-Tray -val "!!" -color ([System.Drawing.Color]::Red)
            }
        }
        catch { $lblPingLarge.Text = "ERR" }
    })

$btnStartStop.Add_Click({
        if ($timer.IsEnabled) {
            $timer.Stop()
            $btnStartStop.Content = "START SERVICE"
            $btnStartStop.Background = "#0078D7"
        }
        else {
            $timer.Start()
            $btnStartStop.Content = "STOP SERVICE"
            $btnStartStop.Background = "#D70000"
        }
    })

$btnDarkTheme.Add_Click({ Set-Theme "Dark" })
$btnLightTheme.Add_Click({ Set-Theme "Light" })

$window.Add_Closed({
        $notifyIcon.Visible = $false
        $notifyIcon.Dispose()
    })

$window.ShowDialog()