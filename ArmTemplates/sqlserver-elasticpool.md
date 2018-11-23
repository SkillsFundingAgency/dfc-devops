# SQL Server with Elastic Pool

Deploys a SQL Server with optional elastic pool

## Paramaters

sqlServerName: (required) string
Name of SQL Server. Will be created in the same resource group as the script is run and in the default location for resource group.

elasticPoolName: (optional) string
Name of elastic pool. Does not create elastic pool if not supplied.

elasticPoolEdition: (optional) string
Elastic pool edition. Must be either Basic, Standard, Premium, GeneralPurpose or BusinessCritical.
Only used if elasticPoolName is specified.

elasticPoolTotalDTU: (optional) integer
DTU assigned to elastic pool. Also used as the total DTU assignable per db.
Defaults to 100 if not supplied.
Only used if elasticPoolName is specified.

elasticPoolMinDTU: (optional) integer
Minimum DTU assigned to each db in pool.
Defaults to 1 if not supplied.
Only used if elasticPoolName is specified.

elasticPoolStorage: (optional) integer
Storage assigned to the elastic pool (in Mb).
Defaults to 1Gb if not supplied.
Only used if elasticPoolName is specified.
