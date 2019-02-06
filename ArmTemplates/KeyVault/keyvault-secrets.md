# KeyVault secrets

Creates secrets within the key vault

## Paramaters

keyVaultName: (required) string

Name of key vault. This must ALREADY exists before the template is called.
Please see common usage section for an example of how to create a Keyvault and optionally populate with secrets.

secrets: (required) array of objects

Array of secrets to add to the keyvault.
Objects in the array must be in the following format.

```json
[
    {
        "name": "",
        "secret": "",
        "type": ""
    }
]
```

## Common usage

This is commonly used to with the keyvault linked template to optionally add secrets.
The following template is a guide on how to achieve this.

```json
"parameters": {
  "keyVaultName": {
    "type": "string"
  },
  "secrets": {
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
    "condition": "[greater(length(parameters('secrets')), 0)]",
    "dependsOn": [
      "keyvault"
    ],
    "properties": {
      "mode": "Incremental",
      "templateLink": {
        "uri": "[concat(variables('deploymentUrlBase'),'keyvault-secrets.json')]",
        "contentVersion": "1.0.0.0"
      },
      "parameters": {
        "keyVaultName": {
          "value": "[parameters('keyVaultName')]"
        },
        "secrets": {
          "value": "[parameters('secrets')]"
        }
      }
    }
  }
]
```
