# Data Factory Linked Service - Azure CosmosDb

Creates linked services within a Data Factory for one or more databases within an Azure CosmosDb account.  Depends on the Data Factory being already deployed, eg using the datafactory.json template.

## Parameters

CosmosDbName: required (string)

CosmosDbPrimaryKey: required (securestring)

CosmosDbDatabases: required (array)

DataFactoryName: required (string)