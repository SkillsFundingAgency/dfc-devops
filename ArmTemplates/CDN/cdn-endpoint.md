# CDN Endpoint

Creates a CDN Endpooint.
A CDN Profile must already exist (see cdn-profile.md) and this must be ran in the same resource group as that resource.

## Parameters

cdnProfileName (required) string

Existing CDN profile name

cdnEndPointName (required) string

Name of endpoint to create.
This must be globally unique and can only consist of letters, numbers or hypens (a hyphen cannot be the first or last character).

originHostName (required) string

URL to get the content from.

cacheExpirationOverride (optional) string

The cache expiration to set in days when setting the Caching behaviour to Override.  Setting this parameter will add the CacheExpiration Delivery Policy which is documented [here](https://docs.microsoft.com/en-us/rest/api/cdn/endpoints/create#deliveryrulecacheexpirationaction)

optimizationType (optional) string

Defaults to GeneralWebDelivery, select from GeneralWebDelivery, GeneralMediaStreaming, VideoOnDemandMediaStreaming, LargeFileDownload, DynamicSiteAcceleration

customDomainName (optional) string

Omit the protocol (ie https://) when setting this property

isHttpAllowed (optional) bool

Defaults to false (disabled)

queryStringCachingBehavior (optional) string

Defaults to IgnoreQueryString, select from NotSet, IgnoreQueryString, UseQueryString, BypassCaching

originPath (optional) string