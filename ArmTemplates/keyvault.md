# KeyVault

Creates a key vault.
If ran on an existing key vault it will wipe out all existing access policies.
For an alternative which only creates the key vault if one does not exist, see PSScript/New-KeyVault.ps1

## Paramaters

keyVaultName: (required) string

Name of key vault. Will be created in the same resource group as the script is run and in the default location for resource group.
