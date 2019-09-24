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

.PARAMETER Method
The HTTP method to use to call the given URL

.PARAMETER RequestBody
A body to send as part of Post and Patch requests.

.EXAMPLE
Invoke-CompositeApiRegistrationApiRequest -Url "https://api.example.com/path/somepath" -Method Get
#>

    param(
        [Parameter(Mandatory=$true)]
        [string] $Url,
        [Parameter(Mandatory=$true)]
        [ValidateSet("GET", "PATCH", "POST")]
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
            $result = Invoke-WebRequest -Method Post -Uri $Url -Body $RequestBody -Headers @{ "Content-Type" = "application/json" } -UseBasicParsing

            if($result.StatusCode -eq 201) { 
                $entity = ConvertFrom-Json $result.Content
    
                return $entity    
            }

            return $null
        }
        "PATCH" {
            $result = Invoke-WebRequest -Method Patch -Uri $Url -Body $RequestBody -Headers @{ "Content-Type" = "application/json" } -UseBasicParsing

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
        [int] $PageRegion
    ) 

    $finalUrl = "$($script:RegionApiUrl)/paths/$($Path)/regions/$($PageRegion)"

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
        OfflineHtml = $Path.OfflineHtml
        PhaseBannerUrl = $Path.PhaseBannerHtml
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
 
    $itemsToPatch = [array] @()

    foreach($item in $ItemsToUpdate.Keys) {
        if($item -eq "Path") { continue }

        $itemsToPatch += @{
            "op" = "Replace"
            "path" = "/$($item)"
            "value" = $ItemsToUpdate[$item]
        }
    }

    $requestBodyText = ConvertTo-Json $itemsToPatch

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
Gets the difference between two Path registration objects

.DESCRIPTION
Gets the difference between the two Path registration objects, taking the properties from 
the Right object if differences are detected

.PARAMETER Left
The left hand path registration object

.PARAMETER Right
The right hand path registration object

.EXAMPLE
$configurationEntities = Get-Content -Path ./registration.json | ConvertFrom-Json

$entityFromApi = Get-PathRegistration -Path SomePath
$entityFromFile = $configurationEntities[0]

$itemsToUpdate = Get-DifferencesBetweenPathObjects -Left $entityFromApi -Right $entityFromFile
#>
    param(
        [Parameter(Mandatory=$true)]
        [object] $Left,
        [Parameter(Mandatory=$true)]
        [object] $Right
    )
    if($null -eq $Right.Path) { throw "Path not specified" }
    if($null -eq $Right.Layout) { throw "Layout is mandatory when creating a path registration for path '$($Right.Path)'."}
    if($null -eq $Right.IsOnline) { 
        $Right | Add-Member -NotePropertyName IsOnline -NotePropertyValue $true
     }

    $itemsToUpdate = @{
        Path = $Left.Path
    }
        
    if($Left.TopNavigationText -ne $Right.TopNavigationText) {
        $itemsToUpdate["TopNavigationText"] = $Right.TopNavigationText
    }

    if($Left.TopNagivationOrder -ne $Right.TopNagivationOrder) {
        $itemsToUpdate["TopNavigationOrder"] = $Right.TopNagivationOrder
    }

    if($Left.Layout -ne $Right.Layout) {
        $itemsToUpdate["Layout"] = $Right.Layout
    }

    if($Left.IsOnline -ne $Right.IsOnline) {
        $itemsToUpdate["IsOnline"] = $Right.IsOnline
    }

    if($Left.OfflineHtml -ne $Right.OfflineHtml) {
        $itemsToUpdate["OfflineHtml"] = $Right.OfflineHtml
    }

    if($Left.PhaseBannerHtml -ne $Right.PhaseBannerHtml) {
        $itemsToUpdate["PhaseBannerHtml"] = $Right.PhaseBannerHtml
    }

    if($Left.ExternalUrl -ne $Right.ExternalUrl) {
        $itemsToUpdate["ExternalUrl"] = $Right.ExternalUrl
    }    

    if($Left.SitemapURL -ne $Right.SitemapURL) {
        $itemsToUpdate["SitemapURL"] = $Right.SitemapURL
    }

    if($Left.RobotsURL -ne $Right.RobotsURL) {
        $itemsToUpdate["RobotsURL"] = $Right.RobotsURL
    }

    return $itemsToUpdate
}

function Get-DifferencesBetweenRegionObjects {
    <#
    .SYNOPSIS
    Gets the difference between two region registration objects

    .DESCRIPTION
    Gets the difference between the two region registration objects, taking the properties from 
    the Right object if differences are detected

    
    .PARAMETER Left
    The left hand region registration object
    
    .PARAMETER Right
    The right hand region registration object
    
    .EXAMPLE
    $configurationEntities = Get-Content -Path ./registration.json | ConvertFrom-Json
    
    $entityFromApi = Get-RegionRegistration -Path SomePath -PageRegion 1
    $entityFromFile = $configurationEntities[0].Region[0]
    
    $itemsToUpdate = Get-DifferencesBetweenRegionObjects -ObjectFromApi $entityFromApi -ObjectFromFile $entityFromFile
    #>
    param(
        [Parameter(Mandatory=$true)]
        [object] $Left,
        [Parameter(Mandatory=$true)]
        [object] $Right
    )

    if($null -eq $Right.PageRegion) { throw "PageRegion is not set and is required"}
    if($null -eq $Right.IsHealthy) { 
        $Right | Add-Member -NotePropertyName IsHealthy -NotePropertyValue $true
    }
    if($null -eq $Right.HealthCheckRequired) { 
        $Right | Add-Member -NotePropertyName HealthCheckRequired -NotePropertyValue $true
    }

    $itemsToUpdate = @{
        Path = $Left.Path
        PageRegion = $Left.PageRegion
    }
    
    if($Left.IsHealthy -ne $Right.IsHealthy) {
        $itemsToUpdate["IsHealthy"] = $Right.IsHealthy
    }

    if($Left.RegionEndpoint -ne $Right.RegionEndpoint) {
        $itemsToUpdate["RegionEndpoint"] = $Right.RegionEndpoint
    }

    if($Left.HealthCheckRequired -ne $Right.HealthCheckRequired) {
        $itemsToUpdate["HealthCheckRequired"] = $Right.HealthCheckRequired
    }

    if($Left.OfflineHTML -ne $Right.OfflineHtml) {
        $itemsToUpdate["OfflineHTML"] = $Right.OfflineHtml
    } 
    
    return $itemsToUpdate
}
