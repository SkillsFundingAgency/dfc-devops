$script:PathApiUrl = $null
$script:RegionApiUrl = $null

function New-RegistrationContext {
<#
.SYNOPSIS
Set-up the registration api configuration

.DESCRIPTION
Set-up the registration api configuration

.PARAMETER PathApiUrl
Url for the Path registration API

.PARAMETER RegionApiUrl
Url for the Region registration API

.EXAMPLE
 New-RegistrationContext -PathApiUrl "https://api.example.com/path/api" -RegionApiUrl "https://api.example.com/region/api"
#>
    param(
        [Parameter(Mandatory=$true)]
        [string] $PathApiUrl,
        [Parameter(Mandatory=$true)]
        [string] $RegionApiUrl
    )

    $script:PathApiUrl = $PathApiUrl
    $script:RegionApiUrl = $RegionApiUrl
}

[CmdletBinding]
Push-Location -Path $PSScriptRoot\..\PSScripts\
Import-Module $PSScriptRoot\..\PSModules\AzureApiFunctions
function Invoke-CompositeApiRegistrationRequest
{
<#
.SYNOPSIS
Invoke a request against one of the composite registration apis

.DESCRIPTION
Invoke a request against one of the composite registration apis

Plesae see the following for more information:

https://skillsfundingagency.atlassian.net/wiki/spaces/DFC/pages/1349779557/Composite+UI+Registration+Paths+API
https://skillsfundingagency.atlassian.net/wiki/spaces/DFC/pages/1353252872/Composite+UI+Registration+Regions+API
https://skillsfundingagency.atlassian.net/wiki/spaces/DFC/pages/423231525/DSS+HTTP+response+codes

.PARAMETER Url
Url to the entity

.EXAMPLE
Invoke-CompositeApiRegistrationApiRequest -Url "https://api.example.com/path/somepath" -Method Get
#>

    param(
        [Parameter(Mandatory=$true)]
        [string] $Url,
        [Parameter(Mandatory=$true)]
        [string] $Method,
        [string] $RequestBody
    )

    Write-Verbose "Performing $Method request against '$Url'."

    switch($Method) {
        "GET" {
            $result = Invoke-WebRequest -Method Get -Uri $Url -UseBasicParsing

            if($result.StatusCode -eq 204) { 
                return $null
            }    
    
            $entity = ConvertFrom-Json $result.Content
    
            return $entity
        }
        "POST" {
            $result = Invoke-WebRequest -Method Post -Uri $Url -Body $RequestBody -UseBasicParsing

            if($result.StatusCode -eq 201) { 
                $entity = ConvertFrom-Json $result.Content
    
                return $entity    
            }

            return $null
        }
        "PATCH" {
            $result = Invoke-WebRequest -Method Patch -Uri $Url -Body $RequestBody -UseBasicParsing

            if($result.StatusCode -eq 200) { 
                $entity = ConvertFrom-Json $result.Content
    
                return $entity    
            }

            return $null
        }
    }
}

[CmdletBinding]
function Get-PathRegistration
{
<#
.SYNOPSIS
Get a path from the path registration

.DESCRIPTION
Get a path from the path registration

.PARAMETER Path
The name of the Path registration

.EXAMPLE
Get-PathRegistration -Path somepath
#>    
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path
    )

    $finalUrl = "$($script:PathApiUrl)/paths/$($Path)"

    return Invoke-CompositeApiRegistrationRequest -Url $finalUrl -Method Get
}

[CmdletBinding]
function Get-RegionRegistration
{
<#
.SYNOPSIS
Get a region from the path registration by path name and region

.DESCRIPTION
Get a region from the path registration by path name and region

.PARAMETER Path
The name of the path registration

.PARAMETER PageRegion
The region identifier

.EXAMPLE
Get-RegionRegistration -Path somepath -PageRegion 1
#> 
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,
        [Parameter(Mandatory=$true)]
        [int] $PathRegion
    ) 

    $finalUrl = "$($script:RegionApiUrl)/paths/$($Path)/regions/$($PathRegion)"

    return Invoke-CompositeApiRegistrationRequest -Url $finalUrl -Method Get
}

function New-PathRegistration
{
<#
.SYNOPSIS
Creates a new path registration

.DESCRIPTION
Creates a new path registration

.PARAMETER Path
An object containing the path to be created

.EXAMPLE

$pathObject = @{
    Path = "somePath"
    Layout = 1
}

New-PathRegistration -Path $pathObject
#> 
    param(
        [Parameter(Mandatory=$true)]
        [object] $Path
    )

    if($null -eq $Path.Path) { throw "Path not specified" }
    if($null -eq $Path.Layout) { throw "Layout is mandatory when creating a page registration."}
    if($null -eq $Path.IsOnline) { $Path.IsOnline = $true }
    
    $requestBody = @{
        Path = $Path.Path
        TopNavigationText = $Path.TopNavigationText
        TopNavigationOrder = $Path.TopNavigationOrder
        Layout = $Path.Layout
        IsOnline = $Path.IsOnline
        OfflineHTML = $Path.OfflineHtml
        PhaseBannerHtml = $Path.PhaseBannerHtml
        ExternalUrl = $Path.ExternalUrl
        SitemapURL = $Path.SitemapUrl
        RobotsURL = $Path.RobotsUrl
    }

    $requestBodyText = $requestBody | ConvertTo-Json

    $finalUrl = "$($script:PathApiUrl)/paths"

    return Invoke-CompositeApiRegistrationRequest -Url $finalUrl -Method Post -RequestBody $requestBodyText
}

