
Describe "App Service Deployment Tests" -Tag "Acceptance" {

  BeforeAll {
    # common variables
    $ResourceGroupName = "dfc-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\app-service.json"

  }
  
  Context "When app service is deployed with just name and ASP" {

    BeforeAll {
      $TemplateParameters = @{
        appServiceName     = "dfc-foo-bar-as"
        appServicePlanName = "dfc-test-template-asp"
      }
      $TestTemplateParams = @{
        ResourceGroupName       = $ResourceGroupName
        TemplateFile            = $TemplateFile
        TemplateParameterObject = $TemplateParameters
      }
    }

  
    It "Should be deployed successfully" {
      $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams
      $output | Should -Be $null
    }

  }

  Context "When app service is deployed as a function app" {

    BeforeAll {
      $TemplateParameters = @{
        appServiceName     = "dfc-foo-bar-fa"
        appServicePlanName = "dfc-test-template-asp"
        appServiceType     = "functionapp"
      }
      $TestTemplateParams = @{
        ResourceGroupName       = $ResourceGroupName
        TemplateFile            = $TemplateFile
        TemplateParameterObject = $TemplateParameters
      }
    }

  
    It "Should be deployed successfully" {
      $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams
      $output | Should -Be $null
    }

  }

}