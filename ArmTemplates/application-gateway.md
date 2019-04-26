# App Service

Creates an Application Gateway

## Paramaters

appGatewayName: (required) string

Name of the application gateway

subnetRef: (required) string

Resouce ID for the subnet the app gateway will be set up into

Can be calculated with the following ARM template function:
resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)

backendIPAddresses: (optional) array of object

```json
[
    { "ipAddress": "10.0.0.4" },
    { "fqdn": "www.myserver.com" }
]
```