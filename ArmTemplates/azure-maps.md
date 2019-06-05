# Azure Maps

Creates an Azure Maps Account

location must be set as global

## Paramaters

azureMapsName: (required) string

Name of Azure Maps. Will be created in the same resource group as the script is run and in the default location for resource group.

azureMapsSku: (required) string

Map tier; can be either Standard S0, Standard S1.

For a summary of the differences between the tiers,
please [see here](https://azure.microsoft.com/en-us/pricing/details/azure-maps/).

## Resources

For a summary of the resources, please 
[see here](https://docs.microsoft.com/en-us/azure/templates/microsoft.maps/2018-05-01/accounts#Sku).