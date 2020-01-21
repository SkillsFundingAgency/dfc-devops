# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\cognitive-services.json"

Describe "Cognitive Services account Tests" -Tag "Acceptance" {
  
  Context "When a Spellcheck Cognitive Services account is deployed" {

    $TemplateParameters = @{
      cognitiveServiceName = "dfc-foo-bar-cog-01"
      cognitiveServiceType = "Bing.SpellCheck.v7" # global location
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

  Context "When a Facial Recognition Cognitive Services account is deployed" {
    
    $TemplateParameters = @{
      cognitiveServiceName = "dfc-foo-bar-cog-02"
      cognitiveServiceType = "Face" # local location
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