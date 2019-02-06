# CDN Endpoint

Creates a CDN Endpooint.  A CDN Profile must already exist (see cdn-profile.md).  This template has been tested with the Microsoft SKU, refactoring may be required for it to work with other SKUs.

## Parameters

cdnProfileName (required) string

cdnEndPointName (required) string

originHostName (required) string

optimizationType (optional) string

Defaults to GeneralWebDelivery, select from GeneralWebDelivery, GeneralMediaStreaming, VideoOnDemandMediaStreaming, LargeFileDownload, DynamicSiteAcceleration

customDomainName (optional) string

Omit the protocol (ie https://) when setting this property

isHttpAllowed (optional) bool

Defaults to false (disabled)

queryStringCachingBehavior (optional) string

Defaults to IgnoreQueryString, select from NotSet, IgnoreQueryString, UseQueryString, BypassCaching

originPath (optional) string