Push-Location -Path $PSScriptRoot\..\..\PSScripts\

# solves CommandNotFoundException
function Clear-AzFrontDoorCdnEndpointContent {}

Describe "Clear-Cdn unit tests" -Tag "Unit" {


    It "Should pass parameters to Unpublish-AzureRmCdnEndpointContent" {

        Mock Clear-AzFrontDoorCdnEndpointContent

        .\Clear-Cdn -ResourceGroupName dfc-foo-bar-rg -CdnName dfc-foo-bar-cdn -EndpointName dfc-foo-bar-assets

        Should -Invoke -CommandName Clear-AzFrontDoorCdnEndpointContent

    }

}

Push-Location -Path $PSScriptRoot
