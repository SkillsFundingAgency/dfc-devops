<#
.SYNOPSIS
Tests an ARM template file

.DESCRIPTION
Tests a ARM template file to make sure it should deploy.

.PARAMETER ParameterFile
Parameter file with manditory and optional parameters to test with.
Normally contains dummy values unless it is a dependancy in which case a valid value is needed.

.PARAMETER TemplateFile
The template file to test

.PARAMETER ResourceGroupName
The name of the resource group to test the ARM template against.  Defaults to dfc-test-template-rg

.EXAMPLE
Test-ArmTemplate.ps1 -ParameterFile paramaters.json -TemplateFile template.json

#>
[CmdletBinding()]
Param(
    [string] $ParameterFile,
    [string] $TemplateFile,
    [string] $ResourceGroupName = "dfc-test-template-rg"
)

$DeploymentParameters = @{
    ResourceGroupName     = $ResourceGroupName
    TemplateFile          = $TemplateFile
    TemplateParameterFile = $ParameterFile
    Verbose               = $true
}

Write-Host "- Validating template"
if ($PSCmdlet.MyInvocation.BoundParameters["Verbose"].IsPresent) {

    Write-Verbose -Message "Deployment Parameters:"
    $DeploymentParameters

}
$Result = Test-AzureRmResourceGroupDeployment @DeploymentParameters
if ($Result.Count -gt 0) {

    $Result
    throw "Template is invalid"

}