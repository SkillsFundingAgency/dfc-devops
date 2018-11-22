# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\ArmTemplates\keyvault.json"

Describe "Key Vault Deployment Tests" -Tag "Acceptance" {

    BeforeAll {
      $DebugPreference = "Continue"
    }
  
    AfterAll {
      $DebugPreference = "SilentlyContinue"
    }
  
    Context "When KeyVault deployed with parameters" {
      $params = @{ keyVaultName = "dfc-foo-bar-kv" }
      $output = Test-AzureRmResourceGroupDeployment `
                  -ResourceGroupName $ResourceGroupName `
                  -TemplateFile $TemplateFile `
                  -TemplateParameterObject $params `
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