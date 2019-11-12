<#
    .SYNOPSIS
    Get a function app name and version from it's source branch

    .DESCRIPTION
    Gets the function app name and version from it's branch name and it's base name

    .EXAMPLE
    Get-VersionedFunctionAppName.ps1 -BranchName someBranch -FunctionBaseName some-function-app

    .PARAMETER BranchName
    The name of a branch

    .PARAMETER FunctionAppBaseName
    The function app name minus the version, eg dss-at-cust-fa rather than dss-at-cust-v2-fa
#>
[CmdletBinding()]
param()

function Write-AzureDevopsVariable {
    <#
        .SYNOPSIS
        Writes a string representing azure devops variable to the output

        .EXAMPLE
        Write-AzureDevopsVariable -Name SomeVariable -Value SomeValue

        .PARAMETER Name
        The name of the variable

        .PARAMETER Value
        The value of the variable

        .PARAMETER IsOuput
        Determines if the value should be propogated to other tasks steps.
        Optional, defaults to false.
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string] $Name,
        [Parameter(Mandatory=$true)]
        [string] $Value,
        [bool] $IsOutput = $false
    )

    $lowerCaseOutputValue = ([string] $IsOutput).ToLower()

    Write-Output "##vso[task.setvariable variable=$Name;isOutput=$lowerCaseOutputValue]$Value"
}


function Get-FunctionVersionFromBranch {
    <#
        .SYNOPSIS
        Get the version of a function from it's branch name

        .EXAMPLE
        Get-VersionedFunctionAppNameFromBranch -BranchName someBranch

        .PARAMETER BranchName
        The name of a branch
    #>

    param(
        [Parameter(Mandatory=$true)]
        [string] $BranchName
    )

    if($BranchName -iin @("dev", "master"))  {
        $branchVersion = "v1"
    } else {
        if($BranchName -match '^(?:(v[0-9]+)-)?(?:master|dev)(?:-(v[0-9]+))?$') {
            if($null -ne $Matches[1]) {
                $branchVersion = $Matches[1]
            } else {
                $branchVersion = $Matches[2]
            }
        } else {
            throw "Unknown branch version for branch '$BranchName'"
        }
    }

    return $branchVersion
}


function Get-FunctionAppName {
    <#
        .SYNOPSIS
        Get the full name of a function from it's branch name and base name

        .EXAMPLE
        Get-FunctionAppName -FunctionAppBaseName dfc-dev-func-fa -FunctionAppVersion v2

        .PARAMETER FunctionAppBaseName
        The base name of the function. Must be in the form dfc-<env>-<what>-fa

        .PARAMETER FunctionAppVersion
        The version of the app. Must be in the form v<Number> - ie: v1
    #>
    param(
        [Parameter(Mandatory=$true)]
        [string] $FunctionAppBaseName,
        [Parameter(Mandatory=$true)]
        [string] $FunctionAppVersion
    )

    if(-not $FunctionAppBaseName.EndsWith(("-fa"))) {
        throw "Warning: FunctionAppBaseName does not end with -fa, as expected."
    }

    $nameWithoutSuffix = $FunctionAppBaseName.Substring(0, $FunctionAppBaseName.Length -3)

    $versionedName = ($nameWithoutSuffix, $FunctionAppVersion, "fa") -join "-"

    return $versionedName
}

$branchName = $env:Build_SourceBranchName
$functionAppBaseName = $env:FunctionAppBaseName

$apiVersion = Get-FunctionVersionFromBranch -BranchName $branchName
Write-AzureDevopsVariable -Name ApiVersion -Value $apiVersion

$functionAppName = Get-FunctionAppName -FunctionAppBaseName $functionAppBaseName -FunctionAppVersion $apiVersion
Write-AzureDevopsVariable -Name FunctionAppName -Value $functionAppName