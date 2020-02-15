###########################################################################################
##                                    WARNING                                            ##
## This script is for backwards compatibility.                                           ##
## Please make any changes to the version of this script in the PSCoreScripts folder     ##
###########################################################################################


<#
.SYNOPSIS
Tests the current branch for build features

.DESCRIPTION
Determine which build features that a build could run.

.EXAMPLE
Test-BuildFeatures.ps1

#>

[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSProvideCommentHelp', '', Scope='Function', Target='Test-IfNotFeatureBranch')]
[System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSProvideCommentDescription', '', Scope='Function', Target='Test-IfNotFeatureBranch')]
param()

function Test-IfNotFeatureBranch {
    param(
        [Parameter(Mandatory=$true)]
        [string] $BranchName,
        [string] $BuildReason

    )
    $shouldRunSonarCloud  = $false

    if($BranchName -match  '^(v[0-9]+-)?(master|dev)(-v[0-9]+)?$') { $shouldRunSonarCloud = $true }

    if($BuildReason -eq "PullRequest") { $shouldRunSonarCloud = $true }

    Write-Output "##vso[task.setvariable variable=ShouldRunSonarCloud]$($shouldRunSonarCloud)"
}

$branchName = $env:Build_SourceBranchName
$buildReason = $env:Build_Reason

Test-IfNotFeatureBranch -BranchName $branchName -BuildReason $buildReason