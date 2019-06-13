# KeyVault Access Policy

Adds a KeyVault Access Policy, leaves any existing policies in place.  If access policies are set when the KeyVault is created then any policies added by this template will be removed.

## Parameters

keyVaultName (required) string

servicePrincipalObjectId (required) string

The ObjectId of the ServicePrincipal that needs permissions.

keyPermissions (optional) array

Set permissions to keys.  Defaults to no access.
To set different permissions pass in a new array that contains permissions from the following:  encrypt, decrypt, wrapKey, unwrapKey, sign, verify, get, list, create, update, import, delete, backup, restore, recover, purge

secretPermissions (optional) array

Set permissions to secrets.  Defaults to get.
To set different permissions pass in a new array that contains permissions from the following: get, list, set, delete, backup, restore, recover, purge

certificatePermissions (optional) array

Set permissions to keys.  Defaults to no access.
To set different permissions pass in a new array that contains permissions from the following: get, list, delete, create, import, update, managecontacts, getissuers, listissuers, setissuers, deleteissuers, manageissuers, recover, purge, backup, restore

storagePermissions (optional) array

Set permissions to secrets.  Defaults to no access.
To set different permissions pass in a new array that contains permissions from the following: get, list, delete, set, update, regeneratekey, recover, purge, backup, restore, setsas, listsas, getsas, deletesas
