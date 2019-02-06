# KeyVault Access Policy

Adds a KeyVault Access Policy, leaves any existing policies in place.  If access policies are set when the KeyVault is created then any policies added by this template will be removed.

## Parameters

keyVaultName (required) string

servicePrincipalObjectId (required) string

The ObjectId of the ServicePrincipal that needs permissions.

secretPermissions (optional) array

Set permissions to secrets (but not Keys or Certificates).  Defaults to get.  To set different permissions pass in a new array that contains permissions from the following: get, list, set, delete, backup, restore, recover, purge