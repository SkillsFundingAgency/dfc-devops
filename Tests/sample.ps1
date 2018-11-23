$TemplateParameters = @{
    sqlServerName   = "dfc-foo-bar-sql"
    elasticPoolName    = $null
    elasticPoolEdition = $null
    elasticPoolTotalDTU = $null
    elasticPoolMinDTU   = $null
    elasticPoolStorage  = $null
}
$TestTemplateParams = @{
    ResourceGroupName       = "dfc-test-template-rg"
    TemplateFile            = "$PSScriptRoot\..\ArmTemplates\sqlserver-elasticpool.json"
    TemplateParameterObject = $TemplateParameters
}

$output = Test-AzureRmResourceGroupDeployment @TestTemplateParams

if ($output) {
    Write-Output $output
}