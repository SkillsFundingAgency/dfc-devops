$script:AppRegistryApiUrl = $null

function New-RegistrationContext {
<#
.SYNOPSIS
Set-up the registration api configuration

.DESCRIPTION
Set-up the registration api configuration

.PARAMETER AppRegistryApiUrl
Url for the App Registry registration API

.PARAMETER AppRegistryApiKey
The Api Key for the APIM instance hosting the API

.EXAMPLE
 New-RegistrationContext -AppRegistryApiUrl "https://api.example.com/path/api"
#>
    param(
        [Parameter(Mandatory=$true)]
        [string] $AppRegistryApiUrl,
        [Parameter(Mandatory=$true)]
        [string] $AppRegistryApiKey
    )

    $script:AppRegistryApiUrl = $AppRegistryApiUrl
    $script:AppRegistryApiKey = $AppRegistryApiKey
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
        [ValidateSet("GET", "PUT", "POST")]
        [string] $Method,
        [string] $RequestBody
    )

    Write-Verbose "Performing $Method request against '$Url'."

    if (($method -in "POST","PUT") -and ($RequestBody)) {
        Write-Verbose "With body"
        Write-Verbose $requestBody
    }

    $authHeader = @{"Ocp-Apim-Subscription-Key" = $script:AppRegistryApiKey }
    $authHeaderWithContentType = @{
        "Ocp-Apim-Subscription-Key" = $script:AppRegistryApiKey
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
        "PUT" {
            $result = Invoke-WebRequest -Method Put -Uri $Url -Body $RequestBody -Headers $authHeaderWithContentType -UseBasicParsing

            if($result.StatusCode -eq 202) { 
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
        [string] $PathName
    )

    $finalUrl = "$($script:AppRegistryApiUrl)/appregistry/$($PathName)"

    return Invoke-CompositeApiRegistrationRequest -Url $finalUrl -Method Get
}

function New-PathRegistration
{
<#
.SYNOPSIS
Posts a new path registration

.DESCRIPTION
Posts a new path registration

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
        [object] $PathObject
    )

    if($null -eq $PathObject.Path) { throw "Path not specified" }
    if($null -eq $PathObject.Layout) { throw "Layout is mandatory when creating a page registration."}
    
    $requestBody = $PathObject

    $requestBodyText = $requestBody | ConvertTo-Json

    $finalUrl = "$($script:AppRegistryApiUrl)/appregistry"

    return Invoke-CompositeApiRegistrationRequest -Url $finalUrl -Method Post -RequestBody $requestBodyText
}

function Update-PathRegistration
{
<#
.SYNOPSIS
Puts a replacement path registration

.DESCRIPTION
Puts a replacement path registration.

.PARAMETER Path
The path of the path registration to update.

.EXAMPLE

Update-PathRegistration -Path somePath
#> 
    param(
        [Parameter(Mandatory=$true)]
        [string] $PathName,
        [Parameter(Mandatory=$true)]
        [object] $PathObject
    )

    $requestBody = $PathObject

    $requestBodyText = $requestBody | ConvertTo-Json

    $finalUrl = "$($script:AppRegistryApiUrl)/appregistry/$PathName"
    
    return Invoke-CompositeApiRegistrationRequest -Url $finalUrl -Method Put -RequestBody $requestBodyText
}