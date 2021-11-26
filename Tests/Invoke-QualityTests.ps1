<#
.SYNOPSIS
Test runner for code quality tests

.DESCRIPTION
Test runner for code quality tests

.EXAMPLE
Invoke-QualityTests.ps1

.EXAMPLE
Invoke-QualityTests.ps1

#>

[CmdletBinding()]
param()

$pesterModule = Get-Module -Name Pester -ListAvailable | Where-Object {$_.Version -like '5.*'}
if (!$pesterModule) {
    try {
        Write-Host "Installing Pester"
        Install-Module -Name Pester -Force -SkipPublisherCheck -MinimumVersion "5.0.0"
        Write-Host "Getting Pester version"
        $pesterModule = Get-Module -Name Pester -ListAvailable | Where-Object {$_.Version -like '5.*'}
    }
    catch {
        Write-Error "Failed to install the Pester module."
    }
}

$pesterModule | Import-Module


# Write-Host "Fetching tests:"
$Tests = (Get-ChildItem -Path "$($PSScriptRoot)\Quality" -Recurse | Where-Object {$_.Name -like "*.Tests.ps1"}).FullName

$Params = [ordered]@{
    Path = $Tests;
}

$Container = New-PesterContainer @Params

$Configuration = [PesterConfiguration]@{
    Run          = @{
        Container = $Container
    }
    Output       = @{
        Verbosity = 'Diagnostic'
    }
    Filter = @{
        Tag = 'Quality'
    }
    TestResult   = @{
        Enabled      = $true
        OutputFormat = "NUnitXml"
        OutputPath   = "$PSScriptRoot\TEST-Quality.xml"
    }
    Should = @{
        ErrorAction = 'Continue'
    }
}

# Invoke tests
$Result = Invoke-Pester -Configuration $Configuration

# report failures
if ($Result.FailedCount -ne 0) { 
    Write-Error "Pester returned $($result.FailedCount) errors"
}