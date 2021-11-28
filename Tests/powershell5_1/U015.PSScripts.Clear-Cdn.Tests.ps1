Push-Location -Path $PSScriptRoot\..\..\PSScripts\

# solves CommandNotFoundException
function Unpublish-AzureRmCdnEndpointContent {}

Describe "Clear-Cdn unit tests" -Tag "Unit" {


    It "Should pass parameters to Unpublish-AzureRmCdnEndpointContent" {

        Mock Unpublish-AzureRmCdnEndpointContent

        .\Clear-Cdn -ResourceGroupName dfc-foo-bar-rg -CdnName dfc-foo-bar-cdn -EndpointName dfc-foo-bar-assets

        Should -Invoke -CommandName Unpublish-AzureRmCdnEndpointContent

    }

}

Push-Location -Path $PSScriptRoot