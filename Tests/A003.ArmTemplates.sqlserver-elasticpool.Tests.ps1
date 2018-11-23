# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\ArmTemplates\sqlserver-elasticpool.json"

<#
            elasticPoolName    = $null
            elasticPoolEdition = $null
            elasticPoolTotalDTU = $null
            elasticPoolMinDTU   = $null
            elasticPoolStorage  = $null
#>

Describe "SQL Server Deployment Tests" -Tag "Acceptance" {
  
    Context "When SQL Server deployed with just SQL server name" {
        $TemplateParameters = @{
            sqlServerName   = "dfc-foo-bar-sql"
        }
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

    Context "When SQL Server deployed with just SQL server and elastic pool name" {
        $TemplateParameters = @{
            sqlServerName   = "dfc-foo-bar-sql"
            elasticPoolName = "dfc-foo-bar-epl"
        }
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