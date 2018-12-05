# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\ArmTemplates\azure-search.json"

Describe "Azure Search Deployment Tests" -Tag "Acceptance" {
  
  Context "When Azure Search is deployed with just search name" {
    $TemplateParameters = @{
      azureSearchName = "dfc-foo-bar-sch"
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