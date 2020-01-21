# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\redis.json"

Describe "Redis Cache Deployment Tests" -Tag "Acceptance" {
  
  Context "When a Redis Cache is deployed with just a name" {
    $TemplateParameters = @{
      redisName = "dfc-foo-bar-rds"
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