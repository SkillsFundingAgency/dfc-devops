<#
.SYNOPSIS
Displays the results of the test runner

.DESCRIPTION
Displays a summary of results from the test runner and fails if a threshold is not met

.PARAMETER TestResultFile
[Optional] Path to the test results file. Will use the latest file called TEST-xxx.XML if not passed

.PARAMETER CodeCoverageFile
[Optional] Path to the test results file. Will use the latest file called CODECOVERAGE-xxx.XML if not passed

.PARAMETER CoveragePercent
[Optional] Minimum code coverage percentage to pass. Defaults to 80

.EXAMPLE
Out-TestResults.ps1

#>

[CmdletBinding()]
Param (
    [Parameter(Mandatory = $false)]
    [String] $TestResultFile,
    [Parameter(Mandatory = $false)]
    [String] $CodeCoverageFile,
    [Parameter(Mandatory = $false)]
    [int] $CoveragePercent = 80
)

if (-not $TestResultFile) {
    $findfile = Get-ChildItem "$PSScriptRoot\TEST-*.xml" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    $TestResultFile = $findfile.FullName
}
[xml] $TestResult = Get-Content -Path $TestResultFile

if (-not $CodeCoverageFile) {
    $findfile = Get-ChildItem "$PSScriptRoot\CODECOVERAGE-*.xml" |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    $CodeCoverageFile = $findfile.FullName
}
[xml] $CodeCoverage = Get-Content -Path $CodeCoverageFile

$failures = select-xml "//test-results/test-suite[@success='False']" $TestResult
if ($failures) {
    $fails = 0
    $failures | ForEach-Object {
        Select-Xml "//failure" $_.node.results | ForEach-Object {
            $fails += 1
            Write-Output "Failure: $fails"
            Write-Output $_.node.message
        }
    }
    Write-Error "Pester reported $fails error(s)"
}

$total = 0
$covered = 0
select-xml "//report/counter" $CodeCoverage | ForEach-Object {
    $total += [int] $_.Node.missed + [int] $_.node.covered
    $covered += [int] $_.node.covered
}

$codecovered = $covered / $total * 100
if ($codecovered -lt $CoveragePercent) {
    Write-Error "Code coverage $codecovered"
}
