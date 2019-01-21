# Storage Account

Creates a storage account.
See https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-storage-tiers for types.

## Paramaters

storageAccountName: (required) string

Name of storage account.
Must not globally unique consisting of lowercase letters and numbers only.
Will be created in the same resource group as the script is run and in the default location for resource group.

accountType: (optional) string

Replication type used for storage account data.
Must be one of the following:

* *Standard_LRS* (default) - Local redundant storage
* *Standard_GRS* - G
* *Standard_RAGRS* -
* *Premium_LRS* - Premium storage, use for VM disks only

accessTier: (optional) string

Storage tier.
Must be one of the following:

* *Hot* (default) - storage optimized for storing data that is accessed frequently
* *Cool* - storage optimized for storing data that is infrequently accessed and stored for at least 30 days

storageKind: (optional) string

Kind of data to be stored.
Must be one of the following:

* *Storage* - General purpose storage account
* *StorageV2* (default) - New general purpose storage account
* *BlobStorage* - Blob storage only
