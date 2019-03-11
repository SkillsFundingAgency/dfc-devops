# API Management API

Creates an APIM API and optionaly connects to a logger and adds to a product.  Both must already exist and dependencies should be set on the parent template.

## Parameters

apimServiceName (required) string

The name of the API Management Service this API will be added to.

apiName (required) string

The name of the API.

apimProductInstanceName (optional) string

The name of a product that this API should be added to.  The product must already exist and should be created using the apim-product template.

apimLoggerName (optional) string

The name of an apim logger that requests to this API will be logged against.

apiVersion (optional) string

The version of the API.  A version set will need to be created separartely.

apiSuffix (optional) string

Relative URL uniquely identifying this API and all of its resource paths within the API Management service instance.
It is appended to the API base URL and appears before the path for the API.
Defaults to the apiName if not specified.

loggerSamplingPercentage (optional) string

Defaults to 100, only applied if apimLoggerName is set.

oauthAuthenticationServer (optional) string

The name of an APIM authentication server, this will need to be create separately.