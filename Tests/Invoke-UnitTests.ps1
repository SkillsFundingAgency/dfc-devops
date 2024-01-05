<#
.SYNOPSIS
Test Runner to run powershell Unit tests

.DESCRIPTION
Test Runner to run powershell Unit tests..

It will output unit and code coverage files for the test run.

.EXAMPLE 
Invoke-UnitTests.ps1

#>

[CmdletBinding()]
param ()

try {
    $pesterModule = Get-Module -Name Pester -ListAvailable | Where-Object { $_.Version -like '5.*' }
    if (!$pesterModule) {
        Write-Error "Unable to find Pester v5.x"
        exit 1
    }

    $pesterModule | Select-Object -First 1 | Import-Module

    $tests = @(
        "PSScripts"
        "PSCoreScripts"
    )

    foreach($test in $tests) {
        $pathToTests = "$PSScriptRoot\$test"
        $pathToScripts = "$PSScriptRoot\..\$test\*.ps1"

        $fullPathToScripts = Resolve-Path -Path $pathToScripts

        $testResult = "$PSScriptRoot\TEST-$test.xml"
        $codeCoverageResult = "$PSScriptRoot\CODECOVERAGE-$test.xml"

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
}
catch {
    $msg = $_
    Write-Error -ErrorRecord $msg
    exit 1
}