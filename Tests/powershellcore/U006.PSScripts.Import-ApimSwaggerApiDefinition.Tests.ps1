
Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Import-ApimSwaggerApiDefinition unit tests" -Tag "Unit" {

    It "Should not create a file"  {

        Mock Invoke-RestMethod
        Mock Set-Content
        Mock Get-AzApiManagementApi { [PsCustomObject]
            @{
                ApiId = "bar"
                Path = "bar"
            }
        }
        Mock Import-AzApiManagementApi

        $CmdletParameters = @{
           ApimResourceGroup = "dfc-foo-bar-rg"
           InstanceName = "dfc-foo-bar-apim"
           ApiName = "bar"
           SwaggerSpecificationUrl = "https://dfc-foo-bar-fa.azurewebsites.net/api/bar/bar-api-definition"
       }

        .\Import-ApimSwaggerApiDefinition @CmdletParameters

        Assert-MockCalled Invoke-RestMethod -Exactly 0 -Scope It
        Assert-MockCalled Set-Content -Exactly 0 -Scope It
        Assert-MockCalled Get-AzApiManagementApi -Exactly 1 -Scope It
        Assert-MockCalled Import-AzApiManagementApi -Exactly 1 -Scope It

    }

}

Push-Location -Path $PSScriptRoot