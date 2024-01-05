Push-Location -Path $PSScriptRoot\..\..\PSScripts\

Describe "New-KeyVault unit tests" -Tag "Unit" {

    BeforeAll {
        Mock Get-AzResourceGroup { return ConvertFrom-Json '{ "ResourceGroupName": "dfc-foobar-rg", "Location": "westeurope" }' }
        Mock New-AzKeyVault { return ConvertFrom-Json '{ "VaultName": "dfc-foobar-kv", "AccessPolicies": [ { "ObjectId": "12345678-abcd-1234-5678-1234567890ab" } ] }' }
        Mock Remove-AzKeyVaultAccessPolicy

        $kvname = "dfc-foobar-kv"
        $rgname = "dfc-foobar-rg"
    }

    It "Should create a key vault if one does not exist" {
        Mock Get-AzKeyVault { return $null }

        .\New-KeyVault -keyVaultName $kvname -ResourceGroupName $rgname

        Should -Invoke -CommandName Get-AzKeyVault -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzResourceGroup -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzKeyVault -Exactly 1 -Scope It
        Should -Invoke -CommandName Remove-AzKeyVaultAccessPolicy -Exactly 1 -Scope It
    }

    It "Should not create anything if the key vault already exist" {
        Mock Get-AzKeyVault { return ConvertFrom-Json '{ "VaultName": "dfc-foobar-kv", "ResourceGroupName": "dfc-foobar-rg", "Location": "westeurope" }' }

        .\New-KeyVault -keyVaultName $kvname -ResourceGroupName $rgname

        Should -Invoke -CommandName Get-AzKeyVault -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzResourceGroup -Exactly 0 -Scope It
        Should -Invoke -CommandName New-AzKeyVault -Exactly 0 -Scope It
        Should -Invoke -CommandName Remove-AzKeyVaultAccessPolicy -Exactly 0 -Scope It
    }
}

Push-Location -Path $PSScriptRoot