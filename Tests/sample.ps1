$TemplateParameters = @{
    sqlServerName   = "dfc-foo-bar-sql"
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