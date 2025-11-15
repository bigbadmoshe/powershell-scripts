function Start-MemoryLoad {
    <#
    .SYNOPSIS
    Memory Load Generator & Stress Tester (Local or Remote)

    .DESCRIPTION
    This function consumes system memory until only a specified safety margin remains. It supports both local and remote (WinRM) execution with live monitoring.

    .EXAMPLE
    Start-MemoryLoad -HeadroomMB 1024

    .NOTES
    v0.0.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "Amount of memory (in MB) to keep free for system stability")]
        [int]$HeadroomMB = 512,

        [Parameter(Mandatory = $false, HelpMessage = "Remote computer name for WinRM execution")]
        [string]$ComputerName,

        [Parameter(Mandatory = $false, HelpMessage = "Username for remote authentication")]
        [string]$User,

        [Parameter(Mandatory = $false, HelpMessage = "Password for remote authentication")]
        [string]$Pass
    )
    if ($ComputerName) {
        if (-not ($User -and $Pass)) {
            Write-Error "For remote execution, both -User and -Pass are required."
            return
        }
        $securePass = ConvertTo-SecureString $Pass -AsPlainText -Force
        $cred = New-Object PSCredential ($User, $securePass)
        Write-Host "Connecting to $ComputerName via WinRM..." -ForegroundColor Cyan
        try {
            Invoke-Command -ComputerName $ComputerName -Credential $cred `
                -ScriptBlock ${function:Start-MemoryLoad} `
                -ArgumentList $HeadroomMB
        }
        catch {
            Write-Error "Remote execution failed: $($_.Exception.Message)"
        }
        return
    }
    Write-Host "Starting Memory Load Test (leaving $HeadroomMB MB free)..." -ForegroundColor Yellow
    $System = Get-CimInstance Win32_ComputerSystem
    $TotalMB = [math]::Round($System.TotalPhysicalMemory / 1MB)
    $MemCounter = New-Object System.Diagnostics.PerformanceCounter("Memory", "Available MBytes")
    $null = $MemCounter.NextValue()
    $MaxUsage = $TotalMB - $HeadroomMB
    $StartTime = Get-Date
    Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    Write-Host " Total Memory:       $TotalMB MB"
    Write-Host " Reserved Headroom:  $HeadroomMB MB"
    Write-Host " Target Usage:       $MaxUsage MB"
    Write-Host " Start Time:         $StartTime"
    Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-="
    $Block = "x" * 200MB
    $GrowArray = @()
    $BigArray = @()
    $i = 0
    $lastProgress = -1
    try {
        do {
            $BigArray += , @($i, $GrowArray)
            $GrowArray += $Block
            $i++
            $Used = $TotalMB - $MemCounter.NextValue()
            $Progress = [math]::Round(($Used / $MaxUsage) * 100, 1)
            if ($Progress -ne $LastProgress) {
                Write-Host ("Memory Usage: {0} / {1} MB ({2}%)" -f $Used, $MaxUsage, $Progress)
                $LastProgress = $Progress
            }
            Start-Sleep -Milliseconds 250
        } while ($Used -lt $MaxUsage)
    }
    catch {
        Write-Warning "Memory allocation interrupted: $($_.Exception.Message)"
    }
    Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    Write-Host " Final Used: $Used / $MaxUsage MB"
    Write-Host " Duration:   $((Get-Date) - $StartTime)"
    Write-Host "=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-"
    Read-Host -Prompt "Press ENTER to release allocated memory (Ctrl+C to abort)"
    Write-Host "Releasing memory..." -ForegroundColor Cyan
    try {
        $BigArray.Clear()
        $GrowArray.Clear()
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()
    }
    catch {
        Write-Warning "Memory cleanup encountered an issue: $($_.Exception.Message)"
    }
    $Free = $MemCounter.NextValue()
    $UsedNow = $TotalMB - $Free
    Write-Host ("RAM Cleared: {0} MB used" -f $UsedNow) -ForegroundColor Green
    Write-Host ("Free Memory: {0} MB" -f $Free)
    Write-Host "Completed at: $(Get-Date)" -ForegroundColor Yellow
}
