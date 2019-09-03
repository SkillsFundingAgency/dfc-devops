# CosmosDb Collection

Creates a container on a CosmosDb Collection

## Parameters

accountName (required)  string

The CosmosDb account to create the collection on.

databaseName (required) string

The database within the cosmosdb account to create the collection on.

collectionName (required) string

The name of the collection to create

provisionRequestUnits (optional) bool

If true, provision request units for the collection.  This should be set to false when the collection resides on a database that has provisioned throughput.

Defaults to false

offerThroughput (optional)  int

When provisionRequestUnits is set to true, provisions the RU for the collection

partitionKey (required) string

The partition key to configure the collection to use

timeToLive (optional) int

Sets the default time to live for documents within the collection.
Defaults to -1 (disabled)
