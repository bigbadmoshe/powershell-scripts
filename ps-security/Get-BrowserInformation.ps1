function Get-BrowserInformation {
    <#
    .SYNOPSIS
    Retrieves browser data such as history or bookmarks from supported browsers.

    .DESCRIPTION
    This function extracts URLs from history or bookmarks files of major browsers, can optionally filter results by a search string.

    .EXAMPLE
    Get-BrowserInformation -Browser brave -DataType bookmarks
    Get-BrowserInformation -Browser chrome -DataType history -Search "github"
    
    .NOTES
    v0.0.1
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, HelpMessage = "Specify the browser to query")]
        [ValidateSet('chrome', 'edge', 'brave', 'opera', 'vivaldi', 'chromium', 'firefox')]
        [string]$Browser,

        [Parameter(Mandatory = $true, HelpMessage = "Data type to retrieve")]
        [ValidateSet('history', 'bookmarks')]
        [string]$DataType,

        [Parameter(Mandatory = $false, HelpMessage = "Filter string (regex or plain text)")]
        [string]$Search = ''
    )
    $UrlPattern = '(http|https)://([\w-]+\.)+[\w-]+(/[^\s"<>]*)?'
    $browserPaths = @{
        chrome   = "$env:LOCALAPPDATA\Google\Chrome\User Data"
        edge     = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
        brave    = "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\User Data"
        opera    = "$env:APPDATA\Opera Software\Opera Stable"
        vivaldi  = "$env:LOCALAPPDATA\Vivaldi\User Data"
        chromium = "$env:LOCALAPPDATA\Chromium\User Data"
        firefox  = "$env:APPDATA\Mozilla\Firefox\Profiles"
    }
    if (-not $browserPaths.ContainsKey($Browser)) {
        Write-Warning -Message "Unsupported browser: $Browser!"
        return
    }
    switch ($Browser) {
        { $_ -in @('chrome', 'edge', 'brave', 'vivaldi', 'chromium') } {
            $BasePath = $browserPaths[$Browser]
            $Profiles = Get-ChildItem -Path $BasePath -Directory -ErrorAction SilentlyContinue | 
            Where-Object { $_.Name -match 'Default|Profile \d+' }
            if (-not $Profiles) {
                Write-Warning -Message "No browser profiles found for $Browser!"
                return
            }
            $DataFiles = foreach ($Pr in $Profiles) {
                switch ($DataType) {
                    'history' { Join-Path $Pr.FullName 'History' }
                    'bookmarks' { Join-Path $Pr.FullName 'Bookmarks' }
                }
            }
        }
        'opera' {
            switch ($DataType) {
                'history' { $DataFiles = @("$($browserPaths[$Browser])\History") }
                'bookmarks' { $DataFiles = @("$($browserPaths[$Browser])\Bookmarks") }
            }
        }
        'firefox' {
            $Profiles = Get-ChildItem -Path $browserPaths['firefox'] -Directory -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match '\.default' }
            if (-not $Profiles) {
                Write-Warning -Message "No Firefox profiles found!"
                return
            }
            $DataFiles = switch ($DataType) {
                'history' { $Profiles | ForEach-Object { Join-Path $_.FullName 'places.sqlite' } }
                'bookmarks' { Write-Warning -Message "Firefox bookmarks not supported in this version"; return }
            }
        }
    }
    $Results = @()
    foreach ($File in $DataFiles) {
        if (-not (Test-Path $File)) {
            Write-Verbose -Message "Skipping missing file: $File"
            continue
        }
        Write-Verbose -Message "Reading data from: $File"
        try {
            Get-Content -Path $File -ErrorAction SilentlyContinue |
            Select-String -AllMatches $UrlPattern |
            ForEach-Object { $_.Matches.Value } |
            Sort-Object -Unique |
            Where-Object { $_ -match $Search } |
            ForEach-Object {
                $Results += [PSCustomObject]@{
                    User     = $env:USERNAME
                    Browser  = $Browser
                    Profile  = (Split-Path $File -Parent | Split-Path -Leaf)
                    DataType = $DataType
                    URL      = $_
                    FilePath = $File
                }
            }
        }
        catch {
            Write-Warning -Message "Failed to read: $File - $($_.Exception.Message)"
        }
    }
    if ($Results.Count -eq 0) {
        Write-Warning -Message "No matching data found for $Browser ($DataType)"
        return
    }
    return $Results
}
