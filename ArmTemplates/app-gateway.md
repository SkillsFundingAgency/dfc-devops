# Application Gateway

Adds an application gateway

## parameters

appGatewayName: (required) string

Name of the application gateway resource to create

subnetRef: (required) string

The subnet resource ID where the application gateway will go.

If you have the vnet and subnet names, you can get the ID with the following function
`resourceId('Microsoft.Network/virtualNetworks/subnets', 'vnet', 'subnet')`

appGatewayTier: (optional) string

Application gateway type and instance size combined

Must be one of Standard_Small (default if none supplied), Standard_Medium, Standard_Large, WAF_Medium, WAF_Large, Standard_v2 or WAF_v2

backendPools: (required) array of object

A list of backend pools to create.
The first backend pool specified will be the default one (used if not routing)

Each backend is specified by an object consisting of

* name: the name the backend pool resource
* fqdn: the full domain name

An example of a valid object

```json
{
    "name": "backendName",
    "fqdn": "be.example.net"
}
```

backendHttpSettings: (required) array of object

A list of settings for connecting to the back end application(s).
The first setting in the array is used for the default routing rule.

Each backend setting is specified by an object consisting of

* name: the name the backend setting
* port: port
* protocol: protocol
* hostnameFromBackendAddress: Select hostname from backend address
* timeout: set the request timeout (optional)
* backendPath: override the backend path (optional)
* probeName: name of probe (optional)
* authCerts: array of authentication certificates (optional)
* rootCerts: array of trusted root certificates (optional)

An example of a valid object

```json
{
    "name": "httpSettingName",
    "port": 443,
    "protocol": "Https",
    "hostnameFromBackendAddress": true
}
```

routingRules: (required) array of object

A list of routing rules describing which paths should be routed to which backend pool.
If the path does not match any rule provided it will go to the default backend pool,
which is the first backend specified (see above).

Each backend is specified by an object consisting of

* name: the name the backend pool resource
* backendPool: the name of the backend to route to (as specified in a previous parameter, see above)
* backendHttp: the name of the backend http settings to use (as specified in the previous parameter, see above)
* paths: an array of paths, usually wildcarded, to route to the backend

An example of a valid object

```json
{
    "name": "routingRule",
    "backendPool": "backendName",
    "backendHttp": "httpSettingName",
    "paths": [ "/myapp/*" ]
}
```

customProbes: (optional) array of objects

Create probes for use in backendHttpSettings.
See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2018-11-01/applicationgateways#ApplicationGatewayProbe
for options.

An example of a valid object array

```json
[
    {
        "name": "myProbe",
        "type": "Microsoft.Network/applicationGateways/probes",
        "properties": {
            "protocol": "Https",
            "path": "/",
            "interval": 60,
            "timeout": 30,
            "unhealthyThreshold": 3,
            "pickHostNameFromBackendHttpSettings": true,
            "minServers": 0,
            "match": {
                "statusCodes": [
                    "200-399"
                ]
            }
        }
    }
]
```

customErrorPages: (optional) array of objects

Create probes for use in backendHttpSettings.
See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2018-11-01/applicationgateways#ApplicationGatewayCustomError
for options.

An example of a valid object array

```json
[
    {
        "statusCode": "HttpStatus502",
        "customErrorPageUrl": "https://my.domain/502.html"
    }
]
```

rewriteRules: (optional) array of object

A list of rewrite rules which will be applied to all URL paths.
If not specified, no rewrite rules will be specified.
This is only valid with v2 tiers.

Each rewrite rule is specified by an object consisting of

* name: the name the rewrite rule set
* ruleSequence: an integer specifying the order to run the rules (lowest to highest) - defaults to 100 if not specified
* conditions: an array of objects specifying the conditions that need to be met for the rule to be applied - rules are run unconditionally if not specified
* actionSet: an array of objects specifying actionSet of the rule

An example of a valid object. Only name and actionSet are required.

```json
{
    "name": "rewriteRule",
    "ruleSequence": 100,
    "conditions": { ... }, 
    "actionSet": { ... }
}
```

See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2018-11-01/applicationgateways#ApplicationGatewayRewriteRuleActionSet
for rule settings via the actionSet object.

capacity: (optional) int

Number of instances of the application gateway to run.
Must be at least 2.
Defaults to 2 if not supplied.

privateIpAddress: (optional) string

Private IP address to allocate to the application gateway.
If not specified, no private IP address will be assigned to the app gateway.
At least one of privateIpAddress or publicIpAddressId must be supplied.

publicIpAddressId: (optional) string

An ID of a public IP address resource.
If not specified, no public IP address will be assigned to the app gateway.
At least one of privateIpAddress or publicIpAddressId must be supplied.

httpFrontendPort: (optional) int

The port the application gateway is accessible on via HTTP.
Defaults to port 80 if not specified.

httpsFrontendPort: (optional) int

The port the application gateway is accessible on via HTTP.
Defaults to port 443 if not specified.

keyVaultName: (optional) string

Name of key vault to get the SSL certificate from.
Will only add SSL options if keyVaultName, keyVaultSecretName and userAssignedIdentityName are supplied.

keyVaultSecretName: (optional) string

Name of secret in key vault containing the SSL certificate.
Will only add SSL options if keyVaultName, keyVaultSecretName and userAssignedIdentityName are supplied.

userAssignedIdentityName: (optional) string

Name of assigned identity with secret read access to the key vault.
Will only add SSL options if keyVaultName, keyVaultSecretName and userAssignedIdentityName are supplied.

This can be created in ARM with a Microsoft.ManagedIdentity/userAssignedIdentities resource.
An example

```json
{
    "name": "myidentity",
    "type": "Microsoft.ManagedIdentity/userAssignedIdentities",
    "apiVersion": "2018-11-30",
    "location": "[resourceGroup().location]"
}
```

logStorageAccountId: (optional) string

Storage account Id to archive logs to.
Will not achive logs if no storage account is specified.
Either this or logWorkspaceId needs to be specified in order to enable diagnostics.

logWorkspaceId: (optional) string

Op Insight Workspace (OMS) Id to send all logs to.
Will not send logs to a workspace if no workspace is specified.
Either this or logStorageAccountId needs to be specified in order to enable diagnostics.

logRetention: (optional) int

Number of days to retain logs for.
Defaults to 0 - retention policy disabled.
Only used if diagnostics is enabled.
