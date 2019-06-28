# Azure Container Registry

Creates an Azure Container Registry

## Parameters

containerRegistryName (required) string

Name of the Azure Container Registry.  The registry name must be unique within Azure, and contain 5-50 alphanumeric characters.

containerRegistrySku (optional) string

Allowed values: Basic, Standard, Premium.  https://docs.microsoft.com/en-gb/azure/container-registry/container-registry-skus