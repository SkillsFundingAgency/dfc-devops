# Certificate

Creates a certificate from a key vault.

## Paramaters

keyVaultName: (required) string

Name of key vault. Will be created in the same resource group as the script is run and in the default location for resource group.

keyVaultCertificateName: (required) string

Name of the key vault secret that contains the certificate.
It is recommended to use the Add-KeyVaultCertificate.ps1 script (from PSScripts) to add a pfx cert to the key vault.

keyVaultResourceGroup: (optional) string

Resource group the key vault is in.
Defaults to resource group the template is ran under if not specified.

serverFarmId: (optional) string

App service plan resource ID to associate to the certificate.
Resource ID needs to be formatted as: "/subscriptions/{subscriptionID}/resourceGroups/{groupName}/providers/Microsoft.Web/serverfarms/{appServicePlanName}".
