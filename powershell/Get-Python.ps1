function Source-Python-Version {
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$false)]
        [ValidateSet("full","minimal")]
        [string]$Type="full",
        [Parameter(Position=1, Mandatory=$true)]
        [string]$Version,
        [Parameter(Position=2, Mandatory=$false)]
        [string]$TargetDir=".",
        [Parameter(Position=3, Mandatory=$false)]
        [string]$TargetFullDir
    )

    if ($TargetFullDir) {
        $TargetDir=$TargetFullDir
    } else {
        $TargetDir+="\python-$Type-$Version"
    }

    $env:path = "$TargetDir\python\tools\;$TargetDir\python\tools\Scripts\;$env:path"
    python --version
}

function Get-Python-Version {
    <#
    .SYNOPSIS
        Install an specified python version
    .DESCRIPTION
        Install an specified python version
    .PARAMETER Type
        The Python Installation Type
    .PARAMETER Version
        The Python Version
    .PARAMETER TargetDir
        Install to this base directory
    .PARAMETER TargetFullDir
        Install to this full path directory
    .EXAMPLE
        Get-Python-Version -Type full -Version 3.8.0 -TargetDir E:\deploy\apps\python

        Install python full 3.8.0 version into E:\deploy\apps\python\python-full-3.8.0
    .EXAMPLE
        Get-Python-Version -Type minimal -Version 3.8.0 -TargetDir E:\deploy\apps\python

        Install python minimal 3.8.0 version into E:\deploy\apps\python\python-minimal-3.8.0
    .EXAMPLE
        Get-Python-Version -Type minimal -Version 3.8.0 -TargetFullDir E:\deploy\apps\python3.8.0

        Install python minimal 3.8.0 version into E:\deploy\apps\python3.8.0
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$false)]
        [ValidateSet("full","minimal")]
        [string]$Type="full",
        [Parameter(Position=1, Mandatory=$true)]
        [string]$Version,
        [Parameter(Position=2, Mandatory=$false)]
        [string]$TargetDir=".",
        [Parameter(Position=3, Mandatory=$false)]
        [string]$TargetFullDir
    )

    if ($TargetFullDir) {
        $TargetDir=$TargetFullDir
    } else {
        $TargetDir+="\python-$Type-$Version"
    }

    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

    Write-Host $Type $Version $TargetDir
    Switch -regex ($Type)     {
        'full' {
            Write-Host "TODO: full installation mode"
            Write-Host "https://docs.python.org/3/using/windows.html#windows-full"
        }
        'minimal' {
            if (-Not (Get-Command "nuget" -errorAction SilentlyContinue)) {
                Invoke-WebRequest -Uri "https://aka.ms/nugetclidl" -OutFile "nuget.exe"
                $env:path += ";."
            }

            nuget | Select-Object -first 1
            nuget install python -Version $Version -OutputDirectory $TargetDir -ExcludeVersion
        }
    }
}
