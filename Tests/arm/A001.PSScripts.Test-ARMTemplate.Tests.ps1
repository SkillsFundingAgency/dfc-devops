Push-Location -Path $PSScriptRoot\..\..\PSScripts\

Describe "Test-ARMTemplate acceptance tests" -Tag "Acceptance" {

    It "Should call Test-AzureRmResourceGroupDeployment" {
        Mock Test-AzureRmResourceGroupDeployment

        .\Test-ARMTemplate -TemplateFile template.json -ParameterFile parameters.json

        Should -Invoke -CommandName Test-AzureRmResourceGroupDeployment  -Exactly 1
    }
}