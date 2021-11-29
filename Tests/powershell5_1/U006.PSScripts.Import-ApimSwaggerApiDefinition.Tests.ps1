Push-Location -Path $PSScriptRoot\..\..\PSScripts\

Describe "Import-ApimSwaggerApiDefinition unit tests" -Tag "Unit" {

    It "Should run with AzureRM cmdlets if a URL is supplied but not create a file" {

        Mock New-AzureRmApiManagementContext -MockWith { return @{} }
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

        Should -Invoke -CommandName Invoke-RestMethod -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-Content -Exactly 0 -Scope It
        Should -Invoke -CommandName Get-AzureRmApiManagementApi -Exactly 1 -Scope It
        Should -Invoke -CommandName Import-AzureRmApiManagementApi -Exactly 1 -Scope It

    }

    # Unable to test Az cmdlets alongside AzureRm.  After ZDT deployments are implemented across all projects this script will no longer require the AzureRm code blocks
    It "Should run with AZ cmdlets if a URL is supplied and UseAzModule is set to `$true but not create a file" -Tag "DontRun" {

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
           UseAzModule = $true
       }

        .\Import-ApimSwaggerApiDefinition @CmdletParameters

        Should -Invoke -CommandName Invoke-RestMethod -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-Content -Exactly 0 -Scope It
        Should -Invoke -CommandName Get-AzApiManagementApi -Exactly 1 -Scope It
        Should -Invoke -CommandName Import-AzApiManagementApi -Exactly 1 -Scope It

    }

}

Push-Location -Path $PSScriptRoot