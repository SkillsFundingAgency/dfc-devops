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

partitionKey (optional) string

The partition key to configure the collection to use. Leave unset to deploy a partitionless collection.

timeToLive (optional) int

Sets the default time to live for documents within the collection.

If set to null, items are not expired automatically.
If set to -1, and items don't expire by default.
If set to a number greater than 0, items will expire "n" seconds after their last modified time.

Defaults to null
