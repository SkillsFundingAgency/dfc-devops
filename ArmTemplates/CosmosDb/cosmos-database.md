# Cosmos Database

Creates a database within a cosmosdb account.

## Parameters

accountName (required) string

Name of the cosmosdb account

databaseName (required) string

Name of the database to create

useSharedRequestUnits (optional)  boolean

Share request units through all collections on the database.  The minimum assignment is 100 RUs per collection.  RUs must be assigned in increments of 100.
The RU assignement will automatically increase when a new collection is added but the release definition that deploys this template will need to be manually updated.
This can only be set when the container is created - it cannot be changed after creation.

Please note: there is a minimum of 100 RU for each container on the database. Please ensure you set the offerThroughput parameter accordingly.

offerThroughput (optional) int

When running with useSharedRequestUnits set to true,  sets the required shared request units for the database.

databaseNeedsCreation (optional) boolean

Due to a limitation with the ARM templates, we need to know if the database is being created or updated.

This is because the "throughput" property of the "options" on the database can only be used during creation - if used at any other time,  it throws an error.
