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

* [APIM Service](apim-service.md)
* [APIM API](APIM/apim-api.md)
* [APIM Logger](APIM/apim-logger.md)
* [APIM Product](APIM/apim-product.md)
* [App Gateway v2](app-gateway-v2.md)
* [App Insights](application-insights.json)
* [App Service](app-service.md)
* [App Service Environment](app-service-environment.md)
* [App Service Plan](app-service-plan.md)
* [Azure Maps](azure-maps.md)
* [Azure Search](azure-search.md)
* [CDN Profile](cdn-profile.md)
* [CDN Endpoint](CDN/cdn-endpoint.md)
* [Certificate](certificate.md)
* [Cognitive Services](cognitive-services.md)
* [Container Registry](container-registry.md)
* [Cosmos DB](cosmos-db.md)
* [DataFactory](datafactory.md)
* [DataFactory Linked Service Azure SQL](DataFactory/datafactory-linkedservice-azuresql.md)
* [DataFactory Linked Service CosmosDb](DataFactory/datafactory-linkedservice-cosmosdb.md)
* [Keyvault](keyvault.md)
* [Keyvault Access Policy](KeyVault/keyvault-access-policy.md)
* [Keyvault Certificates](KeyVault/keyvault-certificates.md)
* [Keyvault Secrets](KeyVault/keyvault-secrets.md)
* [Network](network.md)
* [Public IP Address](public-ip.md)
* [Redis Cache](redis.md)
* [Service Bus](ServiceBus/service-bus.md)
* [Service Bus Firewall vNet Rule](ServiceBus/servicebus-firewall-vnetrule.md)
* [Service Bus Queue Auth Rule](ServiceBus/servicebus-queue-authrule.md)
* [Service Bus Topic](ServiceBus/servicebus-topic.md)
* [Service Bus Topic Subscription](ServiceBus/servicebus-topic-subscription.md)
* [Service Bus Topic Auth Rule](ServiceBus/servicebus-topic-authrule.md)
* [SQL Server Managed Instance](sql-managed-instance.md)
* [SQL Server](sql-server.md)
* [SQL Database](SqlServer/sql-database.md)
* [Storage Account](storage-account.md)
* [Storage Account Container](Storage/storage-account-arm-container.md)
* [Action Groups](Application-Insights/action-groups.md)
* [Failure Anomaly alerting rules](Application-Insights/failure-anomaly-rule.md)
* [Metric Alerts](Application-Insights/metric-alerts.md)
* [Slack Alert logic App](Application-Insights/slack-alerts-logic-app.md)
