# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\ArmTemplates\keyvault.json"

Describe "Key Vault Deployment Tests" -Tag "Acceptance" {
  
    Context "When KeyVault deployed with just key vault name" {
      $params = @{ keyVaultName = "dfc-foo-bar-kv" }

      try {
        $output = Test-AzureRmResourceGroupDeployment `
                  -ResourceGroupName $ResourceGroupName `
                  -TemplateFile $TemplateFile `
                  -TemplateParameterObject $params
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