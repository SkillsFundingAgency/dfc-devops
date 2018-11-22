Push-Location -Path $PSScriptRoot\..\PSScripts\

Describe "Test-ARMTemplate acceptance tests" -Tag "Acceptance" {
    Mock Test-AzureRmResourceGroupDeployment

    It "Should call Test-AzureRmResourceGroupDeployment" {
        .\Test-ARMTemplate -TemplateFile template.json -ParameterFile parameters.json
        Assert-MockCalled Test-AzureRmResourceGroupDeployment -Exactly 1
    }
}