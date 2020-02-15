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

$TestParameters = @{
    OutputFormat = 'NUnitXml'
    OutputFile   = "$PSScriptRoot\TEST-Quality.xml"
    Script       = "$PSScriptRoot\Quality"
    PassThru     = $True
    Tag          = "Quality"
}

# Invoke tests
$Result = Invoke-Pester @TestParameters

# report failures
if ($Result.FailedCount -ne 0) { 
    Write-Error "Pester returned $($result.FailedCount) errors"
}