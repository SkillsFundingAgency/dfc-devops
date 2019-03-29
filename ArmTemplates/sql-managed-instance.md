# SQL Server Managed Instance

Deploys a SQL Server Managed Instance to the supplied VNet Subnet

## Paramaters

sqlServerName: (required) string

Name of SQL Server Managed Instance.
Will be created in the same resource group as the script is run and in the default location for resource group.

sqlSubnetId: (required) string

Subnet ID to install SQL managed instance to

sqlServerAdminUserName: (optional) string

SQL SA administrator username.
Only used when the server is created.
Does not change settings if the server already exists (will not change the admin username on an existing server).
If not passed in a username will be generated.
The username is available as an output of the template - saAdministratorLogin

sqlServerAdminPassword: (required) securestring

SQL SA administrator password.
Only used when the server is created.
Does not change settings if the server already exists (will not change the admin password on an existing server).

sqlServerActiveDirectoryAdminLogin: (required) string

Name of AAD user or group to grant administrator rights to.

sqlServerActiveDirectoryAdminObjectId: (required) string

Object ID of AAD user or group above.

vCores: (optional) int

Number of cores the server cluster will have.
Must be either 8, 16, 24, 32, 40, 64 or 80.
Defaults to 8.

storageSizeGb: (optional) int

Max size of the database in Gb.
Defaults to 32Gb.

## Common usage

The SQL managed instance needs an network environment (VNet and Routing Table) to be installed into.
This can easily be achieved by usinghte [managed-instance-environment template](managed-instance-environment.md) as shown.

```json
"parameters": {
  "virtualNetworkPrefix": {
    "type": "string"
  },
  "sqlServerAdminUserName": {
    "type": "string"
  },
  "sqlServerAdminPassword": {
    "type": "securestring"
  },
  "sqlServerActiveDirectoryAdminLogin": {
    "type": "string"
  },
  "sqlServerActiveDirectoryAdminObjectId": {
    "type": "string"
  }
},
"variables": {
  "deploymentUrlBase": "https://raw.githubusercontent.com/SkillsFundingAgency/dfc-devops/master/ArmTemplates/",
  "sqlServerName": "[concat(parameters('virtualNetworkPrefix'), '-sql')]"
},
"resources": [
  {
    "apiVersion": "2017-05-10",
    "name": "env",
    "type": "Microsoft.Resources/deployments",
    "properties": {
      "mode": "Incremental",
      "templateLink": {
        "uri": "[concat(variables('deploymentUrlBase'),'managed-instance-environment.json')]",
        "contentVersion": "1.0.0.0"
      },
      "parameters": {
        "virtualNetworkPrefix": {
          "value": "[parameters('virtualNetworkPrefix')]"
        },
        "virtualNetworkSubnets": {
            "value": [
                "sql"
            ]
        }
      }
    }
  },
  {
    "apiVersion": "2017-05-10",
    "name": "keyvaultsecrets",
    "type": "Microsoft.Resources/deployments",
    "dependsOn": [
      "env"
    ],
    "properties": {
      "mode": "Incremental",
      "templateLink": {
        "uri": "[concat(variables('deploymentUrlBase'),'sql-managed-instance.json')]",
        "contentVersion": "1.0.0.0"
      },
      "parameters": {
        "sqlServerName": {
          "value": "[variables('sqlServerName')]"
        },
        "sqlServerAdminUserName": {
          "value": "[parameters('sqlServerAdminUserName')]"
        },
        "sqlServerAdminPassword": {
          "value": "[parameters('sqlServerAdminPassword')]"
        },
        "sqlServerActiveDirectoryAdminLogin": {
          "value": "[parameters('sqlServerActiveDirectoryAdminLogin')]"
        },
        "sqlServerActiveDirectoryAdminObjectId": {
          "value": "[parameters('sqlServerActiveDirectoryAdminObjectId')]"
        },
        "sqlSubnetId": {
          "value": "[resourceId('Microsoft.Network/virtualNetworks/subnets', reference('env').outputs.virtualNetworkName.value, 'sql')]"
        }
      }
    }
  }
]
```
