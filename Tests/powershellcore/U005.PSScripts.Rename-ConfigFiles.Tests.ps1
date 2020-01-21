Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "ConvertTo-VSTSVariables unit tests" -Tag "Unit" {

    It "Should return a string correctly" {
        Set-Content -Path (Join-Path -Path $TestDrive -ChildPath "test.config.template") -Value "Test file"

        .\Rename-ConfigFiles -RootPath $TestDrive

        (Get-ChildItem $TestDrive).Name | Should be "test.config"
    }

}

Push-Location -Path $PSScriptRoot