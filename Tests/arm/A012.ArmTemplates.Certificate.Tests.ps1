# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\certificate.json"

Describe "Certificate Deployment Tests" -Tag "Acceptance" {
  
  Context "When a single certificate from the key vault is created" {
    $TemplateParameters = @{
      keyVaultName            = "dfc-foo-bar-kv"
      keyVaultCertificateName = "foo.example.com"
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