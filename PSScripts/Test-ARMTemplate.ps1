<#
.SYNOPSIS
Tests an ARM template file

.DESCRIPTION
Tests a ARM template file to make sure it should deploy.

.PARAMETER TemplateFile
The template file to test

.PARAMETER ParameterFile
Parameter file with manditory and optional parameters to test with.
Normally contains dummy values unless it is a dependancy in which case a valid value is needed.

.EXAMPLE
Test-ARMTemplate.ps1 -TemplateFile template.json -ParameterFile paramaters.json

#>

Param(
  [string] $TemplateFile,
  [string] $ParameterFile
)

# common variables
$ResourceGroupName = "dfc-test-template-rg"

Test-AzureRmResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -TemplateParameterFile $ParameterFile
