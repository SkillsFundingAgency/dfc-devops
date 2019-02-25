# ARM Templates

This folder contains [ARM linked templates](https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-linked-templates) 
that can be used to stand up a specific resource and can be used in the same way as nested templated.
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

Templates for root resources (ie resources that appear at the root of the Microsoft ARM reference documentation) are stored in the root folder.  Any templates for child resources are stored in subfolders named after the root resource.

The following templates are available

* APIM
* [App Service Plan](app-service-plan.md)
* [App Service](app-service.md)
* [App Insights](application-insights.json)
* [Azure Search](azure-search.md)
* [CDN](CDN/cdn-endpoint.md)
* [Certificate](certificate.md)
* [Cognitive Services](cognitive-services.md)
* [Cosmos DB](cosmos-db.md)
* [DataFactory](datafactory.md)
* [DataFactory Linked Service Azure SQL](DataFactory/datafactory-linkedservice-azuresql.md)
* [DataFactory Linked Service CosmosDb](DataFactory/datafactory-linkedservice-cosmosdb.md)
* [Keyvault](keyvault.md)
* [Keyvault Access Policy](KeyVault/keyvault-access-policy.md)
* [Keyvault Certificates](KeyVault/keyvault-certificates.md)
* [Keyvault Secrets](KeyVault/keyvault-secrets.md)
* [Redis Cache](redis.md)
* [SQL Server](sql-server.md)
* [Storage Account](storage-account.md)
* [Storage Account Container](Storage/storage-account-arm-container.md)
