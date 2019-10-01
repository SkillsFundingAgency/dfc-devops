# SQL Virtual Network Rule

Creates a virtual network rule on an existing PaaS Azure SQL Server

## Parameters

sqlServerName (required) string

Name of the SQL server to which the Virtual Network Rule will be applied

subnetName (required) string

Name of the subnet from which traffic will be allowed through to the SQL server

virtualNetworkRuleName (required) string

Display name of the Virtual Network Rule that will be created.  This should be descriptive rather than a concatenation of the vnet and subnet names as these properties are clearly displayed in the portal and elsewhere

vnetName (required) string

Name of the VNet which the subnet belongs to

vnetResourceGroupName (required) string

Name of the Resource Group that the VNet belongs to

ignoreMissingVnetServiceEndpoint (optional) bool

Defaults to false.  Allows you to ignore a missing service endpoint on the subnet.  Avoid setting this to true as the SQL Server will not allow traffic through until the Service Endpoint is configured correctly