# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\KeyVault\keyvault-certificates.json"

Describe "Key Vault Certificates Deployment Tests" -Tag "Acceptance" {
  
  Context "When a single certificate from the key vault is created" {
    $TemplateParameters = @{
      keyVaultName = "dfc-foo-bar-kv"
      certificates = @( "foo.example.com" )
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

  Context "When a multiple certificates from the key vault are created" {
    $TemplateParameters = @{
      keyVaultName = "dfc-foo-bar-kv"
      certificates = @( "foo.example.com" , "bar.example.com" )
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