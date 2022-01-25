function Source-Python-Version {
    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Version,
        [Parameter(Position=1, Mandatory=$false)]
        [string]$TargetDir=".",
        [Parameter(Position=2, Mandatory=$false)]
        [string]$TargetFullDir
    )

    if ($TargetFullDir) {
        $TargetDir=$TargetFullDir
    } else {
        $TargetDir+="\python-$Version"
    }

    $env:path = "$TargetDir\tools\;$TargetDir\tools\Scripts\;$env:path"
    python --version
}

function Get-Python-Version {
    <#
    .SYNOPSIS
        Install an specified python version
    .DESCRIPTION
        Install an specified python version
    .PARAMETER Version
        The Python Version
    .PARAMETER TargetDir
        Install to this base directory
    .PARAMETER TargetFullDir
        Install to this full path directory
    .EXAMPLE
        Get-Python-Version -Version 3.8.2 -TargetDir C:\Python

        Install python 3.8.2 version into C:\Python\python-3.8.2
    .EXAMPLE
        Get-Python-Version -Version 3.8.2 -TargetFullDir C:\Python\3.8.2

        Install python 3.8.2 version into C:\Python\3.8.2
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Version,
        [Parameter(Position=1, Mandatory=$false)]
        [string]$TargetDir=".",
        [Parameter(Position=2, Mandatory=$false)]
        [string]$TargetFullDir
    )

    if ($TargetFullDir) {
        $TargetDir=$TargetFullDir
    } else {
        $TargetDir+="\python-$Version"
    }

    New-Item -ItemType Directory -Force -Path $TargetDir | Out-Null

    Write-Host $Version $TargetDir
    if (-Not (Get-Command "nuget" -errorAction SilentlyContinue)) {
        Invoke-WebRequest -Uri "https://aka.ms/nugetclidl" -OutFile "nuget.exe"
        $env:path += ";."
    }

    nuget | Select-Object -first 1
    nuget install python -Version $Version -OutputDirectory $TargetDir -ExcludeVersion
	
	Move-Item -Path $TargetDir -Destination "$TargetDir.tmp"
    Move-Item -Path "$TargetDir.tmp\python" $TargetDir
	rmdir "$TargetDir.tmp"
}