function New-RegionRegistration
{
<#
.SYNOPSIS
Creates a new region registration

.DESCRIPTION
Creates a new region registration

.PARAMETER Path
The path that the region belongs to

.PARAMETER Region
An object containing the region to be created

.EXAMPLE

$regionObject = @{
    PageRegion = 1
}

New-RegionRegistration -Path somePath -Region $regionObject
#> 
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,
        [Parameter(Mandatory=$true)]
        [object] $Region
    )

    if($null -eq $Region.PageRegion) { throw "PageRegion is not set for a region on path $Path."}
    if($null -eq $Region.HealthCheckRequired) { 
        $Region | Add-Member -NotePropertyName HealthCheckRequired -NotePropertyValue $true 
    }

    if($null -eq $Region.IsHealthy) { 
        $Region | Add-Member -NotePropertyName IsHealthy -NotePropertyValue $true 
    }

    $requestBody = @{
        Path = $Path
        PageRegion = $Region.PageRegion
        IsHealthy = $Region.IsHealthy
        RegionEndpoint = $Region.RegionEndpoint
        HeathCheckRequired = $Region.HealthCheckRequired
        OfflineHTML = $Region.OfflineHtml
    }

    $requestBodyText = $requestBody | ConvertTo-Json

    $finalUrl = "$($script:RegionApiUrl)/paths/$Path/regions"

    return Invoke-CompositeApiRegistrationRequest -Url $finalUrl -Method Post -RequestBody $requestBodyText    
}

function Update-PathRegistration
{
<#
.SYNOPSIS
Patches a existing path registration

.DESCRIPTION
Patches a existing path registration.  Only fields that are passed in will be changed!

.PARAMETER Path
The path of the path registration to update.

.PARAMETER ItemsToUpdate
A dictionary containing items to update.
Note that this *must* contain at least the name of the path registration itself.

.EXAMPLE
$itemsToUpdate = @{
    Path = "somePath"
    Layout = 1
}

Update-PathRegistration -Path somePath -ItemsToUpdate $itemsToUpdate
#> 
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,
        [Parameter(Mandatory=$true)]
        [object] $ItemsToUpdate
    )

    $requestBodyText = $itemsToUpdate | ConvertTo-Json

    $finalUrl = "$($script:PathApiUrl)/paths/$Path"
    
    return Invoke-CompositeApiRegistrationRequest -Url $finalUrl -Method Patch -RequestBody $requestBodyText    
}

function Update-RegionRegistration
{
<#
.SYNOPSIS
Patches a existing region registration

.DESCRIPTION
Patches a existing region registration.  
Only fields in ItemsToUpdate will be changed.

.PARAMETER Path
The path of the region registration to update.

.PARAMETER ItemsToUpdate
A dictionary containing items to update.
Note that this *must* contain at least the name of the path registration itself.

.EXAMPLE
$itemsToUpdate = @{
    Path = "somePath"
    Layout = 1
}

Update-RegionRegistration -Path somePath -PathRegion 1 -ItemsToUpdate $itemsToUpdate
#> 
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,
        [Parameter(Mandatory=$true)]
        [int] $PageRegion,
        [Parameter(Mandatory=$true)]
        [object] $ItemsToUpdate
    )

    $requestBodyText = $ItemsToUpdate | ConvertTo-Json

    $finalUrl = "$($script:RegionApiUrl)/paths/$($Path)/regions/$($PageRegion)"

    return Invoke-CompositeApiRegistrationRequest -Url $finalUrl -Method Patch -RequestBody $requestBodyText
}

