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
    if($null -eq $Path.IsOnline) {
        $Path | Add-Member -NotePropertyName IsOnline -NotePropertyValue $true
    }
    
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
An array of JsonPatchDocument operations containing items to update.

.EXAMPLE
$itemsToUpdate = @(
    @{
        Op    = "Replace"
        Path  = "Layout"
        Value = 1
    },
    @{
        Op    = "Replace"
        Path  = "Path"
        Value = "SomePath"
    }
)

Update-PathRegistration -Path somePath -ItemsToUpdate $itemsToUpdate
#> 
    param(
        [Parameter(Mandatory=$true)]
        [string] $Path,
        [Parameter(Mandatory=$true)]
        [object] $ItemsToUpdate
    )

    $requestBodyText = ConvertTo-Json $ItemsToUpdate

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
An array of JsonPatchDocument operations containing items to update.

.EXAMPLE
$itemsToUpdate = @(
    @{
        Op    = "Replace"
        Path  = "Layout"
        Value = 1
    },
    @{
        Op    = "Replace"
        Path  = "Path"
        Value = "SomePath"
    }
)

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

    $requestBodyText = ConvertTo-Json $ItemsToUpdate

    $finalUrl = "$($script:RegionApiUrl)/paths/$($Path)/regions/$($PageRegion)"

    return Invoke-CompositeApiRegistrationRequest -Url $finalUrl -Method Patch -RequestBody $requestBodyText
}

function Get-DifferencesBetweenDefinitionAndCurrent {
<#
.SYNOPSIS
Gets the difference between two Path registration objects

.DESCRIPTION
Gets the difference between the two objects, the defintion object and the current object, comparing only the properties
that are found in the definition object to see if differences are detected

.PARAMETER Definition
The definition registration object

.PARAMETER Current
The right hand path registration object

.EXAMPLE
$configurationEntities = Get-Content -Path ./registration.json | ConvertFrom-Json

$entityFromApi = Get-PathRegistration -Path SomePath
$entityFromFile = $configurationEntities[0]

$itemsToUpdate = Get-DifferencesBetweenDefinitionAndCurrent -Definition $entityFromFile -Current $entityFromApi
#>
	[CmdletBinding()]
	param (
		[Object] $Definition,
		[Object] $Current
	)

	# convert both objects to hashtables to make them easier to work with
	$DefinitionHashTable = @{}
	foreach( $property in $Definition.psobject.properties.name )
	{
		$DefinitionHashTable[$property] = $Definition.$property
	}
	$CurrentHashTable = @{}
	foreach( $property in $Current.psobject.properties.name )
	{
		$CurrentHashTable[$property] = $Current.$property
	}
	$CurrentItems = $CurrentHashTable.Keys

    $differencePatch = @()
    $arrayType       = @().GetType()
    $objType         = @{}.GetType()

    foreach($item in $definitionHashTable.Keys) {
        if ($null -eq $definitionHashTable[$item]) {
            $thisType = $null
        }
        else {
            # get the type (cannot do this on a null
            $thisType = $definitionHashTable[$item].GetType()
        }
		if ($thisType -ne $arrayType -and $thisType -ne $objType) {
    		Write-Verbose "Field: $item"
			if ($item -in $currentItems) {
                if ($definitionHashTable[$item] -ne $currentHashTable[$item]) {
					# difference, need to replace
					Write-Verbose "$($definitionHashTable[$item]) <> $($($currentHashTable[$item]))"
					$differencePatch += @{
						"op"    = "Replace"
						"path"  = "/$($item)"
						"value" = $definitionHashTable[$item]
					}
				}
			}
			else {
				# No field, add
				Write-Verbose "Adding $($definitionHashTable[$item])"
				$differencePatch += @{
					"op"    = "Add"
					"path"  = "/$($item)"
					"value" = $definitionHashTable[$item]
				}
			}
		}
	}
	
	return $differencePatch
}
