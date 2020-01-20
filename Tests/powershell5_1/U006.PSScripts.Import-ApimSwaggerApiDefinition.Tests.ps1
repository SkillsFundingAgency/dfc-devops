Push-Location -Path $PSScriptRoot\..\..\PSScripts\

Describe "Import-ApimSwaggerApiDefinition unit tests" -Tag "Unit" {

    It "Should run with AzureRM cmdlets if a URL is supplied but not create a file" {

        Mock Invoke-RestMethod
        Mock Set-Content
        Mock Get-AzureRmApiManagementApi { [PsCustomObject]
            @{
                ApiId = "bar"
                Path = "bar"
            }
        }
        Mock Import-AzureRmApiManagementApi

        $CmdletParameters = @{
           ApimResourceGroup = "dfc-foo-bar-rg"
           InstanceName = "dfc-foo-bar-apim"
           ApiName = "bar"
           SwaggerSpecificationUrl = "https://dfc-foo-bar-fa.azurewebsites.net/api/bar/bar-api-definition"
       }

        .\Import-ApimSwaggerApiDefinition @CmdletParameters

        Assert-MockCalled Invoke-RestMethod -Exactly 0 -Scope It
        Assert-MockCalled Set-Content -Exactly 0 -Scope It
        Assert-MockCalled Get-AzureRmApiManagementApi -Exactly 1 -Scope It
        Assert-MockCalled Import-AzureRmApiManagementApi -Exactly 1 -Scope It

    }
}

Push-Location -Path $PSScriptRoot