<#
.SYNOPSIS
Test runner for ARM acceptance tests

.DESCRIPTION
Test runner for ARM acceptance tests

.EXAMPLE
Invoke-QualityTests.ps1

.EXAMPLE
Invoke-QualityTests.ps1

#>

[CmdletBinding()]
param()

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


    # Write-Host "Fetching tests:"
    $Tests = (Get-ChildItem -Path "$($PSScriptRoot)\arm" -Recurse | Where-Object { $_.Name -like "*.Tests.ps1" }).FullName

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
            Tag = 'Acceptance'
            ExcludeTag = 'DontRun'
        }
        TestResult = @{
            Enabled      = $true
            OutputFormat = "NUnitXml"
            OutputPath   = "$PSScriptRoot\TEST-Acceptance.xml"
        }
        Should     = @{
            ErrorAction = 'Continue'
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