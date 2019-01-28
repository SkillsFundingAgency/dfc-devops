# KeyVault

Creates a key vault.
If ran on an existing key vault it will wipe out all existing access policies.
For an alternative which only creates the key vault if one does not exist, see PSScript/New-KeyVault.ps1

## Paramaters

keyVaultName: (required) string

Name of existing key vault

permissions: (required) array of object

Array of permissions to add to the keyvault.
Objects in the array must be in the following format.

```json
[
    {
        "objectID": "",
        "permission": {
            "keys": [],
            "secrets": [],
            "certificates": [],
            "storage": []
        }
    }
]
```

## Permissions

The permission object has the following properties (each is optional) with an array specifying the permissions to grant.
Accepted permissions for each type are:

* keys - encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, purge
* secrets - get, list, set, delete, backup, restore, recover, purge
* certificates - get, list, delete, create, import, update, managecontacts, getissuers, listissuers, setissuers, deleteissuers, manageissuers, recover, purge, backup, restore
* storage - get, list, delete, set, update, regeneratekey, recover, purge, backup, restore, setsas, listsas, getsas, deletesas
