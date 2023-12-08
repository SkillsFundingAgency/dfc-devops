<#
.SYNOPSIS
Creates a key vault if one does not exist

.DESCRIPTION
Creates a key vault if one does not exist

.PARAMETER KeyVaultName
Keyvault to add the secret to

.PARAMETER ResourceGroupName
Resource Group for the key vault

.EXAMPLE
New-KeyVault -KeyVaultName dfc-foo-kv -ResourceGroupName dfc-foo-rg

#>
param(
    [Parameter(Mandatory=$true)]
    [string] $KeyVaultName,
    [Parameter(Mandatory=$true)]
    [string] $ResourceGroupName
)

$ExistingKeyVault = Get-AzKeyVault $KeyVaultName -ResourceGroupName $ResourceGroupName

if ($ExistingKeyVault) {
    Write-Host "Key vault $KeyVaultName already exists"
}
else {
    Write-Host "Creating key vault $KeyVaultName"
    $ResourceGroup = Get-AzResourceGroup -Name $ResourceGroupName

    $AzureRmVersion = Get-Module AzureRM -ListAvailable | Sort-Object { $_.Version.Major } -Descending | Select-Object -First 1
    if ($AzureRmVersion.Version.Major -gt 5) {
        $NewKeyVault   = New-AzKeyVault -Name $KeyVaultName -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $ResourceGroup.Location
    }
    else {
        $NewKeyVault   = New-AzKeyVault -Name $KeyVaultName -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $ResourceGroup.Location
    }

    Remove-AzKeyVaultAccessPolicy -VaultName $NewKeyVault.VaultName -ObjectId $NewKeyVault.AccessPolicies[0].ObjectId
}

