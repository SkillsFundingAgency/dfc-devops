# Service Bus Firewall Virtual Network Rule

Adds a Virtual Network rule to an existing Service Bus Namespace.  Optionally can add IP rules.

## Parameters

servicebusName (required) string

The name of the Service Bus Namespace to ad the VNet rule to.

subnetNames (required) array

An array of Subnet names to add to the VNet rule.  All the subnets must be part of the same VNet.

vnetName (required) string

Name of the VNet that contains the subnets.

vnetResourceGroup (required) string

Name of the Vnet's resource group.

ipRules (optional) array

An array of IP Addresses, these can be added seperately using the servicebus-ipfilters-resources template (which needs to be relocated from the dss-infrastructure repo)