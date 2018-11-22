Push-Location -Path $PSScriptRoot\..\PSScripts\

Mock Test-AzureRmResourceGroupDeployment

Describe "Test-ARMTemplate acceptance tests" -Tag "Acceptance" {

    It "Should call Test-AzureRmResourceGroupDeployment" {
        .\Test-ARMTemplate -TemplateFile template.json -ParameterFile parameters.json
        Assert-MockCalled Test-AzureRmResourceGroupDeployment  #-Exactly 1
    }
}