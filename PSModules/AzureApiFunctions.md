# AzureApiFunctions

Functions to reduce boilerplate code when calling Azure API functions.

## ApiRequest

Wrapper around Invoke-WebRequest.
Settings application type to JSON and adds the API key to the header.
Converts the response from the JSON text to an object.
Will throw the same exceptions as Invoke-WebRequest.

### Parameters

**Url**
API URL including protocol.
Example: http://api.example.com/endpoint

**ApiKey**
API key for the REST API

**Method**
Optional HTTP method (verb) for accessing the API endpoint.
Normally this will be one of GET, POST, PUT, PATCH or DELETE.
Defaults to GET

**ApiVersion**
Optional, changes the API version passed to the API as part of the URL.
Defaults to 2017-11-11

**Body**
Optional hash to send as the body (in JSON format)
Should only be used with POST, PUT or PATCH