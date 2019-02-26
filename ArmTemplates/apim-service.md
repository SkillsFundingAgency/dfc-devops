# API Management Service

Creates an API Management service

## Parameters

adminEmail (required) string

A valid email address, this will receive notifications related to APIM service provisioning.  It's not required to access the service as an Admin, this can be done with any tenant AAD account that has the appropriate permissions.

apimServiceName (required) string

The name of the APIM service

environmentName (optional) string

Used to generate the prefixes for custom hostnames.  Where PRD is used the environment name will not be included in the prefix.

hostnameRoot (optional) string

Concatenated with the environmentName (except for PRD).  When this parameter is set valid values will need to be specified for both KeyVaultCertificatePaths.

organizationName (required) string

Any string, this will be visible on the Developer Portal which is a public website.

portalKeyVaultCertificatePath (optional) string

The certificate identifier, eg https://dss-dev-shared-kv.vault.azure.net/certificates/wildcard-dss-nationalcareersservice-direct-gov-uk/identifierstringabc123

proxyKeyVaultCertificatePath (optional) string

The certificate identifier, eg https://dss-dev-shared-kv.vault.azure.net/certificates/wildcard-dss-nationalcareersservice-direct-gov-uk/identifierstringabc123

skuTier (optional) string

Select from Developer, Basic, Standard or Premium.  Defaults to Developer.

subnetName (optional) string

If network restrictions need to be implemented this parameter is required.  The Azure Subnet must already exist.

vnetResourceGroup (optional) string

The resource group that holds the VNet that the Subnet belongs to.

vnetName (optional) string

The name of the VNet that the Subnet belongs to.