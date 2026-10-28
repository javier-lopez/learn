<#
.SYNOPSIS
    Install Windhawk and leave a list of mods installed and configured
.DESCRIPTION
    Unattended. Installs Windhawk when windhawk-cli.exe is missing (it first
    ships in 2.0, so a 1.x install gets upgraded; mods and settings survive the
    upgrade), then installs every mod in -Mods that is not installed yet and
    applies its settings.

    Mods already installed are not reinstalled: `mod install` enables the mod
    it installs, which would undo one disabled by hand. Their settings are
    still applied.

    Needs an elevated shell: Windhawk installs machine-wide.
.PARAMETER Mods
    Mod id -> settings. windhawk-cli validates each key against the settings
    the mod declares, so a typo fails instead of being stored; list them with
    `windhawk-cli repo show <id>`.
.PARAMETER Version
    Windhawk release tag to install when windhawk-cli.exe is missing. 1.x tags
    carry a "v" prefix, 2.0 prereleases do not.
.EXAMPLE
    .\Get-Windhawk.ps1

    Install Windhawk and the default mod list
.EXAMPLE
    .\Get-Windhawk.ps1 -Mods @{ 'taskbar-thumbnail-reorder' = @{}; 'taskbar-clock-customization' = @{} }

    Install two mods with their default settings
.EXAMPLE
    . .\Get-Windhawk.ps1
    Add-WindhawkMod taskbar-thumbnail-reorder @{ oldTaskbarOnWin11 = $true }

    Dot-source to use the functions alone; nothing runs on load
#>
[CmdletBinding()]
param
(
    [Parameter(Position=0, Mandatory=$false)]
    [System.Collections.IDictionary]$Mods = [ordered]@{
        'taskbar-thumbnail-reorder' = @{ oldTaskbarOnWin11 = $false }
    },
    [Parameter(Position=1, Mandatory=$false)]
    [string]$Version = '2.0.0-alpha.5'
)

$ErrorActionPreference = 'Stop'

function Get-WindhawkCli {
    <#
    .SYNOPSIS
        Path to the installed windhawk-cli.exe, or $null when there is none
    #>

    foreach ($key in 'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Windhawk',
                     'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Windhawk') {
        if (-Not (Test-Path $key)) {
            continue
        }
        $location = (Get-ItemProperty -Path $key).InstallLocation
        if ($location -and (Test-Path (Join-Path $location 'windhawk-cli.exe'))) {
            return Join-Path $location 'windhawk-cli.exe'
        }
    }
    return $null
}

function Install-Windhawk {
    <#
    .SYNOPSIS
        Download a Windhawk release and install it silently
    .PARAMETER Version
        Release tag, e.g. 2.0.0-alpha.5
    .EXAMPLE
        Install-Windhawk -Version 2.0.0-alpha.5
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Version
    )

    $setup = Join-Path $env:TEMP "windhawk_setup_$Version.exe"
    Write-Host "Downloading Windhawk $Version"
    Invoke-WebRequest -UseBasicParsing -OutFile $setup `
        -Uri "https://github.com/ramensoftware/windhawk/releases/download/$Version/windhawk_setup.exe"

    try {
        # It runs elevated, so check who built it. The signer, not a hash or a
        # thumbprint: both change with every release or certificate renewal.
        $signature = Get-AuthenticodeSignature -FilePath $setup
        if ($signature.Status -ne 'Valid' -or $signature.SignerCertificate.Subject -notlike '*Michael Maltsev*') {
            throw "Refusing to run the Windhawk installer: signature is $($signature.Status), signer '$($signature.SignerCertificate.Subject)'"
        }

        Write-Host "Installing Windhawk $Version"
        # Not -Wait: in Windows PowerShell it also waits for every process the
        # installer leaves running. Reading Handle before exit is what makes
        # ExitCode available afterwards on a -PassThru process.
        $process = Start-Process -FilePath $setup -ArgumentList '/S', '/STANDARD' -PassThru
        $null = $process.Handle
        $process.WaitForExit()
        if ($process.ExitCode -ne 0) {
            throw "Windhawk installer exited with code $($process.ExitCode)"
        }
    } finally {
        Remove-Item -Path $setup -Force
    }
}

function Invoke-WindhawkCli {
    <#
    .SYNOPSIS
        Run windhawk-cli.exe, return its stdout, throw on a non-zero exit code
    #>

    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Cli,
        [Parameter(Position=1, Mandatory=$true)]
        [string[]]$Arguments
    )

    # windhawk-cli reports failures on stderr plus its exit code. Under 'Stop'
    # Windows PowerShell can turn native stderr into a terminating error before
    # the exit code is read, so judge the call by the exit code alone.
    $ErrorActionPreference = 'Continue'
    $output = & $Cli @Arguments
    if ($LASTEXITCODE -ne 0) {
        throw "windhawk-cli $Arguments failed with exit code $LASTEXITCODE"
    }
    return $output
}

function Add-WindhawkMod {
    <#
    .SYNOPSIS
        Install a Windhawk mod unless it is installed, then apply its settings
    .PARAMETER Id
        Mod id as in the repository, e.g. taskbar-thumbnail-reorder
    .PARAMETER Settings
        Setting key -> value; keys are validated against the mod's declaration
    .PARAMETER Cli
        windhawk-cli.exe to drive; defaults to the installed one
    .EXAMPLE
        Add-WindhawkMod taskbar-thumbnail-reorder @{ oldTaskbarOnWin11 = $false }
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        [string]$Id,
        [Parameter(Position=1, Mandatory=$false)]
        [System.Collections.IDictionary]$Settings = @{},
        [Parameter(Mandatory=$false)]
        [string]$Cli = (Get-WindhawkCli)
    )

    if (-Not $Cli) {
        throw 'windhawk-cli.exe not found: install Windhawk 2.0 or newer first'
    }

    $installed = (Invoke-WindhawkCli $Cli '--json', 'mod', 'list' | Out-String | ConvertFrom-Json).data.mods |
        ForEach-Object { $_.id }
    if ($installed -contains $Id) {
        Write-Host "${Id}: already installed"
    } else {
        Invoke-WindhawkCli $Cli 'mod', 'install', $Id | Out-Host
    }

    $pairs = foreach ($key in $Settings.Keys) {
        $value = $Settings[$key]
        # A PowerShell boolean prints as True/False; the CLI's own spelling is lowercase.
        if ($value -is [bool]) {
            $value = $value.ToString().ToLower()
        }
        "$key=$value"
    }
    if ($pairs) {
        Invoke-WindhawkCli $Cli (@('mod', 'settings', 'set', $Id) + $pairs) | Out-Host
    }
}

# Dot-sourced: only define the functions.
if ($MyInvocation.InvocationName -ne '.') {
    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    if (-Not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        throw 'Run from an elevated shell, e.g. gsudo powershell -ExecutionPolicy Bypass -File .\Get-Windhawk.ps1'
    }

    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    # The progress bar slows Invoke-WebRequest in Windows PowerShell many times over.
    $ProgressPreference = 'SilentlyContinue'

    $cli = Get-WindhawkCli
    if (-Not $cli) {
        Install-Windhawk -Version $Version
        $cli = Get-WindhawkCli
        if (-Not $cli) {
            throw "Windhawk $Version installed, but windhawk-cli.exe is not in the folder its uninstall entry names"
        }
    }

    foreach ($id in $Mods.Keys) {
        Add-WindhawkMod -Id $id -Settings $Mods[$id] -Cli $cli
    }
}
