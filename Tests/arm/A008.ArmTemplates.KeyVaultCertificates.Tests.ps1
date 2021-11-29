Describe "Key Vault Certificates Deployment Tests" -Tag "Acceptance" {

  BeforeAll {
    # common variables
    $ResourceGroupName = "dfc-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\KeyVault\keyvault-certificates.json"
  }
  
  Context "When a single certificate from the key vault is created" {

    BeforeAll {
      $TemplateParameters = @{
        keyVaultName = "dfc-foo-bar-kv"
        certificates = @( "foo.example.com" )
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

  Context "When a multiple certificates from the key vault are created" {

    BeforeAll {
      $TemplateParameters = @{
        keyVaultName = "dfc-foo-bar-kv"
        certificates = @( "foo.example.com" , "bar.example.com" )
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