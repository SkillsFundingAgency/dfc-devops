Push-Location -Path $PSScriptRoot\..\..\PSScripts\

Describe "Set-EsfaResourceGroupTags unit tests" -Tag "Unit" {

    BeforeAll {
        Mock Get-AzResourceGroup { [PsCustomObject]
            @{
                ResourceGroupName = "dfc-foobar-rg"
                Location          = "westeurope"
                Tags              = @{"Parent Business" = "National Careers Service"; "Service Offering" = "Digital First Career Service (DFCS) Website"; "Environment" = "Dev/Test"; "Portfolio" = "Education and Skills Funding Agency"; "Service Line" = "National Careers Service (CEDD)"; "Service" = "National Careers Service"; "Product" = "Digital First Career Service (DFCS) Website"; "Feature" = "Digital First Career Service (DFCS) Website" } 
            }
        }
        Mock New-AzResourceGroup
        Mock Set-AzResourceGroup
    
    }
    It "Should do nothing if a resource group exists with matching tags" {

        .\Set-EsfaResourceGroupTags -ResourceGroupName "dfc-foobar-rg" -Environment "Dev/Test" -ParentBusiness "National Careers Service" -ServiceOffering "Digital First Career Service (DFCS) Website"

        Should -Invoke -CommandName Get-AzResourceGroup -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzResourceGroup -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-AzResourceGroup -Exactly 0 -Scope It

    }

    It "Should update existing resource group if group exists with different tags" {

        .\Set-EsfaResourceGroupTags -ResourceGroupName "dfc-foobar-rg" -Environment "Dev/Test" -ParentBusiness "National Careers Service" -ServiceOffering "Digital First Career Service (DFCS) Website (PP)"

        Should -Invoke -CommandName Get-AzResourceGroup -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzResourceGroup -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-AzResourceGroup -Exactly 1 -Scope It

    }

    It "Should create new resource group if group doesn't exists" {

        Mock Get-AzResourceGroup

        .\Set-EsfaResourceGroupTags -ResourceGroupName "dfc-barfoo-rg" -Environment "Dev/Test" -ParentBusiness "National Careers Service" -ServiceOffering "Digital First Career Service (DFCS) Website (PP)"

        Should -Invoke -CommandName Get-AzResourceGroup -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzResourceGroup -Exactly 1 -Scope It
        Should -Invoke -CommandName Set-AzResourceGroup -Exactly 0 -Scope It

    }

    It "Should add tags to the group it not tags exist" {

        Mock Get-AzResourceGroup { [PsCustomObject]
            @{
                ResourceGroupName = "dfc-foobar-rg"
                Location          = "westeurope"
            }
        }
    
        .\Set-EsfaResourceGroupTags -ResourceGroupName "dfc-barfoo-rg" -Environment "Dev/Test" -ParentBusiness "National Careers Service" -ServiceOffering "Digital First Career Service (DFCS) Website (PP)"

        Should -Invoke -CommandName Get-AzResourceGroup -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzResourceGroup -Exactly 0 -Scope It
        Should -Invoke -CommandName Set-AzResourceGroup -Exactly 1 -Scope It

    }

}

Push-Location -Path $PSScriptRoot