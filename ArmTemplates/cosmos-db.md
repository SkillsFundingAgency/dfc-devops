# Cosmos DB

Creates a Cosmos DB account

## Paramaters

cosmosDbName: (required) string

Name of Cosmos DB account. Will be created in the same resource group as the script is run and in the default location for resource group.

cosmosApiType: (required) string

API type used to talk to Cosmos DB. Can be either Cassandra, Gremlin, MongoDB, SQL or Table.
Will be used to set the kind of Cosmos DB and defaultExperience tag.

defaultConsistencyLevel: (required) string

Consistency level of Cosmos DB. Can be either Eventual, Session, BoundedStaleness, Strong or ConsistentPrefix.

## Notes

If cosmosApiType is set to MongoDB, the kind value is also set to MongoDB, otherwise it will be set to GlobalDocumentDB.
Will also set a tag for defaultExperience based on cosmosApiType; SQL cosmosApiType will be set defaultExperience to DocumentDB.
