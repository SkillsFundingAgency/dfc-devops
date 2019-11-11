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
        [string] $BranchName
    )
    $shouldRunSonarCloud  = $false

    if($BranchName -match  '^(v[0-9]+-)?(master|dev)(-v[0-9]+)?$') { $shouldRunSonarCloud = $true }

    Write-Output "##vso[task.setvariable variable=ShouldRunSonarCloud]$($shouldRunSonarCloud)"
}


$branchName = $env:Build_SourceBranchName
Test-IfNotFeatureBranch -BranchName $branchName