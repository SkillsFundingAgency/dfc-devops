<#
.SYNOPSIS
Runner to invoke Acceptance, Quality and / or Unit tests

.DESCRIPTION
Test wrapper that invokes

.PARAMETER TestType
[Optional] The type of test that will be executed. The parameter value can be either All (default), Acceptance, Quality or Unit

.EXAMPLE
Invoke-AcceptanceTests.ps1

.EXAMPLE
Invoke-AcceptanceTests.ps1 -TestType Quality

#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [ValidateSet("All", "Acceptance", "Quality", "Unit")]
    [String] $TestType = "All",
    [Parameter(Mandatory = $false)]
    [String] $CodeCoveragePath
)

$TestParameters = @{
    OutputFormat = 'NUnitXml'
    OutputFile   = "$PSScriptRoot\TEST-$TestType.xml"
    Script       = "$PSScriptRoot"
    PassThru     = $True
}
if ($TestType -ne 'All') {
    $TestParameters['Tag'] = $TestType
}
if ($CodeCoveragePath) {
    $TestParameters['CodeCoverage'] = $CodeCoveragePath
    $TestParameters['CodeCoverageOutputFile'] = "$PSScriptRoot\CODECOVERAGE-$TestType.xml"
}

# Remove previous runs
Remove-Item "$PSScriptRoot\TEST-*.xml"
Remove-Item "$PSScriptRoot\CODECOVERAGE-*.xml"

# Invoke tests
$Result = Invoke-Pester @TestParameters

# report failures
if ($Result.FailedCount -ne 0) { 
    Write-Error "Pester returned $($result.FailedCount) errors"
}