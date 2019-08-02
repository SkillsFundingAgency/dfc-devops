# App Service

Creates an App Service

## Paramaters

appServiceName: (required) string

Name of App Service. Will be created in the same resource group as the script is run and in the default location for resource group.

appServicePlanName: (required) string

Name of the App Service Plan the app will run inside.

appServicePlanResourceGroup: (optional) string

Resource group the App Service Plan resides in.
Will default to Standard if not supplied.

appServiceType: (optional) string

Determines whether a web app (app) or a function app (functionapp) is created.
Creates a web app if not specified.

appServiceAppSettings: (optional) array of object

Array of app settings to be created.
Will not create any app settings if not supplied.
Objects in the array must be of the format.

```json
[
    {
        "name": "",
        "value": ""
    }
]
```

appServiceConnectionStrings: (optional) array of object

Array of connection strings to be created.
Will not create any connection strings if not supplied.
Objects in the array must be of the format.

```json
[
    {
        "name": "",
        "connectionString": "",
        "type": ""
    }
]
```

customHostName: (optional) string

Custom fully qualified domain name for the app service URL.
If not provided then the app service will have the URL https://appServiceName.azurewebsites.net/.

In order to specify a custom domain, a CNAME DNS record must be created referencing appServiceName.azurewebsites.net

certificateThumbprint: (optional) string

Thumbprint of the certificate used.
Only required if the customHostName is supplied above.

This can be passed into the template via the following reference function if an Azure certificate resource has been created:
> [reference(resourceId(parameters('certificateResourceGroup'), 'Microsoft.Web/certificates', parameters('certificateName')), '2016-03-01').Thumbprint]

deployStagingSlot: (optional) boolean

Creates a staging slot.
Defaults to creating a staging slot

clientAffinity: (optional) boolean

Enable ARR Affinity cookie (also known as sticky sessions).
Often required for stateful web applications.
Defaults to not enabled (stateless).

If ARR Affinity is enabled the server will place a cookie on responses that causes a user to always hit the same instance within their session.
This has a load balancing penalty (existing clients cannot be balanced away from an instance running hot) so is disabled by default.
