# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\ArmTemplates\SqlServer\sql-database.json"
$TemplateParametersDefault = @{
    databaseName = "dfc-foo-bar-db"
    sqlServerName = "dfc-foo-bar-sql"
}

Describe "Sql Database Deployment Tests" -Tag "Acceptance" {
  
    Context "When SQL Database is deployed with just databaseName and sqlServerName" {

        $TemplateParameters = $TemplateParametersDefault
        $TestTemplateParams = @{
            ResourceGroupName       = $ResourceGroupName
            TemplateFile            = $TemplateFile
            TemplateParameterObject = $TemplateParameters
        }

        $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams

        It "Should be deployed successfully" {
            $output | Should -Be $null
        }

    }

}