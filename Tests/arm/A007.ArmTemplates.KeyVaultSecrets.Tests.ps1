Describe "Key Vault Secrets Deployment Tests" -Tag "Acceptance" {

  BeforeAll {
    # common variables
    $ResourceGroupName = "dfc-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\KeyVault\keyvault-secrets.json"
  }

  Context "When a single key vault secret added" {

    BeforeAll{
      $TemplateParameters = @{
        keyVaultName = "dfc-foo-bar-kv"
        secrets      = [Newtonsoft.Json.JsonConvert]::DeserializeObject('[{ "name": "foo", "secret": "bar", "type": "" }]')
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

  Context "When a multiple secrets added" {
    BeforeAll{
      $TemplateParameters = @{
        keyVaultName = "dfc-foo-bar-kv"
        secrets      = [Newtonsoft.Json.JsonConvert]::DeserializeObject('[{ "name": "foo", "secret": "bar", "type": "" },
                        { "name": "foo2", "secret": "another secret", "type": "text/plain" }]')
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