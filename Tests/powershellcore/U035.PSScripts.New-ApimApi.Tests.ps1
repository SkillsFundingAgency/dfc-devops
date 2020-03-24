Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "New-ApimApi unit tests" -Tag "Unit" {

    Mock New-AzApiManagementContext -MockWith { return @{} }
    Mock Get-AzApiManagementApiVersionSet -MockWith { return @{
        ApiVersionSetId = "bar-api-versionset"
        DisplayName = "bar-api"
    } }
    Mock New-AzApiManagementApi

    $CmdletParameters = @{
        ApimResourceGroup = "dfc-foo-bar-rg"
        InstanceName = "dfc-foo-bar-apim"
        ApiId = "bar-api"
        ApiProductId = "bar-product"
        ApiServiceUrl = "https://dfc-foo-api-bar-fa.azurewebsites.net/"
    }

    It "Should not create an API if one already exists" {

        Mock Get-AzApiManagementApi -MockWith { return @{
            ApiId = "bar-api"
            Name = "Bar API"
        } }

        .\New-ApimApi @CmdletParameters

        Assert-MockCalled New-AzApiManagementContext -Exactly 1 -Scope It
        Assert-MockCalled Get-AzApiManagementApi -Exactly 1 -Scope It
        Assert-MockCalled Get-AzApiManagementApiVersionSet -Exactly 0 -Scope It
        Assert-MockCalled New-AzApiManagementApi -Exactly 0 -Scope It

    }

    It "Should create an API if one does not already exist in the APIM" {

        Mock Get-AzApiManagementApi -MockWith { return $null }
        
        .\New-ApimApi @CmdletParameters

        Assert-MockCalled New-AzApiManagementContext -Exactly 1 -Scope It
        Assert-MockCalled Get-AzApiManagementApi -Exactly 1 -Scope It
        Assert-MockCalled Get-AzApiManagementApiVersionSet -Exactly 0 -Scope It
        Assert-MockCalled New-AzApiManagementApi -Exactly 1 -Scope It  -ParameterFilter { $ApiVersionSetId -eq $null }

    }

    It "Should create a versioned API if one does not already exist in the APIM" {

        Mock Get-AzApiManagementApi -MockWith { return $null }

        $CmdletParameters['ApiVersionSetId'] = "bar-api-versionset"
        $CmdletParameters['ApiVersion'] = "v1"

        .\New-ApimApi @CmdletParameters

        Assert-MockCalled New-AzApiManagementContext -Exactly 1 -Scope It
        Assert-MockCalled Get-AzApiManagementApi -Exactly 1 -Scope It
        Assert-MockCalled Get-AzApiManagementApiVersionSet -Exactly 1 -Scope It
        Assert-MockCalled New-AzApiManagementApi -Exactly 1 -Scope It -ParameterFilter { $ApiVersionSetId -eq "bar-api-versionset" }

    }

}

Push-Location -Path $PSScriptRoot