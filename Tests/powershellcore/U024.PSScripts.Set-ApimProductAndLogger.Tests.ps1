Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Set-ApimProductAndLogger unit tests" -Tag "Unit" {

    BeforeEach {
        Mock New-AzApiManagementContext -MockWith { return @{} }
        Mock Add-AzApiManagementApiToProduct
        Mock Get-AzApiManagementDiagnostic
        Mock New-AzApiManagementDiagnostic
        Mock Set-AzApiManagementDiagnostic
    }

    It "Should set product only if no logger passed in" {

        $CmdletParameters = @{
            ApimResourceGroup = "dfc-foo-bar-rg"
            InstanceName      = "dfc-foo-bar-apim"
            ApiId             = "bar"
            ApiProductId      = "bar-product"
        }

        .\Set-ApimProductAndLogger @CmdletParameters

        Should -Invoke -CommandName New-AzApiManagementContext -Exactly 1 -Scope It
        Should -Invoke -CommandName Add-AzApiManagementApiToProduct -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzApiManagementDiagnostic -Exactly 0 -Scope It
        Should -Invoke -CommandName New-AzApiManagementDiagnostic -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-AzApiManagementDiagnostic -Exactly 0 -Scope It

    }

    It "Should set product only if the logger is already attached to the API" {

        Mock Get-AzApiManagementDiagnostic { [PSCustomObject]
            @{
                LoggerId = "bar-product-logger"
            }
        }
        
        $CmdletParameters = @{
            ApimResourceGroup = "dfc-foo-bar-rg"
            InstanceName      = "dfc-foo-bar-apim"
            ApiId             = "bar"
            ApiProductId      = "bar-product"
            ApimLoggerName    = "bar-product-logger"
        }

        .\Set-ApimProductAndLogger @CmdletParameters

        Should -Invoke -CommandName New-AzApiManagementContext -Exactly 1 -Scope It
        Should -Invoke -CommandName Add-AzApiManagementApiToProduct -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzApiManagementDiagnostic -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzApiManagementDiagnostic -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-AzApiManagementDiagnostic -Exactly 0 -Scope It

    }

    It "Should set product and logger if the wrong logger is attached to the API" {

        Mock Get-AzApiManagementDiagnostic { [PSCustomObject]
            @{
                LoggerId = "foo-product-logger"
            }
        }
        
        $CmdletParameters = @{
            ApimResourceGroup = "dfc-foo-bar-rg"
            InstanceName      = "dfc-foo-bar-apim"
            ApiId             = "bar"
            ApiProductId      = "bar-product"
            ApimLoggerName    = "bar-product-logger"
        }

        .\Set-ApimProductAndLogger @CmdletParameters

        Should -Invoke -CommandName New-AzApiManagementContext -Exactly 1 -Scope It
        Should -Invoke -CommandName Add-AzApiManagementApiToProduct -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzApiManagementDiagnostic -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzApiManagementDiagnostic -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-AzApiManagementDiagnostic -Exactly 1 -Scope It

    }

    It "Should set product and add a new logger if no logger is attached to the API" {

        Mock Get-AzApiManagementDiagnostic
        
        $CmdletParameters = @{
            ApimResourceGroup = "dfc-foo-bar-rg"
            InstanceName      = "dfc-foo-bar-apim"
            ApiId             = "bar"
            ApiProductId      = "bar-product"
            ApimLoggerName    = "bar-product-logger"
        }

        .\Set-ApimProductAndLogger @CmdletParameters

        Should -Invoke -CommandName New-AzApiManagementContext -Exactly 1 -Scope It
        Should -Invoke -CommandName Add-AzApiManagementApiToProduct -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzApiManagementDiagnostic -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzApiManagementDiagnostic -Exactly 1 -Scope It
        Should -Invoke -CommandName Set-AzApiManagementDiagnostic -Exactly 0 -Scope It

    }
}