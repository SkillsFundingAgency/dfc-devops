# CDN Profile

Creates a CDN Profile, use the [CDN Endpoint](CDN/cdn-endpoint.md) to add endpoint(s) to the profile.

## Parameters

cdnProfileName (required) string

The name of the CDN Profile, use the standard organisation-environment-project naming convention with the -cdn suffix.

cdnSKU (optional) string

Defaults to Standard_Verizon, select from Premium_Verizon, Custom_Verizon, Standard_Verizon, Standard_Akamai, Standard_Microsoft