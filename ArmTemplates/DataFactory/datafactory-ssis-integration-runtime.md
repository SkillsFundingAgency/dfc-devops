# Data Factory - SSIS integration runtime

Creates an SSIS integration runtime within a Data Factory.  
Depends on the Data Factory being already deployed, eg using the datafactory.json template.

Please note that SSIS integration runtime is created in a stopped state, and needs starting before it can be used.
This is a currently a manual process via the Azure Data Factory instance website.

## Parameters

DataFactoryName: required (string)
The name of the Data Factory instance to deploy the SSIS rumtime to.

RuntimeName:  required (string)
The name of the SSIS runtime instance to create.

RuntimeDescription:  required (string)
The description for the SSIS runtime instance.

NodeSize: required (string)
The size of node to run the integration runtime upon.
Must match one of the Azure VM sizes.

NodeCount: optional (int)
The number of nodes to run.
Defaults to 2 if not otherwise specified.

MaxConcurrentJobsPerNode: optional (int)
The maximum number of concurrent jobs to run on each node simultaneously.
Defualts to 8.

CatalogServerEndpoint: required (string)
The name of the SQL Server containing the SSIS catalog.

CatalogServerAdminUsername: required (string)
The name of the admin user to connect to the SSIS catalog with.

CatalogServerAdminPassword: required (string)
The password for the admin user to connect to the SSIS catalog with.
