# Composite Registration Functions

Functions to assist in the registration of composite applications to the path and region APIs.

## New-RegistrationContext

Create a new path and region registration context

### Parameters

**PathApiUrl**
The URL to the Path Registration API

**RegionApiUrl**
The URL to the Region Registration API

## Invoke-CompositeApiRegistrationRequest

Perform a request to one of the composite APIs

### Parameters

**Url**
The URL to access

**Method**
The HTTP Method to use

**RequestBody**
For Post and Patch requests, an object to send as part of the request.

## Get-PathRegistration

Fetches a path registration from the API

### Parameters

**Path**
The Path to fetch

## Get-RegionRegistration

Fetches a region registration from the API

### Parameters

**Path**
The Path to fetch

**PageRegion**
The Page Region to fetch

## New-PathRegistration

Creates a new path registration

### Parameters

**Path**
An object that describes the path setup.
This must contain properties for 'Path', and 'Layout', and may contain the following properties:

    * TopNavigationText
    * TopNavigationOrder
    * IsOnline
    * OfflineHtml
    * PhaseBannerUrl
    * ExternalUrl
    * SitemapUrl
    * RobotsUrl

## New-RegionRegistration

Creates a new region registration

### Parameters

**Path**
The Path that the new region is associated with

**Region**
An object that describes the region setup.
This must contain a property called 'PageRegion', and may contain the following properties:

    * PageRegion
    * IsHealthy
    * RegionEndpoint
    * HealthCheckRequired
    * OfflineHtml

## Update-PathRegistration

Updates a path registration

### Parameters

**Path**
The Path to update

**ItemsToUpdate**
An object containing properties to update. 
See New-PathRegistration for valid property names.

## Update-RegionRegistration

Update a region registration

### Parameters

**Path**
The Path to update

**PageRegion**
The PageRegion to update

**ItemsToUpdate**
An object containing properties to update.
See New-RegionRegistration for valid property names.

## Get-DifferencesBetweenPathObjects

Gets the difference between the two Path registration objects, taking the properties from 
the Right object if differences are detected

## Parameters

**Left** 
The left hand page registration object

**Right**
The right hand page registration object

## Get-DifferencesBetweenRegionObjects

Gets the difference between the two reguion registration objects, taking the properties from 
the Right object if differences are detected

## Parameters

**Left** 
The left hand region registration object

**Right**
The right hand region registration object