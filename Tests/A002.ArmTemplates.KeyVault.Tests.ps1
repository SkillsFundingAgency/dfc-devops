# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\ArmTemplates\keyvault.json"

Describe "Key Vault Deployment Tests" -Tag "Acceptance" {
  
    Context "When KeyVault deployed with just key vault name" {
      $params = @{ keyVaultName = "dfc-foo-bar-kv" }

      $output = Test-AzureRmResourceGroupDeployment `
                  -ResourceGroupName $ResourceGroupName `
                  -TemplateFile $TemplateFile `
                  -TemplateParameterObject $params
  
      It "Should be deployed successfully" {
        $output | Should -Be $null
        if ($output) {
          # return some useful info to the user
          Write-Debug $output
        }
      }
  
      <#
      It "Should return" {
        $resource = $result.validatedResources[0]
  
        $resource.name | Should -Be ?
      }
      #>

    }
}