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

.PARAMETER ApiKey
The Api Key for the APIM instance hosting both apis

.EXAMPLE
 New-RegistrationContext -PathApiUrl "https://api.example.com/path/api" -RegionApiUrl "https://api.example.com/region/api"
#>
    param(
        [Parameter(Mandatory=$true)]
        [string] $PathApiUrl,
        [Parameter(Mandatory=$true)]
        [string] $RegionApiUrl,
        [Parameter(Mandatory=$true)]
        [string] $ApiKey
    )

    $script:PathApiUrl = $PathApiUrl
    $script:RegionApiUrl = $RegionApiUrl
    $script:ApiKey = $ApiKey
}

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

    if (($method -in "POST","PATCH") -and ($RequestBody)) {
        Write-Verbose "With body"
        Write-Verbose $requestBody
    }

    $authHeader = @{"Ocp-Apim-Subscription-Key" = $script:ApiKey }
    $authHeaderWithContentType = @{
        "Ocp-Apim-Subscription-Key" = $script:ApiKey
        "Content-Type" = "application/json"
    }

    switch($Method) {
        "GET" {
            $result = Invoke-WebRequest -Method Get -Uri $Url -UseBasicParsing -Headers $authHeader

            if($result.StatusCode -eq 204) { 
                return $null
            }    
    
            $entity = ConvertFrom-Json $result.Content
    
            return $entity
        }
        "POST" {
            $result = Invoke-WebRequest -Method Post -Uri $Url -Body $RequestBody -Headers $authHeaderWithContentType -UseBasicParsing

            if($result.StatusCode -eq 201) { 
                $entity = ConvertFrom-Json $result.Content
    
                return $entity    
            }

            return $null
        }
        "PATCH" {
            $result = Invoke-WebRequest -Method Patch -Uri $Url -Body $RequestBody -Headers $authHeaderWithContentType -UseBasicParsing

            if($result.StatusCode -eq 200) { 
                $entity = ConvertFrom-Json $result.Content
    
                return $entity
            }

            return $null
        }
    }
}

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
    
    $requestBody = @{
        Path = $Path.Path
        Layout = $Path.Layout
    }

    if($null -ne $Path.TopNavigationText) {
        $requestBody.TopNavigationText = $Path.TopNavigationText
    }

    if($null -ne $Path.TopNavigationOrder) {
        $requestBody.TopNavigationOrder = $Path.TopNavigationOrder
    }

    if($null -ne $Path.OfflineHtml) {
        $requestBody.OfflineHtml = $Path.OfflineHtml
    }

    if($null -ne $Path.PhaseBannerHtml) {
        $requestBody.PhaseBannerHtml = $Path.PhaseBannerHtml
    }

    if($null -ne $Path.ExternalUrl) {
        $requestBody.ExternalUrl = $Path.ExternalUrl
    }

    if($null -ne $Path.SitemapUrl) {
        $requestBody.SitemapURL = $Path.SitemapUrl
    }

    if($null -ne $Path.RobotsUrl) {
        $requestBody.RobotsURL = $Path.RobotsUrl
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

    $requestBody = @{
        Path = $Path
        PageRegion = $Region.PageRegion
    }

    if($null -ne $Region.RegionEndpoint) {
        $requestBody.RegionEndpoint = $Region.RegionEndpoint
    }

    if($null -ne $Region.HealthCheckRequired) {
        $requestBody.HeathCheckRequired = $Region.HealthCheckRequired
    }

    if($null -ne $Region.OfflineHtml) {
        $requestBody.OfflineHTML = $Region.OfflineHtml
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

.PARAMETER ItemsToPatch
An array of hashtables describing what to patch.
Each item must be in JSON Patch (http://jsonpatch.com/) format.

.EXAMPLE
$ItemsToPatch = @(
    @{ op = "replace"; Path="/Layout"; Value = "1" }
)

Update-PathRegistration -Path somePath -ItemsToPatch $ItemsToPatch
#> 
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,
        [Parameter(Mandatory=$true)]
        [array] $ItemsToPatch
    )

    $requestBodyText = ConvertTo-Json -InputObject @( $ItemsToPatch )

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

.PARAMETER PageRegion
The region to patch.

.PARAMETER ItemsToPatch
An array of hashtables describing what to patch.
Each item must be in JSON Patch (http://jsonpatch.com/) format.

.EXAMPLE
$ItemsToPatch = @(
    @{ op = "replace"; Path="/Layout"; Value = "1" }
)

Update-RegionRegistration -Path somePath -PageRegion 1 -ItemsToPatch $ItemsToPatch
#> 
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,
        [Parameter(Mandatory=$true)]
        [int] $PageRegion,
        [Parameter(Mandatory=$true)]
        [array] $ItemsToPatch
    )

    $requestBodyText = ConvertTo-Json -InputObject @( $ItemsToPatch )

    $finalUrl = "$($script:RegionApiUrl)/paths/$($Path)/regions/$($PageRegion)"

    return Invoke-CompositeApiRegistrationRequest -Url $finalUrl -Method Patch -RequestBody $requestBodyText
}

function Get-PatchDocuments {
<#
.SYNOPSIS
Generate a series of patch documents

.DESCRIPTION
Generates a series of patch documents for all properties on the replacement hashtable.

If the values of a replacement property matches the original value,  patch generation for that property is skipped.

Each patch document will generate the correct patch operation type depending on the values passed in
via the OriginalValues and ReplacementValues parameters

.PARAMETER OriginalValues
A hashtable containing the name/values of the original properties

.PARAMETER ReplacementValues
A hashtable containing the name/values of the replacement properties

.EXAMPLE

$original = @{}
$replacement = @{}
Get-PatchDocuments -OriginalValues SomeValue -ReplacementValue AnotherValue
#>
    param(
        [Parameter(Mandatory=$true)]
        [hashtable] $OriginalValues,
        [Parameter(Mandatory=$true)]
        [hashtable] $ReplacementValues
    )

    $patchDocuments = @()
    $arrayType = @().GetType()
    $objectType = @{}.GetType()

    foreach($property in $ReplacementValues.Keys) {
        $thisType = $null

        if($null -ne $ReplacementValues[$property]) {
            $thisType = $ReplacementValues[$property].GetType()
        }

        if($thisType -eq $arrayType -or $thisType -eq $objectType) {
            Write-Verbose "Array or object-like value for '$property' found, skipping"
            continue
        }

        if ($OriginalValues.$property -eq $ReplacementValues.$property) {
            Write-Verbose "Original and Replacement values for '$property' are the same, skipping."
            continue
        }

        $operation = "replace"

        if($null -eq $OriginalValues.$property -and $null -ne $ReplacementValues.$property) {
            $operation = "add"
        }

        $patchDocuments += @{
            "op" = $operation
            "path" = "/$($property)"
            "value" = $ReplacementValues.$property
        }
    }

    return ,$patchDocuments
}


function ConvertTo-HashTable {
<#
.SYNOPSIS
Converts a PSCustomObject into a hashtable

.DESCRIPTION
Converts a PSCustomObject into a hashtable.

Note that this only converts a single level - it does not recurse into inner properties!

.PARAMETER Object
The object to convert

.EXAMPLE
ConvertTo-HashTable -Object $SomeObject
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject] $Object
    )

    $converted = @{}

    foreach( $property in $Object.psobject.properties.name)
    {
        $converted[$property] = $Object.$property
    }

    return $converted
}