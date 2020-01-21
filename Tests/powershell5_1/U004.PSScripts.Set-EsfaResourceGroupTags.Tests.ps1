Push-Location -Path $PSScriptRoot\..\..\PSScripts\

Describe "Set-EsfaResourceGroupTags unit tests" -Tag "Unit" {

    Mock Get-AzureRmResourceGroup { [PsCustomObject]
        @{
            ResourceGroupName = "dfc-foobar-rg"
            Location = "westeurope"
            Tags = @{"Parent Business" =  "National Careers Service"; "Service Offering" = "Digital First Career Service (DFCS) Website"; "Environment" = "Dev/Test"} 
        }
    }
    Mock New-AzureRmResourceGroup
    Mock Set-AzureRmResourceGroup

    It "Should do nothing if a resource group exists with matching tags" {

        .\Set-EsfaResourceGroupTags -ResourceGroupName "dfc-foobar-rg" -Environment "Dev/Test" -ParentBusiness "National Careers Service" -ServiceOffering "Digital First Career Service (DFCS) Website"

        Assert-MockCalled Get-AzureRmResourceGroup -Exactly 1 -Scope It
        Assert-MockCalled New-AzureRmResourceGroup -Exactly 0 -Scope It
        Assert-MockCalled Set-AzureRmResourceGroup -Exactly 0 -Scope It

    }

    It "Should update existing resource group if group exists with different tags" {

        .\Set-EsfaResourceGroupTags -ResourceGroupName "dfc-foobar-rg" -Environment "Dev/Test" -ParentBusiness "National Careers Service" -ServiceOffering "Digital First Career Service (DFCS) Website (PP)"

        Assert-MockCalled Get-AzureRmResourceGroup -Exactly 1 -Scope It
        Assert-MockCalled New-AzureRmResourceGroup -Exactly 0 -Scope It
        Assert-MockCalled Set-AzureRmResourceGroup -Exactly 1 -Scope It

    }

    It "Should create new resource group if group doesn't exists" {

        Mock Get-AzureRmResourceGroup

        .\Set-EsfaResourceGroupTags -ResourceGroupName "dfc-barfoo-rg" -Environment "Dev/Test" -ParentBusiness "National Careers Service" -ServiceOffering "Digital First Career Service (DFCS) Website (PP)"

        Assert-MockCalled Get-AzureRmResourceGroup -Exactly 1 -Scope It
        Assert-MockCalled New-AzureRmResourceGroup -Exactly 1 -Scope It
        Assert-MockCalled Set-AzureRmResourceGroup -Exactly 0 -Scope It

    }

    It "Should add tags to the group it not tags exist" {

        Mock Get-AzureRmResourceGroup { [PsCustomObject]
            @{
                ResourceGroupName = "dfc-foobar-rg"
                Location = "westeurope"
            }
        }
    
        .\Set-EsfaResourceGroupTags -ResourceGroupName "dfc-barfoo-rg" -Environment "Dev/Test" -ParentBusiness "National Careers Service" -ServiceOffering "Digital First Career Service (DFCS) Website (PP)"

        Assert-MockCalled Get-AzureRmResourceGroup -Exactly 1 -Scope It
        Assert-MockCalled New-AzureRmResourceGroup -Exactly 0 -Scope It
        Assert-MockCalled Set-AzureRmResourceGroup -Exactly 1 -Scope It

    }

}

Push-Location -Path $PSScriptRoot