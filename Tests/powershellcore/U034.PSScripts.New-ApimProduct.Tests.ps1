Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "New-ApimProduct unit tests" -Tag "Unit" {

    Mock New-AzApiManagementContext -MockWith { return @{} }
    Mock Set-AzApiManagementProduct
    Mock New-AzApiManagementProduct

    $CmdletParameters = @{
        ApimResourceGroup = "dfc-foo-bar-rg"
        InstanceName = "dfc-foo-bar-apim"
        ApiProductId = "bar-product"
    }

    It "Should not create a product if one already exists" {

        Mock Get-AzApiManagementProduct -MockWith { return @{
            Id = "bar-product"
            State = "Published"
        } }

        .\New-ApimProduct @CmdletParameters

        Assert-MockCalled New-AzApiManagementContext -Exactly 1 -Scope It
        Assert-MockCalled Get-AzApiManagementProduct -Exactly 1 -Scope It
        Assert-MockCalled New-AzApiManagementProduct -Exactly 0 -Scope It
        Assert-MockCalled Set-AzApiManagementProduct -Exactly 0 -Scope It

    }

    It "Should create a product if one does not already exist in the APIM" {

        Mock Get-AzApiManagementProduct -MockWith { return $null }
        Mock New-AzApiManagementProduct -MockWith { return @{
            Id = "bar-product"
            State = "Published"
        } }
        
        .\New-ApimProduct @CmdletParameters

        Assert-MockCalled New-AzApiManagementContext -Exactly 1 -Scope It
        Assert-MockCalled Get-AzApiManagementProduct -Exactly 1 -Scope It
        Assert-MockCalled New-AzApiManagementProduct -Exactly 1 -Scope It
        Assert-MockCalled Set-AzApiManagementProduct -Exactly 0 -Scope It

    }

    It "Should publish the product if it is not published" {

        Mock Get-AzApiManagementProduct -MockWith { return [PSCustomObject]
            @{
                Id = "bar-product"
                State = "Not Published"
            }
        }

        .\New-ApimProduct @CmdletParameters

        Assert-MockCalled New-AzApiManagementContext -Exactly 1 -Scope It
        Assert-MockCalled Get-AzApiManagementProduct -Exactly 1 -Scope It
        Assert-MockCalled New-AzApiManagementProduct -Exactly 0 -Scope It
        Assert-MockCalled Set-AzApiManagementProduct -Exactly 1 -Scope It

    }

}

Push-Location -Path $PSScriptRoot