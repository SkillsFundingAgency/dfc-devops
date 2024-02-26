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

Select values from "Basic", "Standard", "Premium", "GeneralPurpose", "GeneralPurposeServerless".
In the case of Standard and Premium SKUs, it will be concatenated with the databaseSize to form the sku name.

databaseCapacity:
This will be used on GeneralPurpose  and GeneralPurposeServerless SKUs to determine the maximum amount of VCores to allocate.

databaseMinCapacity:
This will be used on GeneralPurpose  and GeneralPurposeServerless SKUs to determine the minumum amount of VCores to allocate.

databaseAutoPauseDelay:
This will be used on GeneralPurposes and GeneralPurposeServerless SKUs to determine after how long a database is idle for (in minmutes) before it will be automatically paused. Pass -1 to disable this, which is the default. 

dataMaskingExemptPrincipals (optional) string

dataMaskingRules (optional) array

diagnosticsRetentionDays (optional) int

logAnalyticsSubscriptionId (optional) string

logAnalyticsResourceGroup (optional) string

logAnalyticsWorkspaceName (optional) string