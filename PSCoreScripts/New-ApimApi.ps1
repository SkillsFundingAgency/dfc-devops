###########################################################################################
##                                    WARNING                                            ##
## This script is for backwards compatibility.                                           ##
## Please make any changes to the version of this script in the PSCoreScripts folder     ##
###########################################################################################

<#
.SYNOPSIS
Creates an APIM API if one does not already exist

.DESCRIPTION
Creates an APIM API if one does not already exist

.PARAMETER ApimResourceGroup
The name of the resource group that contains the APIM instnace

.PARAMETER InstanceName
The name of the APIM instance

.PARAMETER ApiId
Api ID of product to add

.PARAMETER ApiServiceUrl
Root Uri of the Api to call; the path from this root is then used as the endpoint

.PARAMETER ApiProductId
The ApiProductId within APIM of the Product to add the API to

.PARAMETER ApiPath
[Optional] The path prefix to apply to the URL; defaults to the ApiId if not specified

.PARAMETER ApiName
[Optional] The API name; defaults to the ApiId if not specified

.PARAMETER ApiVersionSetId
[Versioned API only] The name of the version set to apply to this API; this resource must already be created

.PARAMETER ApiVersion
[Versioned API only] The version name (ie v1)

.EXAMPLE
Set-ApimApi -ApimResourceGroup dfc-foo-shared-rg -InstanceName dfc-foo-shared-apim -ApiId bar-api -ApiServiceUrl "https://dfc-foo-api-bar-fa.azurewebsites.net/" -ApiProductId bar-product
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [String]$ApimResourceGroup,
    [Parameter(Mandatory=$true)]
    [String]$InstanceName,
    [Parameter(Mandatory=$true)]
    [String]$ApiId,
    [Parameter(Mandatory=$true)]
    [String]$ApiServiceUrl,
    [Parameter(Mandatory=$true)]
    [String]$ApiProductId,
    [Parameter(Mandatory=$false)]
    [String]$ApiPath = $ApiId,
    [Parameter(Mandatory=$false)]
    [String]$ApiName = $ApiId,
	[Parameter(Mandatory=$false, ParameterSetName="versioned")]
    [String]$ApiVersionSetId,
	[Parameter(Mandatory=$false, ParameterSetName="versioned")]
    [String]$ApiVersion
)

$Context = New-AzApiManagementContext -ResourceGroupName $ApimResourceGroup -ServiceName $InstanceName
$Api = Get-AzApiManagementApi -Context $Context -ApiId $ApiId -ErrorAction SilentlyContinue

if (!$Api) {

    Write-Verbose "Creating APIM Api $ApiId"

    if ($PSCmdlet.ParameterSetName -eq "versioned") {

        Write-Output "Creating versioned API $ApiId"
        $VersionSet = Get-AzApiManagementApiVersionSet -Context $Context -ApiVersionSetId $ApiVersionSetId
        $Api = New-AzApiManagementApi -Context $Context -ApiId $ApiId -Name $ApiName -ServiceUrl $ApiServiceUrl -Protocols @("https") -ProductIds @( $ApiProductId ) -Path $ApiPath -ApiVersionSetId $versionSet.ApiVersionSetId -ApiVersion $ApiVersion

    }
    else {

        Write-Output "Creating standard API $ApiId"
        $Api = New-AzApiManagementApi -Context $Context -ApiId $ApiId -Name $ApiName -ServiceUrl $ApiServiceUrl -Protocols @("https") -ProductIds @( $ApiProductId ) -Path $ApiPath

    }

}
else {

    Write-Verbose "$($Api.Id) already exists"

}