# Application Gateway v2

Adds an Application Gateway v2

## parameters

appGatewayName: (required) string

Name of the application gateway resource to create

subnetRef: (required) string

The subnet resource ID where the application gateway will go.

If you have the vnet and subnet names, you can get the ID with the following function
`resourceId('Microsoft.Network/virtualNetworks/subnets', 'vnet', 'subnet')`

appGatewayTier: (optional) string

Application gateway type and instance size combined
Must be either Standard_v2 or WAF_v2.
Defaults to Standard_v2.

Be aware that the Web Application Firewall option, WAF_v2, adds considerable overhead to the App Gateway.
Ensure load testing is done before using WAF option. 

backendPools: (required) array of object

A list of backend pools to create.
The first backend pool specified will be the default one (used if not routing)

Each backend is specified by an object consisting of

* name: string
  The name the backend pool resource
* fqdn: string
  The full domain name

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

* name: string
  The name the backend setting
* port: int
  Port number the backend
* protocol: string
  Protocol type, either Http or Https
* hostnameFromBackendAddress: bool
  Select hostname from backend address. Normally set to true for any PaaS service (like app services).
* timeout: (optional) int
  Set the request timeout in seconds. Defaults to 20 seconds.
* backendPath: (optional) string
  Override the backend path, no override if not specified
* probeName: (optional) string
  Name of probe as specified in customProbes
* authCerts: (optional) array of string
  Authentication certificates
* rootCerts: (optional) array of string
  Array of trusted root certificates

For more details see https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2019-04-01/applicationgateways#ApplicationGatewayBackendHttpSettingsPropertiesFormat

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

* name: string
  The name the backend pool resource
* backendPool: string
  The name of the backend to route to (as specified in a previous parameter, see above)
* backendHttp: string
  The name of the backend http settings to use (as specified in the previous parameter, see above)
* paths: array of string
  An array of paths, usually wildcarded, to route to this backend

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
See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2019-04-01/applicationgateways#ApplicationGatewayProbe
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
See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2019-04-01/applicationgateways#ApplicationGatewayCustomError
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

Each rewrite rule is specified by an object consisting of

* name: string
  The name the rewrite rule set
* ruleSequence: (optional) int
  Specifies the order to run the rules (lowest to highest) - defaults to 100 if not specified
* conditions: (optional) array of object
  An array of objects specifying the conditions that need to be met for the rule to be applied - rules are always ran if no conditions are specified
* actionSet: object
  An objects with either requestHeaderConfigurations or responseHeaderConfigurations arrays specifying action of the rule

An example of a valid object which rewrites location header. Only name and actionSet are required.

```json
{
    "name": "rewriteLocationRule",
    "ruleSequence": 100,
    "conditions": [ { 
        "variable": "http_resp_Location",
        "pattern": "(https?):\\/\\/example\\.net(.*)$",
        "ignoreCase": true

     } ], 
    "actionSet": {
        "responseHeaderConfigurations": [ {
            "headerName": "Location",
            "headerValue": "{http_resp_Location_1}redirect_uri=https%3a%2f%2f__appGatewayFqdn__{http_resp_Location_3}"
        } ]
    }
}
```

See https://docs.microsoft.com/en-us/azure/templates/microsoft.network/2019-04-01/applicationgateways#ApplicationGatewayRewriteRuleActionSet
for rule settings via the actionSet object.

capacity: (optional) int

Number of instances of the application gateway to run.
Must be at least 2.
Defaults to 2 if not supplied.

privateIpAddress: (optional) string

Private IP address to allocate to the application gateway.
If not specified, no private IP address will be assigned to the app gateway.
At least one of privateIpAddress or publicIpAddressId must be supplied.

publicIpAddressId: (required) string

Public IP address resource. v2 App Gateways require a public IP address (older v1 ones didnt).
At least one of privateIpAddress or publicIpAddressId must be supplied.

httpFrontendPort: (optional) int

The port the application gateway is accessible on via HTTP.
Defaults to port 80 if not specified.

httpsFrontendPort: (optional) int

The port the application gateway is accessible on via HTTPS.
Defaults to port 443 if not specified.

keyVaultName: (optional) string

Name of key vault to get the SSL certificate from.
Will only add SSL options if keyVaultName, keyVaultSecretName and userAssignedIdentityName are supplied.

keyVaultSecretName: (optional) string

Name of secret in key vault containing the SSL certificate.
Will only add SSL options if keyVaultName, keyVaultSecretName and userAssignedIdentityName are supplied.

userAssignedIdentityName: (required) string

Name of assigned identity with secret read access to the key vault.
Because the app gateway is created under this identity it is required even if keyVaultName, keyVaultSecretName and userAssignedIdentityName are not supplied.

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
Will not archive logs if no storage account is specified.
Either this or logWorkspaceId needs to be specified in order to enable diagnostics.

logWorkspaceId: (optional) string

Op Insight Workspace (OMS) Id to send all logs to.
Will not send logs to a workspace if no workspace is specified.
Either this or logStorageAccountId needs to be specified in order to enable diagnostics.

logRetention: (optional) int

Number of days to retain logs for.
Defaults to 0 - retention policy disabled.
Only used if diagnostics is enabled.
