# Azure Search

Creates an Azure Search

## Paramaters

azureSearchName: (required) string

Name of Azure search. Will be created in the same resource group as the script is run and in the default location for resource group.

azureSearchSku: (optional) string

Search tier; can be either free, basic, standard, standard2 or standard3.
Will default to basic if not supplied.
Please note you can't scale from basic to standard.

For a summary of the differences between the tiers,
please [see here](https://azure.microsoft.com/en-us/blog/new-azure-search-tiers-and-basic-and-standard-s2-general-availability/).

azureSearchReplicaCount: (optional) integer

The number of replicas of the search instance, between 1 and 12.
Will default to 1 if not supplied.

azureSearchPartitionCount: (optional) integer

The number of partitions of the search instance, between 1 and 12.
Not all number of partitions are valid, the valid ones are 1, 2, 3, 4, 6 and 12
Will default to 1 if not supplied.
