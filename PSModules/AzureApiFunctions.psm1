function ApiRequest {
    param (
        [Parameter(Mandatory=$true)]
        [string] $Url,
        [Parameter(Mandatory=$true)]
        [string] $ApiKey,
        [Parameter(Mandatory=$false)]
        [string] $Method = "GET",
        [Parameter(Mandatory=$false)]
        [string] $ApiVersion = "2017-11-11",
        [Parameter(Mandatory=$false)]
        $Body
    )

<#
.SYNOPSIS
JSON invoke web request for Azure Search

.DESCRIPTION
Invokes a web request to Azure Search REST API assuming a JSON document

.PARAMETER Url
API URL including protocol

.PARAMETER ApiKey
API key for the REST API

.PARAMETER Method
Optional HTTP method, defaults to GET

.PARAMETER ApiVersion
Optional, override the API version, defaults to 2017-11-11

.PARAMETER Body
Optional hash to send as the body

.EXAMPLE
ApiRequest -Url "https://api.example.com/endpoint" -ApiKey fookey
#>

    Write-Verbose "API version $ApiVersion"
    
    $ApiHeaders = @{
        "Content-Type" = "application/json"
        "api-key"      = $ApiKey
    }
    $FullUrl = "$($Url)?api-version=$ApiVersion"
    
    if ($Body) {
        $JsonBody = $Body | ConvertTo-Json -Depth 10
        Write-Verbose "Body - $JsonBody"
        $WebResponse = Invoke-WebRequest -Uri $FullUrl -Method $Method -Headers $ApiHeaders -Body $JsonBody -UseBasicParsing
    }
    else {
        $WebResponse = Invoke-WebRequest -Uri $FullUrl -Method $Method -Headers $ApiHeaders -UseBasicParsing
    }
    
    if ($WebResponse.StatusCode -eq 200) {
        return $WebResponse.Content | ConvertFrom-Json  # Depth is only supported in PowerShell 6, consider this if you find deep nested documents to be missing values
    }
}

