# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\ArmTemplates\app-service.json"

Describe "App Service Deployment Tests" -Tag "Acceptance" {
  
  Context "When app service is deployed with just name and ASP" {
    $TemplateParameters = @{
      appServiceName     = "dfc-foo-bar-as"
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