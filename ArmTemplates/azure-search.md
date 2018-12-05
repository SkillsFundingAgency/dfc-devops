# Azure Search

Creates an Azure Search

## Paramaters

azureSearchName: (required) string

Name of key vault. Will be created in the same resource group as the script is run and in the default location for resource group.

azureSearchSku: (optional) string

Can be either free, basic, standard, standard2 or standard3.
Will default to standard if not supplied.

azureSearchReplicaCount: (optional) integer
The number of replicas of the search instance, between 1 and 12.
Will default to 1 if not supplied.

azureSearchPartitionCount: (optional) integer
The number of partitions of the search instance, between 1 and 12.
Will default to 1 if not supplied.
