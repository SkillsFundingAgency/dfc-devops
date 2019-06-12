# Storage Account Container

Creates a blob container in an Azure Storage account.  The default access policy is none but can be set to allow public access with a parameter.

## Parameters

storageAccountName: (required) string

Name of the storage account.  Must be lowercase and only contain alphanumeric characters.

storageContainerName: (required) string

Name of the storage container.  Must be lowercase, contain only alphanumeric characters and have a length greater than 3 but less than 63 characters.  Can contain dashes if they are preceeded and followed by an alphanumeric character.

publicAccess: (optional) string

Defaults to None but can be set to Blob or Container.

