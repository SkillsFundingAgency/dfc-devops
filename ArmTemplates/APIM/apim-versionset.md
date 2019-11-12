# API Management Version Set

Creates a version set for an APIM API.

## Parameters

apimServiceName (required)  string

The name of the API Management Service this version set will be added to.

apiName (required) string

The name of the API.

versioningMethod (required)  string

The method of determining the api version to use.
Can be one of three values:  Header, Query, and Segment.

versionProperty (optional)  string

The name of the query string property or header to select the api version using.  Needs to be specified for Header and Query versioning.
