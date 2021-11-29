Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Import-ApimSwaggerApiDefinition unit tests" -Tag "Unit" {


    BeforeAll {
        # test wide mocks
        Mock Invoke-RestMethod -MockWith {
            # called only when downloading the swagger to local file, ie ParameterSetName="File"
            return '{"swagger":"2.0","info":{"title":"mock API","version":"0.1.2"},"host":"dfc-foo-bar-fa.azurewebsites.net","basePath":"/","schemes":["https"]}'
        }
        Mock New-AzApiManagementContext -MockWith {
            # always called
            return @{}
        }
        Mock Get-AzApiManagementApi -MockWith { return @{
                # always called
                ApiId = "bar-api"
                Name  = "Bar API"
            } }
        Mock Get-AzApiManagementApiVersionSet -MockWith { return @{
                # called only when using versioned APIs, ie ApiVersionSetId passed in
                ApiVersionSetId = "bar-api-versionset"
                DisplayName     = "bar-api"
            } }
        Mock Import-AzApiManagementApi # called at the end to import API with different paramters

        $BaseParameters = @{
            ApimResourceGroup       = "dfc-foo-bar-rg"
            InstanceName            = "dfc-foo-bar-apim"
            ApiName                 = "bar-api"
            SwaggerSpecificationUrl = "https://dfc-foo-bar-fa.azurewebsites.net/swagger/json"
            ApiPath                 = "bar"
        }
    }

    It "Should import standard api from specification" {

        $ImportStdParameters = $BaseParameters.Clone()

        .\Import-ApimSwaggerApiDefinition @ImportStdParameters

        Should -Invoke -CommandName Invoke-RestMethod -Exactly 0 -Scope It
        Should -Invoke -CommandName New-AzApiManagementContext -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzApiManagementApi -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzApiManagementApiVersionSet -Exactly 0 -Scope It
        Should -Invoke -CommandName Import-AzApiManagementApi -Exactly 1 -Scope It -ParameterFilter { $SpecificationUrl -eq "https://dfc-foo-bar-fa.azurewebsites.net/swagger/json" }

    }

    It "Should download and import standard api from specification" {

        $DownloadStdParameters = $BaseParameters.Clone()
        $DownloadStdParameters['SwaggerSpecificationFile'] = $true
        $DownloadStdParameters['OutputFilePath'] = $TestDrive

        .\Import-ApimSwaggerApiDefinition @DownloadStdParameters

        Should -Invoke -CommandName Invoke-RestMethod -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzApiManagementContext -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzApiManagementApi -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzApiManagementApiVersionSet -Exactly 0 -Scope It
        Should -Invoke -CommandName Import-AzApiManagementApi -Exactly 1 -Scope It -ParameterFilter { $SpecificationPath }

    }

    It "Should import versioned api from specification" {

        $ImportVersionedParameters = $BaseParameters.Clone()
        $ImportVersionedParameters['ApiVersionSetId'] = "bar-api-versionset"
        $ImportVersionedParameters['ApiVersion'] = "v1"

        .\Import-ApimSwaggerApiDefinition @ImportVersionedParameters

        Should -Invoke -CommandName Invoke-RestMethod -Exactly 0 -Scope It
        Should -Invoke -CommandName New-AzApiManagementContext -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzApiManagementApi -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzApiManagementApiVersionSet -Exactly 1 -Scope It
        Should -Invoke -CommandName Import-AzApiManagementApi -Exactly 1 -Scope It -ParameterFilter { $SpecificationUrl -eq "https://dfc-foo-bar-fa.azurewebsites.net/swagger/json" -and $ApiVersion -eq "v1" }

    }

    It "Should download and import versioned api from specification" {

        # Because this may run within the same minute as the above download it would attempt to create the same filename if we used the same values
        $DownloadVersionedParameters = @{
            ApimResourceGroup        = "dfc-foo-bar-rg"
            InstanceName             = "dfc-foo-bar-apim"
            ApiName                  = "bar-api"
            SwaggerSpecificationUrl  = "https://dfc-foo-bar-v2-fa.azurewebsites.net/swagger/json"
            ApiPath                  = "bar"
            ApiVersionSetId          = "bar-api-versionset"
            ApiVersion               = "v2"
            SwaggerSpecificationFile = $true
            OutputFilePath           = $TestDrive
        }

        .\Import-ApimSwaggerApiDefinition @DownloadVersionedParameters

        Should -Invoke -CommandName Invoke-RestMethod -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzApiManagementContext -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzApiManagementApi -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzApiManagementApiVersionSet -Exactly 1 -Scope It
        Should -Invoke -CommandName Import-AzApiManagementApi -Exactly 1 -Scope It

    }

}

Push-Location -Path $PSScriptRoot