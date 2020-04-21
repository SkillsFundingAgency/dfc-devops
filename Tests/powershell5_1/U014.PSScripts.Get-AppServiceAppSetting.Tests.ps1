Push-Location -Path $PSScriptRoot\..\..\PSScripts\

# solves CommandNotFoundException
function Get-AzureRmWebApp {}

Describe "Get-AppServiceAppSetting unit tests" -Tag "Unit" {

    Mock Get-AzureRmWebApp {
        $mockapp = '{ "SiteConfig": { "AppSettings": [ { "name": "foo", "value": "bar"}, { "name": "this", "value": "that" } ] } }'
        return ConvertFrom-Json $mockapp
    }

    It "Should error app setting does not exist" {

        Mock Write-Error

        .\Get-AppServiceAppSetting -ResourceGroupName dfc-foo-bar-rg -AppServiceName dfc-foo-bar-as -AppSetting notasetting

        Assert-MockCalled Write-Error

    }

    It "Should run Invoke-Sqlcmd with inputfile when valid script is passed" {

        $expected = @('##vso[task.setvariable variable=foo]bar')

        $output = .\Get-AppServiceAppSetting -ResourceGroupName dfc-foo-bar-rg -AppServiceName dfc-foo-bar-as -AppSetting foo

        $output | Should be $expected

    }


}

Push-Location -Path $PSScriptRoot