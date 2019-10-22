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

If set to -1, expiry is enabled, but items don't expire by default.
If set to a number greater than 0, expiry is enabled and items will expire "n" seconds after their last modified time.

This property defaults to -99, which means that no default ttl is set up.

WARNING:

This template *cannot* turn off the default Ttl feature once it's enabled.
ie:  If you set TTL to "On (no default)" or "On",  then this template cannot reset that to "Off".

The only way to currently do this is via the Portal.
If you want to do this, it's recommended that you remove the 'defaultTtl' from your parameters and update the collection via the portal.
