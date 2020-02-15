Push-Location -Path $PSScriptRoot\..\..\PSScripts\

Describe "New-KeyVault unit tests" -Tag "Unit" {

    Mock Get-AzureRmResourceGroup { return ConvertFrom-Json '{ "ResourceGroupName": "dfc-foobar-rg", "Location": "westeurope" }' }
    Mock New-AzureRmKeyVault { return ConvertFrom-Json '{ "VaultName": "dfc-foobar-kv", "AccessPolicies": [ { "ObjectId": "12345678-abcd-1234-5678-1234567890ab" } ] }' }
    Mock Remove-AzureRmKeyVaultAccessPolicy

    $kvname = "dfc-foobar-kv"
    $rgname = "dfc-foobar-rg"

    It "Should create a key vault if one does not exist" {
        Mock Get-AzureRmKeyVault { return $null }

        .\New-KeyVault -keyVaultName $kvname -ResourceGroupName $rgname

        Assert-MockCalled Get-AzureRmKeyVault -Exactly 1 -Scope It
        Assert-MockCalled Get-AzureRmResourceGroup -Exactly 1 -Scope It
        Assert-MockCalled New-AzureRmKeyVault -Exactly 1 -Scope It
        Assert-MockCalled Remove-AzureRmKeyVaultAccessPolicy -Exactly 1 -Scope It
    }

    It "Should not create anything if the key vault already exist" {
        Mock Get-AzureRmKeyVault { return ConvertFrom-Json '{ "VaultName": "dfc-foobar-kv", "ResourceGroupName": "dfc-foobar-rg", "Location": "westeurope" }' }

        .\New-KeyVault -keyVaultName $kvname -ResourceGroupName $rgname

        Assert-MockCalled Get-AzureRmKeyVault -Exactly 1 -Scope It
        Assert-MockCalled Get-AzureRmResourceGroup -Exactly 0 -Scope It
        Assert-MockCalled New-AzureRmKeyVault -Exactly 0 -Scope It
        Assert-MockCalled Remove-AzureRmKeyVaultAccessPolicy -Exactly 0 -Scope It
    }

}

Push-Location -Path $PSScriptRoot