<#
.SYNOPSIS
Test Runner to Unit tests for the current powershell version

.DESCRIPTION
Test Runner to Unit tests for the current powershell version.
This will run the powershell 5.1 unit tests on powershell 5.1, and the 
powershell core unit tests on powershell core.

It will output unit and code coverage files for the test run, 
named dependant on the version of powershell running:

    powershell - powershell 5.1
    pwsh - powershell core

.EXAMPLE 
Invoke-UnitTests.ps1

#>

[CmdletBinding()]
param ()

try {
    $pesterModule = Get-Module -Name Pester -ListAvailable | Where-Object { $_.Version -like '5.*' }
    if (!$pesterModule) {
        try {
            Write-Host "Installing Pester"
            Install-Module -Name Pester -Force -SkipPublisherCheck -MinimumVersion "5.0.0"
            Write-Host "Getting Pester version"
            $pesterModule = Get-Module -Name Pester -ListAvailable | Where-Object { $_.Version -like '5.*' }
        }
        catch {
            Write-Error "Failed to install the Pester module."
        }
    }

    $pesterModule | Import-Module



    $pathToTests = "$PSScriptRoot\powershell5_1"
    $pathToScripts = "$PSScriptRoot\..\PSScripts\*.ps1"
    $powerShellEdition = "powershell"

    if ($PSVersionTable.PSVersion.Major -gt 5) {
        $pathToTests = "$PSScriptRoot\powershellcore"
        $pathToScripts = "$PSScriptRoot\..\PSCoreScripts\*.ps1"
        $powerShellEdition = "pwsh"

        # Powershell Core 6 wipes this, losing the path to all modules...
        $env:PSModulePath = "C:\Program Files\PowerShell\Modules;c:\program files\powershell\6\Modules;C:\windows\system32\WindowsPowerShell\v1.0\Modules;C:\Modules\az_2.6.0"
    }


    $fullPathToScripts = Resolve-Path -Path $pathToScripts

    $testResult = "$PSScriptRoot\TEST-$powerShellEdition.xml"
    $codeCoverageResult = "$PSScriptRoot\CODECOVERAGE-$powerShellEdition.xml"



    # Write-Host "Fetching tests:"
    $Tests = (Get-ChildItem -Path "$pathToTests" -Recurse | Where-Object { $_.Name -like "*.Tests.ps1" }).FullName

    $Params = [ordered]@{
        Path = $Tests;
    }

    $Container = New-PesterContainer @Params

    $Configuration = [PesterConfiguration]@{
        Run        = @{
            Container = $Container
        }
        Output     = @{
            Verbosity = 'Detailed'
        }
        Filter     = @{
            Tag = 'Unit'
            ExcludeTag = 'DontRun'
        }
        TestResult = @{
            Enabled      = $true
            OutputFormat = "NUnitXml"
            OutputPath   = $testResult
        }
        Should     = @{
            ErrorAction = 'Continue'
        }
        CodeCoverage = @{
            Enabled = $true
            Path         = $fullPathToScripts
            OutputFormat = "JaCoCo"
            OutputPath   =  $codeCoverageResult
        }
    }

    # Invoke tests
    $Result = Invoke-Pester -Configuration $Configuration

    # report failures
    if ($Result.FailedCount -gt 0) { 
        throw "{0} tests did not pass" -f $Result.FailedCount
    }
}
catch {
    $msg = $_
    Write-Error -ErrorRecord $msg
    exit 1
}