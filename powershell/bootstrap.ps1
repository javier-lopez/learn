<#
.SYNOPSIS
    Set up Windows: Chocolatey and its packages, Windhawk and its mods, settings
.DESCRIPTION
    Unattended, and safe to run again: every step skips what is already done.

    1. Chocolatey: installed when choco.exe is missing, then every package in
       -Packages; choco leaves the installed ones alone.
    2. Windhawk: installed when windhawk-cli.exe is missing (it first ships in
       2.0, so a 1.x install gets upgraded; mods and settings survive the
       upgrade), then every mod in -WindhawkMods that is not installed yet,
       and its settings applied. Mods already installed are not reinstalled:
       `mod install` enables the mod it installs, which would undo one
       disabled by hand. Their settings are still applied.
    3. Settings: End task in the taskbar's right-click menu, as Settings >
       System > For developers > End task.

    Needs an elevated shell: Chocolatey and Windhawk install machine-wide.
    Elevate as yourself (Run as administrator, or gsudo): settings go to the
    current user's HKCU, so under another admin account they land on that
    account instead.

    One file, so a bare machine can run it straight from GitHub before git is
    there to clone the repository.
.PARAMETER Packages
    Chocolatey packages to install
.PARAMETER WindhawkMods
    Mod id -> settings. windhawk-cli validates each key against the settings
    the mod declares, so a typo fails instead of being stored; list them with
    `windhawk-cli repo show <id>`.
.PARAMETER WindhawkVersion
    Windhawk release tag to install when windhawk-cli.exe is missing. 1.x tags
    carry a "v" prefix, 2.0 prereleases do not.
.PARAMETER Skip
    Steps to leave out: Chocolatey, Windhawk, Settings
.EXAMPLE
    irm https://raw.githubusercontent.com/javier-lopez/learn/master/powershell/bootstrap.ps1 | iex

    On a bare machine, from an elevated PowerShell: every step, with the defaults
