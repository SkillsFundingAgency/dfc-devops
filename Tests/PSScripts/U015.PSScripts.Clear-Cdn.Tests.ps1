Push-Location -Path $PSScriptRoot\..\..\PSScripts\

# solves CommandNotFoundException
function Clear-AzCdnEndpointContent {}

Describe "Clear-Cdn unit tests" -Tag "Unit" {


    It "Should pass parameters to Unpublish-AzureRmCdnEndpointContent" {

        Mock Clear-AzCdnEndpointContent

        .\Clear-Cdn -ResourceGroupName dfc-foo-bar-rg -CdnName dfc-foo-bar-cdn -EndpointName dfc-foo-bar-assets

        Should -Invoke -CommandName Clear-AzCdnEndpointContent

    }

}

Push-Location -Path $PSScriptRoot