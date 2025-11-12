function Start-CPULoad {
    <#
    .SYNOPSIS
    CPU Load Generator & Stress Tester (Local or Remote)

    .DESCRIPTION
    This script loads the CPU using parallel mathematical computations. It supports configurable duration, core usage, and real-time monitoring. You can run it locally or remotely via WinRM.

    .EXAMPLE
    Start-CPULoad -Duration 30 -UseAllCores

    .NOTES
    v0.0.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "Duration of the CPU load test in seconds")]
        [int]$Duration = 60,

        [Parameter(Mandatory = $false, HelpMessage = "Use all available logical CPU cores")]
        [switch]$UseAllCores,

        [Parameter(Mandatory = $false, helpMessage = "Target computer name for remote execution")]
        [string]$ComputerName,

        [Parameter(Mandatory = $false, HelpMessage = "Username for remote authentication")]
        [string]$User,

        [Parameter(Mandatory = $false, HelpMessage = "Password for remote authentication")]
        [string]$Pass
    )
    if ($ComputerName) {
        if (-not ($User -and $Pass)) {
            Write-Error "You must specify both -Username and -Password for remote execution."
            return
        }
        $SecPass = ConvertTo-SecureString $Pass -AsPlainText -Force
        $Cred = New-Object System.Management.Automation.PSCredential ($User, $SecPass)
        Write-Host "Connecting remotely to $ComputerName..." -ForegroundColor Cyan
        try {
            Invoke-Command -ComputerName $ComputerName -Credential $Cred -ScriptBlock ${function:Start-CPULoad} `
                -ArgumentList $Duration, $UseAllCores
        }
        catch {
            Write-Error "Remote execution failed: $($_.Exception.Message)"
        }
        return
    }
    $CpuCount = if ($UseAllCores) { [Environment]::ProcessorCount } else { 1 }
    Write-Host "Starting CPU Load Test ($CpuCount core(s)) for $Duration seconds..." -ForegroundColor Yellow
    [System.Threading.Thread]::CurrentThread.Priority = 'Highest'
    $Jobs = @()
    $ScriptBlock = {
        param($Duration)
        $end = (Get-Date).AddSeconds($Duration)
        $x = 0
        while ((Get-Date) -lt $end) {
            $x = [math]::Sqrt($x + 1)
            if ($x -gt 100000) { $x = 0 }
        }
    }
    Write-Verbose -Message "Starting parallel load jobs"
    for ($i = 1; $i -le $cpuCount; $i++) {
        $Jobs += Start-Job -ScriptBlock $ScriptBlock -ArgumentList $Duration
    }
    $CpuCounter = New-Object System.Diagnostics.PerformanceCounter("Processor", "% Processor Time", "_Total")
    $null = $CpuCounter.NextValue()
    $StartTime = Get-Date
    Write-Host "Press Ctrl+C to stop early." -ForegroundColor DarkGray
    Write-Host "-------------------------------------------"
    try {
        while ((Get-Date) -lt $StartTime.AddSeconds($Duration)) {
            $CpuUsage = [math]::Round($CpuCounter.NextValue(), 1)
            Write-Host ("CPU Usage: {0}%" -f $CpuUsage).PadRight(25) -NoNewline
            Write-Host ("Time Elapsed: {0:N0}s" -f ((Get-Date) - $StartTime).TotalSeconds)
            Start-Sleep -Seconds 1
        }
    }
    catch {
        Write-Warning -Message "Test interrupted by user."
    }
    finally {
        Write-Host "Stopping background jobs..." -ForegroundColor Cyan
        Get-Job | Stop-Job -ErrorAction SilentlyContinue
        Get-Job | Remove-Job -Force -ErrorAction SilentlyContinue
        Write-Host "CPU Load Test completed." -ForegroundColor Green
    }
}
