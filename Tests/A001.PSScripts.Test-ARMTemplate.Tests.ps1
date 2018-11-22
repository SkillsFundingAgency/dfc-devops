Push-Location -Path $PSScriptRoot\..\PSScripts\


Describe "Test-ARMTemplate acceptance tests" -Tag "Acceptance" {
  
    It "Should call Test-AzureRmResourceGroupDeployment" {
        #Mock Test-AzureRmResourceGroupDeployment -ParameterFilter { $ResourceGroupName -and $TemplateFile -and $TemplateParameterFile } -MockWith { return $null }
        #.\Test-ARMTemplate -TemplateFile template.json -ParameterFile parameters.json
        #Assert-MockCalled Test-AzureRmResourceGroupDeployment  -Exactly 1
    }

}