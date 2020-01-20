<#
.SYNOPSIS
Test runner for ARM acceptance tests

.DESCRIPTION
Test runner for ARM acceptance tests

.EXAMPLE
Invoke-AcceptanceTests.ps1

.EXAMPLE
Invoke-AcceptanceTests.ps1


#>

[CmdletBinding()]

$TestParameters = @{
    OutputFormat = 'NUnitXml'
    OutputFile   = "$PSScriptRoot\TEST-Acceptance.xml"
    Script       = "$PSScriptRoot\arm"
    PassThru     = $True
    Tag          = "Acceptance"
}

# Invoke tests
$Result = Invoke-Pester @TestParameters

# report failures
if ($Result.FailedCount -ne 0) { 
    Write-Error "Pester returned $($result.FailedCount) errors"
}