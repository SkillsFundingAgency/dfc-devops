# Service Bus IP Filter

Creates a Service Bus IP filter.  Any IP filters should be deployed after VNet rules (by creating a dependancy) to prevent the deployment of the VNet rule removing the IP filter(s).
This template relies on an ARM resource that is still in preview (though IP filters themselve are GA).

## Parameters

action (required) string

Values can be Accept or Deny

ipAddress (required) string

A single IP address from which traffic will either be accepted or denied.
Adding an Accept filter for 0.0.0.0 will allow access by all Azure resources
Adding Accept filters for 104.42.195.92, 40.76.54.131, 52.176.6.30, 52.169.50.45 and 52.187.184.26 will all access via the Azure Portal

servicebusName (required) string

The name of the ServiceBus to apply the rule to.  The ServiceBus must be on the Premium SKU.

## Example

This example will allow access to the ServiceBus from the Azure Portal and an ASE if the ASE's IP address is passed in as a parameter.  It will not allow access from other Azure resources.

```
    "parameters": {
        "aseOutboundIpAddress": {
            "type": "string,
            "defaultValue": ""
        }
    }
    "variables": {
        "allowedIpAddresses": "[createArray('104.42.195.92','40.76.54.131','52.176.6.30','52.169.50.45','52.187.184.26', parameters('aseOutboundIpAddress'))]"
    },
    "resouces": [
        {
            "name": "[concat('fooSharedServiceBusIpFilters-', copyIndex())]",
            "type": "Microsoft.Resources/deployments",
            "condition": "[greater(length(parameters('aseOutboundIpAddress')), 0)]",
            "apiVersion": "2017-05-10",
            "properties": {
                "mode": "Incremental",
                "templateLink": {
                    "uri": "[concat(variables('deploymentUrlBase'),'ServiceBus/servicebus-ipfilter.json')]",
                    "contentVersion": "1.0.0.0"
                },
                "parameters": {
                    "action": {
                        "value": "Accept"
                    },
                    "ipAddress": {
                        "value": "[variables('allowedIpAddresses')[copyIndex()]]"
                    },
                    "servicebusName": {
                        "value": "[variables('servicebusName')]"
                    }
                }
            },
            "dependsOn": [
                "fooSharedServiceBus"
            ],
             "copy": {
                 "name": "ipFilterRuleCopy",
                 "count": "[length(variables('allowedIpAddresses'))]"
             }
        }
    ]
```

## Notes

This ARM resource is in preview (though configuring the resource via the Azure Portal is GA).  There is limited documentation, the documentation used to create this template can be found [here](https://azure.microsoft.com/en-gb/blog/ip-filtering-for-event-hubs-and-service-bus/) and more documentation can be found [here](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-ip-filtering)