$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\ArmTemplates\keyvault.json"
$params = @{ keyVaultName = "dfc-foo-bar-kv" }

$output = Test-AzureRmResourceGroupDeployment `
              -ResourceGroupName $ResourceGroupName `
              -TemplateFile $TemplateFile `
              -TemplateParameterObject $params `
              -ErrorAction Stop `
              5>&1

Write-Output $output

Write-Output ($output | Get-Member)

if ($output) {
    Write-Output "$$output is true"
}