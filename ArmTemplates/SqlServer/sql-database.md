# SQL Database

Creates a new SQL database.  Requires a [SQL Server ](..\sql-server.md) to already exist.

## Parameters

databaseName (required) string

sqlServerName (required) string

elasticPoolName (optional) string

databaseSize (optional) string

Select values from "1", "2", "3", "4", "6", "7", "9", "10", "11", "15".  This will be concatenated with the databaseTier (exception for Basic) to form the sku name.  Check that the combiniation of databaseTier and databaseSize are valid.

databaseSizeBytes (optional) string

databaseTier (optional) string

Select values from "Basic", "Standard", "Premium".  This will be concatenated with the databaseSize (exception for Basic) to form the sku name.

dataMaskingExemptPrincipals (optional) string

dataMaskingRules (optional) array

diagnosticsRetentionDays (optional) int

logAnalyticsSubscriptionId (optional) string

logAnalyticsResourceGroup (optional) string

logAnalyticsWorkspaceName (optional) string