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
      try {
        $output = Test-AzureRmResourceGroupDeployment `
                  -ResourceGroupName $ResourceGroupName `
                  -TemplateFile $TemplateFile `
                  -TemplateParameterObject $params `
                  -ErrorAction Stop #`
                  #5>&1
      } catch {
        $ex = $_.Exception
      }
      #$result = (($output[32] -split "Body:")[1] | ConvertFrom-Json).properties
  
      It "Should be deployed successfully" {
        $ex | Should -Be $null
      }
  
      <#
      It "Should return" {
        $resource = $result.validatedResources[0]
  
        $resource.name | Should -Be ?
      }
      #>

    }
}