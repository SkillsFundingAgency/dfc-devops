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


$pathToTests = "$PSScriptRoot\powershell5_1"
$pathToScripts = "$PSScriptRoot\..\PSScripts\*.ps1"
$powerShellEdition = "powershell"

if($PSVersionTable.PSVersion.Major -gt 5) {
    $pathToTests = "$PSScriptRoot\powershellcore"
    $pathToScripts = "$PSScriptRoot\..\PSCoreScripts\*.ps1"
    $powerShellEdition = "pwsh"

    # Powershell Core 6 wipes this, losing the path to all modules...
    $env:PSModulePath = "C:\Program Files\PowerShell\Modules;c:\program files\powershell\6\Modules;C:\windows\system32\WindowsPowerShell\v1.0\Modules;C:\Modules\az_2.6.0"
}


$fullPathToScripts = Resolve-Path -Path $pathToScripts

$testResult = "$PSScriptRoot\TEST-$powerShellEdition.xml"
$codeCoverageResult = "$PSScriptRoot\CODECOVERAGE-$powerShellEdition.xml"

$TestParameters = @{
    OutputFormat = 'NUnitXml'
    OutputFile   = $testResult
    Script       = $pathToTests
    PassThru     = $True
    CodeCoverage = $fullPathToScripts
    CodeCoverageOutputFile = $codeCoverageResult
}

# Invoke tests
$Result = Invoke-Pester @TestParameters

# report failures
if ($Result.FailedCount -ne 0) { 
    Write-Error "Pester returned $($result.FailedCount) errors"
}
