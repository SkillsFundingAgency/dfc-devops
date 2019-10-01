# Cosmos DB

Creates a Cosmos DB account

## Paramaters

additionalIpAddresses: (optional) string

A list of IP addresses to add to the IP Range Filter.  If no addresses are specified the filter is left empty and is not implemented.  If one or more addresses are added then the default addresses will be added to the filter along with the specified addresses.  If more than one address needs to be added to the filter each address should be seperated by a comma (but with no space).  The default addresses that are added to the filter are: 0.0.0.0,104.42.195.92,40.76.54.131,52.176.6.30,52.169.50.45,52.187.184.26.  These allow other Azure resources and the Azure portal to access CosmosDb.

cosmosDbName: (required) string

Name of Cosmos DB account. Will be created in the same resource group as the script is run and in the default location for resource group.

cosmosApiType: (required) string

API type used to talk to Cosmos DB. Can be either Cassandra, Gremlin, MongoDB, SQL or Table.
Will be used to set the kind of Cosmos DB and defaultExperience tag.

defaultConsistencyLevel: (required) string

Consistency level of Cosmos DB. Can be either Eventual, Session, BoundedStaleness, Strong or ConsistentPrefix.

allowConnectionsFromAzureDataCenters (optional) bool

Defaults to true (to maintain backwards compatibility).  Only applies if the additionalIpAddresses is specified.  If set to false this will remove access to CosmosDB from other Azure resources.  Access will still be allowed from the Azure Portal and IP Address specified in the additionalIpAddresses parameter

## Notes

If cosmosApiType is set to MongoDB, the kind value is also set to MongoDB, otherwise it will be set to GlobalDocumentDB.
Will also set a tag for defaultExperience based on cosmosApiType; SQL cosmosApiType will be set defaultExperience to DocumentDB.
