# KeyVault

Creates a key vault with App Service access

## Paramaters

keyVaultName: (required) string
Name of key vault. Will be created in the same resource group as the script is run and in the default location for resource group.

secretValues: (optional) array of objects
Array of secrets to add to the keyvault. If not supplied no secrets will be added.
Objects in the array must be in the following format.

```json
[
    {
        "name": "",
        "secret": "",
        "type": ""
    }
]
```
