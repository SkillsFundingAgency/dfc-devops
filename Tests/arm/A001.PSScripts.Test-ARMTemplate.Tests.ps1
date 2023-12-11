Push-Location -Path $PSScriptRoot\..\..\PSScripts\

Describe "Test-ARMTemplate acceptance tests" -Tag "Acceptance" {

    It "Should call Test-AzResourceGroupDeployment" {
        Mock Test-AzResourceGroupDeployment

        .\Test-ARMTemplate -TemplateFile template.json -ParameterFile parameters.json

        Should -Invoke -CommandName Test-AzResourceGroupDeployment  -Exactly 1
    }
}