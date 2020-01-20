# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\app-service-plan.json"

Describe "App Service Plan Deployment Tests" -Tag "Acceptance" {
  
  Context "When an app service plan is deployed with just name" {
    $TemplateParameters = @{
      appServicePlanName = "dfc-foo-bar-asp"
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