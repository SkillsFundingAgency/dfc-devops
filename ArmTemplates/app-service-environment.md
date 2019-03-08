# App Service Environment

Creates an App Service Environment.  Depends on a subnet already existing, this will need to be created seperately due to restrictions within the tenant.

## Parameters

name (required) string

Name of the App Service Environment

domainName (required) string

Name of the DNS domain that this ASE and it's child apps will be part of.

location (optional) string

Defaults to West Europe.

subnetName (required) string

Name of the subnet that this ASE will be connected to.

virtualnetworkResourceGroupName (required) string

Name of the Resource Group that holds the vnet that holds the subnet.

virtualNetworkName (required) string

Name of the vnet that contains the subnet.