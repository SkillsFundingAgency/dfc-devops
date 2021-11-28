Describe "Certificate Deployment Tests" -Tag "Acceptance" {

  BeforeAll {
    # common variables
    $ResourceGroupName = "dfc-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\certificate.json"
  }
  
  Context "When a single certificate from the key vault is created" {

    BeforeAll {
      $TemplateParameters = @{
        keyVaultName            = "dfc-foo-bar-kv"
        keyVaultCertificateName = "foo.example.com"
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