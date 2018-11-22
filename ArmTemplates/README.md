# ARM Templates

This folder contains ARM deployments that can be used to stand up a specific resource and can be used in the same way as nested templated.
A master template should call each template as a separate resource passing in parameters as necessary.

Sample master template snippet

```json
"variables": {
  "deploymentUrlBase": "https://raw.githubusercontent.com/SkillsFundingAgency/dfc-devops/master/ArmTemplates/"
},
"resources": [
  {
    "apiVersion": "2017-05-10",
    "name": "myresource",
    "type": "Microsoft.Resources/deployments",
    "properties": {
      "mode": "Incremental",
      "templateLink": {
        "uri": "[concat(variables('deploymentUrlBase'),'template.json')]",
        "contentVersion": "1.0.0.0"
      },
      "parameters": {
      }
    }
  }
]
```

The following templates are available

* APIM
* [Keyvault](keyvault.md)