function Get-DifferencesBetweenPathObjects {
<#
.SYNOPSIS
Gets the difference between the current Path registration from the API and the wanted registration from the configuration file

.DESCRIPTION
Gets the difference between the current Path registration from the API and the wanted registration from the configuration file

.PARAMETER ObjectFromApi
The Path entity as loaded from the API using Get-PathRegistration

.PARAMETER ObjectFromFile
The Path entity loaded from the configuration file

.EXAMPLE
$configurationEntities = Get-Content -Path ./registration.json | ConvertFrom-Json

$entityFromApi = Get-PathRegistration -Path SomePath
$entityFromFile = $configurationEntities[0]

$itemsToUpdate = Get-DifferencesBetweenPathObjects -ObjectFromApi $entityFromApi -ObjectFromFile $entityFromFile
#>
    param(
        [Parameter(Mandatory=$true)]
        [object] $ObjectFromApi,
        [Parameter(Mandatory=$true)]
        [object] $ObjectFromFile
    )
    if($null -eq $ObjectFromFile.Path) { throw "Path not specified" }
    if($null -eq $ObjectFromFile.Layout) { throw "Layout is mandatory when creating a path registration for path '$($ObjectFromFile.Path)'."}
    if($null -eq $ObjectFromFile.IsOnline) { 
        $ObjectFromFile | Add-Member -NotePropertyName IsOnline -NotePropertyValue $true
     }

    $itemsToUpdate = @{
        Path = $ObjectFromFile.Path
    }
        
    if($ObjectFromApi.TopNavigationText -ne $ObjectFromFile.TopNavigationText) {
        $itemsToUpdate["TopNavigationText"] = $ObjectFromFile.TopNavigationText
    }

    if($ObjectFromApi.TopNagivationOrder -ne $ObjectFromFile.TopNagivationOrder) {
        $itemsToUpdate["TopNavigationOrder"] = $ObjectFromFile.TopNagivationOrder
    }

    if($ObjectFromApi.Layout -ne $ObjectFromFile.Layout) {
        $itemsToUpdate["Layout"] = $ObjectFromFile.Layout
    }

    if($ObjectFromApi.IsOnline -ne $ObjectFromFile.IsOnline) {
        $itemsToUpdate["IsOnline"] = $ObjectFromFile.IsOnline
    }

    if($ObjectFromApi.OfflineHTML -ne $ObjectFromFile.OfflineHTML) {
        $itemsToUpdate["OfflineHTML"] = $ObjectFromFile.OfflineHTML
    }

    if($ObjectFromApi.PhaseBannerHtml -ne $ObjectFromFile.PhaseBannerHtml) {
        $itemsToUpdate["PhaseBannerHtml"] = $ObjectFromFile.PhaseBannerHtml
    }    

    if($ObjectFromApi.ExternalUrl -ne $ObjectFromFile.ExternalUrl) {
        $itemsToUpdate["ExternalUrl"] = $ObjectFromFile.ExternalUrl
    }    

    if($ObjectFromApi.SitemapURL -ne $ObjectFromFile.SitemapURL) {
        $itemsToUpdate["SitemapURL"] = $ObjectFromFile.SitemapURL
    }    
    
    if($ObjectFromApi.RobotsURL -ne $ObjectFromFile.RobotsURL) {
        $itemsToUpdate["RobotsURL"] = $ObjectFromFile.RobotsURL
    }    

    return $itemsToUpdate
}

function Get-DifferencesBetweenRegionObjects {
    <#
    .SYNOPSIS
    Gets the difference between the current Region registration from the API and the wanted registration from the configuration file
    
    .DESCRIPTION
    Gets the difference between the current Region registration from the API and the wanted registration from the configuration file
    
    .PARAMETER ObjectFromApi
    The Path entity as loaded from the API using Get-RegionRegistration
    
    .PARAMETER ObjectFromFile
    The Path entity loaded from the configuration file
    
    .EXAMPLE
    $configurationEntities = Get-Content -Path ./registration.json | ConvertFrom-Json
    
    $entityFromApi = Get-RegionRegistration -Path SomePath -PageRegion 1
    $entityFromFile = $configurationEntities[0].Region[0]
    
    $itemsToUpdate = Get-DifferencesBetweenRegionObjects -ObjectFromApi $entityFromApi -ObjectFromFile $entityFromFile
    #>
    param(
        [Parameter(Mandatory=$true)]
        [object] $ObjectFromApi,
        [Parameter(Mandatory=$true)]
        [object] $ObjectFromFile
    )

    if($null -eq $ObjectFromFile.PageRegion) { throw "PageRegion is not set and is required"}
    if($null -eq $ObjectFromFile.IsHealthy) { 
        $ObjectFromFile | Add-Member -NotePropertyName IsHealthy -NotePropertyValue $true
    }
    if($null -eq $ObjectFromFile.HealthCheckRequired) { 
        $ObjectFromFile | Add-Member -NotePropertyName HealthCheckRequired -NotePropertyValue $true
    }

    $itemsToUpdate = @{
        Path = $ObjectFromApi.Path
        PageRegion = $ObjectFromApi.PageRegion
    }
    
    if($ObjectFromApi.IsHealthy -ne $ObjectFromFile.IsHealthy) {
        $itemsToUpdate["IsHealthy"] = $ObjectFromFile.IsHealthy
    }

    if($ObjectFromApi.RegionEndpoint -ne $ObjectFromFile.RegionEndpoint) {
        $itemsToUpdate["RegionEndpoint"] = $ObjectFromFile.RegionEndpoint
    }

    if($ObjectFromApi.HealthCheckRequired -ne $ObjectFromFile.HealthCheckRequired) {
        $itemsToUpdate["HealthCheckRequired"] = $ObjectFromFile.HealthCheckRequired
    }

    if($ObjectFromApi.OfflineHTML -ne $ObjectFromFile.OfflineHtml) {
        $itemsToUpdate["OfflineHTML"] = $ObjectFromFile.OfflineHtml
    } 
    
    return $itemsToUpdate
}