.EXAMPLE
    & ([scriptblock]::Create((irm https://raw.githubusercontent.com/javier-lopez/learn/master/powershell/bootstrap.ps1))) -Skip Windhawk

    The same, passing parameters
.EXAMPLE
    .\bootstrap.ps1 -Packages git, gsudo -Skip Windhawk

    From a clone: two packages and the settings
.EXAMPLE
    .\bootstrap.ps1 -WindhawkMods @{ 'taskbar-thumbnail-reorder' = @{}; 'taskbar-clock-customization' = @{} }

    Two mods with their default settings
.EXAMPLE
    . .\bootstrap.ps1
    Add-WindhawkMod taskbar-thumbnail-reorder @{ oldTaskbarOnWin11 = $true }
    Set-TaskbarEndTask $false

    Dot-source to use the functions alone; nothing runs on load
#>
[CmdletBinding()]
param
(
    [Parameter(Mandatory=$false)]
    [string[]]$Packages = @('ag', 'wget', '7zip', 'notepadplusplus', 'gsudo', 'microsoft-windows-terminal',
                            'make', 'mingw', 'git', 'localsend', 'vcredist140'),
    [Parameter(Mandatory=$false)]
    [System.Collections.IDictionary]$WindhawkMods = [ordered]@{
        'taskbar-thumbnail-reorder' = @{ oldTaskbarOnWin11 = $false }
    },
    [Parameter(Mandatory=$false)]
    [string]$WindhawkVersion = '2.0.0-alpha.5',
    [Parameter(Mandatory=$false)]
    [ValidateSet('Chocolatey', 'Windhawk', 'Settings')]
    [string[]]$Skip = @()
)

$ErrorActionPreference = 'Stop'

function Test-Administrator {
    <#
    .SYNOPSIS
        $true in an elevated shell
    #>

    $principal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Invoke-Native {
    <#
    .SYNOPSIS
        Run an executable, pass its stdout on, throw on an exit code not in -Success
    #>

    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        [string]$FilePath,
        [Parameter(Position=1, Mandatory=$true)]
        [string[]]$Arguments,
        [Parameter(Mandatory=$false)]
        [int[]]$Success = @(0)
    )

    # Native tools report failures on stderr plus their exit code. Under 'Stop'
    # Windows PowerShell can turn native stderr into a terminating error before
    # the exit code is read, so judge the call by the exit code alone.
    $ErrorActionPreference = 'Continue'
    & $FilePath @Arguments
    if ($Success -notcontains $LASTEXITCODE) {
        throw "$(Split-Path -Leaf $FilePath) $Arguments failed with exit code $LASTEXITCODE"
    }
}

function Get-ChocolateyCli {
    <#
    .SYNOPSIS
        Path to choco.exe, or $null when Chocolatey is not installed
    #>

    $command = Get-Command choco.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($command) {
        return $command.Path
    }
    # A fresh install reaches the PATH of new processes, not this one's.
    $root = [System.Environment]::GetEnvironmentVariable('ChocolateyInstall', 'Machine')
    if (-Not $root) {
        $root = Join-Path $env:ProgramData 'chocolatey'
    }
    $choco = Join-Path $root 'bin\choco.exe'
    if (Test-Path $choco) {
        return $choco
    }
    return $null
}

function Install-Chocolatey {
    <#
    .SYNOPSIS
        Install Chocolatey with its official install script
    #>

    Write-Host 'Installing Chocolatey'
    # In a process of its own, under the execution policy Chocolatey's
    # instructions ask for: an `exit` in its script would end this one too.
    $script = '[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; ' +
              "iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    $encoded = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($script))
    # Not Invoke-Native: its error would quote the encoded command. Same
    # reason as there to judge the call by the exit code alone.
    $ErrorActionPreference = 'Continue'
    powershell.exe -NoProfile -ExecutionPolicy Bypass -EncodedCommand $encoded | Out-Host
    if ($LASTEXITCODE -ne 0) {
        throw "Chocolatey's install script failed with exit code $LASTEXITCODE"
    }
}

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

    $installed = (Invoke-Native $Cli '--json', 'mod', 'list' | Out-String | ConvertFrom-Json).data.mods |
        ForEach-Object { $_.id }
    if ($installed -contains $Id) {
        Write-Host "${Id}: already installed"
    } else {
        Invoke-Native $Cli 'mod', 'install', $Id | Out-Host
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
        Invoke-Native $Cli (@('mod', 'settings', 'set', $Id) + $pairs) | Out-Host
    }
}

# Where the End task toggle keeps its state; the key is absent until first used.
$TaskbarEndTaskKey  = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings'
$TaskbarEndTaskName = 'TaskbarEndTask'

function Get-TaskbarEndTask {
    <#
    .SYNOPSIS
        $true when End task is on for the current user
    #>

    $property = Get-ItemProperty -Path $TaskbarEndTaskKey -Name $TaskbarEndTaskName -ErrorAction SilentlyContinue
    return [bool]($property -and $property.$TaskbarEndTaskName -eq 1)
}

function Set-TaskbarEndTask {
    <#
    .SYNOPSIS
        Turn End task on or off for the current user
    .DESCRIPTION
        Needs Windows 11 22631.2715 (23H2) or newer; older builds store the
        value but show nothing. Applies on the next right-click, no Explorer
        restart.
    .PARAMETER Enabled
        $true to show End task in the taskbar's right-click menu, $false to hide it
    .EXAMPLE
        Set-TaskbarEndTask $true
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Position=0, Mandatory=$true)]
        [bool]$Enabled
    )

    $state = if ($Enabled) { 'on' } else { 'off' }
    if ((Get-TaskbarEndTask) -eq $Enabled) {
        Write-Host "End task: already $state"
        return
    }

    if (-Not (Test-Path $TaskbarEndTaskKey)) {
        $null = New-Item -Path $TaskbarEndTaskKey -Force
    }
    # -Force overwrites a value left with another type.
    $null = New-ItemProperty -Path $TaskbarEndTaskKey -Name $TaskbarEndTaskName `
        -PropertyType DWord -Value ([int]$Enabled) -Force
    Write-Host "End task: $state"
}

# Dot-sourced: only define the functions. Under `irm | iex` the name is empty,
# so that runs everything too.
if ($MyInvocation.InvocationName -ne '.') {
    if (-Not (Test-Administrator)) {
        throw 'Run from an elevated PowerShell: Run as administrator, or gsudo once Chocolatey has installed it'
    }

    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    # The progress bar slows Invoke-WebRequest in Windows PowerShell many times over.
    $ProgressPreference = 'SilentlyContinue'

    if ($Skip -notcontains 'Chocolatey') {
        $choco = Get-ChocolateyCli
        if (-Not $choco) {
            Install-Chocolatey
            $choco = Get-ChocolateyCli
            if (-Not $choco) {
                throw 'Chocolatey installed, but choco.exe is not in its bin folder'
            }
        }
        if ($Packages) {
            # 1641 and 3010: installed, a reboot finishes the job.
            Invoke-Native $choco (@('install', '-y') + $Packages) -Success 0, 1641, 3010 | Out-Host
        }
    }

    if ($Skip -notcontains 'Windhawk') {
        $cli = Get-WindhawkCli
        if (-Not $cli) {
            Install-Windhawk -Version $WindhawkVersion
            $cli = Get-WindhawkCli
            if (-Not $cli) {
                throw "Windhawk $WindhawkVersion installed, but windhawk-cli.exe is not in the folder its uninstall entry names"
            }
        }
        foreach ($id in $WindhawkMods.Keys) {
            Add-WindhawkMod -Id $id -Settings $WindhawkMods[$id] -Cli $cli
        }
    }

    if ($Skip -notcontains 'Settings') {
        Set-TaskbarEndTask $true
    }
}
