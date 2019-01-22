# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\ArmTemplates\keyvault.json"

Describe "Key Vault Secrets Deployment Tests" -Tag "Acceptance" {
  
  Context "When a single key vault secret added" {
    $TemplateParameters = @{
      keyVaultName = "dfc-foo-bar-kv"
      secrets      = @( @{ 
        name   = "foo"
        secret = "bar"
        type   = ""
      } )
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

  Context "When a multiple secrets added" {
    $TemplateParameters = @{
      keyVaultName = "dfc-foo-bar-kv"
      secrets      = @( @{ 
        name   = "foo"
        secret = "bar"
        type   = ""
      }, @{
        name   = "foo2"
        secret = "bar2"
        type   = "text/plain"
      } )
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