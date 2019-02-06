# KeyVault

Creates a key vault.
If ran on an existing key vault it will wipe out all existing access policies.
For an alternative which only creates the key vault if one does not exist, see PSScript/New-KeyVault.ps1

## Paramaters

keyVaultName: (required) string

Name of key vault. Will be created in the same resource group as the script is run and in the default location for resource group.

certificates: (required) array of string

Array of certification to create. Name must match that of the secret in the keyvault.

serverFarmId: (optional) string

App service plan resource ID to associate to the certificate.
Resource ID needs to be formatted as: "/subscriptions/{subscriptionID}/resourceGroups/{groupName}/providers/Microsoft.Web/serverfarms/{appServicePlanName}".

## Common usage

This is commonly used to with the keyvault linked template to optionally add secrets.
The following template is a guide on how to achieve this.

```json
"parameters": {
  "keyVaultName": {
    "type": "string"
  },
  "certificates": {
    "type": "array",
    "defaultValue": []
  }
},
"variables": {
  "deploymentUrlBase": "https://raw.githubusercontent.com/SkillsFundingAgency/dfc-devops/master/ArmTemplates/"
},
"resources": [
  {
    "apiVersion": "2017-05-10",
    "name": "keyvault",
    "type": "Microsoft.Resources/deployments",
    "properties": {
      "mode": "Incremental",
      "templateLink": {
        "uri": "[concat(variables('deploymentUrlBase'),'keyvault.json')]",
        "contentVersion": "1.0.0.0"
      },
      "parameters": {
        "keyVaultName": {
          "value": "[parameters('keyVaultName')]"
        }
      }
    }
  },
  {
    "apiVersion": "2017-05-10",
    "name": "keyvaultsecrets",
    "type": "Microsoft.Resources/deployments",
    "condition": "[greater(length(parameters('certificates')), 0)]",
    "dependsOn": [
      "keyvault"
    ],
    "properties": {
      "mode": "Incremental",
      "templateLink": {
        "uri": "[concat(variables('deploymentUrlBase'),'keyvault-certificates.json')]",
        "contentVersion": "1.0.0.0"
      },
      "parameters": {
        "keyVaultName": {
          "value": "[parameters('keyVaultName')]"
        },
        "certificates": {
          "value": "[parameters('certificates')]"
        }
      }
    }
  }
]
```
