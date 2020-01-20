# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\SqlServer\sql-database.json"
$TemplateParametersDefault = @{
    databaseName = "dfc-foo-bar-db"
    sqlServerName = "dfc-foo-bar-sql"
}

Describe "Sql Database Deployment Tests" -Tag "Acceptance" {
  
    Context "When SQL Database is deployed with databaseName, sqlServerName" {

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

    Context "When SQL Database is deployed with databaseName, sqlServerName and databaseTier of Basic" {

        $TemplateParameters = $TemplateParametersDefault
        $TemplateParameters['databaseTier'] = "Basic"
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

    Context "When SQL Database is deployed with databaseName, sqlServerName and databaseTier of Standard and a databaseSize of 2" {

        $TemplateParameters = $TemplateParametersDefault
        $TemplateParameters['databaseTier'] = "Standard"
        $TemplateParameters['databaseSize'] = "2"
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