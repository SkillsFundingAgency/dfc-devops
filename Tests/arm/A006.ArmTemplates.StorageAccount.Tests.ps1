Describe "Storage Account Deployment Tests" -Tag "Acceptance" {

  BeforeAll {
    # common variables
    $ResourceGroupName = "dfc-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\storage-account.json"
  }

  Context "When a storage account deployed with just name" {
    BeforeAll {
      $TemplateParameters = @{
        storageAccountName = "dfcfoobar787str"
      }
      $TestTemplateParams = @{
        ResourceGroupName       = $ResourceGroupName
        TemplateFile            = $TemplateFile
        TemplateParameterObject = $TemplateParameters
      }
    }
    It "Should be deployed successfully" {
      $output = Test-AzResourceGroupDeployment @TestTemplateParams
      $output | Should -Be $null
    }
  }
}