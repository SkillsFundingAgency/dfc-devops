# common variables

Describe "Key Vault Deployment Tests" -Tag "Acceptance" {

  BeforeAll {
    $ResourceGroupName = "dfc-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\keyvault.json"

  }

  Context "When KeyVault deployed with just key vault name" {
    BeforeAll {
      $TemplateParameters = @{
        keyVaultName = "dfc-foo-bar-kv"
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