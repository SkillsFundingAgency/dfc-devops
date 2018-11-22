# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "..\ArmTemplates\keyvault.json"

Describe "Key Vault Deployment Tests" { #-Tag "Acceptance" {

    BeforeAll {
      $DebugPreference = "Continue"
    }
  
    AfterAll {
      $DebugPreference = "SilentlyContinue"
    }
  
    Context "When KeyVault deployed with parameters" {
      $output = Test-AzureRmResourceGroupDeployment `
                  -ResourceGroupName $ResourceGroupName `
                  -TemplateFile $TemplateFile `
                  -keyVaultName "dfc-foo-bar-kv" `
                  -ErrorAction Stop `
                  5>&1
      $result = (($output[32] -split "Body:")[1] | ConvertFrom-Json).properties
  
      It "Should be deployed successfully" {
        $result.provisioningState | Should -Be "Succeeded"
      }
  
      <#
      It "Should return" {
        $resource = $result.validatedResources[0]
  
        $resource.name | Should -Be ?
      }
      #>

    }
  }