<#

.SYNOPSIS
Clears (purges) content from CDN

.DESCRIPTION
Clears (purges) content from CDN

.PARAMETER ResourceGroupName
Optional - name of the Resource Group for the CosmosDb Account (reads environment var if not passed)

.PARAMETER CdnName
Azure CDN name

.PARAMETER EndpointName
Endpoint within the CDN

.PARAMETER Path
Optional - path to resources to be purged, defaults to all

.EXAMPLE
Clear-Cdn -CdnName dfc-foo-bar-cdn -EndpointName dfc-foo-bar-assets

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName = $ENV:ResourceGroup,
    [Parameter(Mandatory = $true)]
    [string] $CdnName,
    [Parameter(Mandatory = $true)]
    [string] $EndpointName,
    [Parameter(Mandatory = $false)]
    [string] $Path = '/*'
)

Write-Verbose "Purging $EndpointName of all content from $Path"
Unpublish-AzureRmCdnEndpointContent -ResourceGroupName $ResourceGroupName -ProfileName $CdnName -EndpointName $EndpointName -PurgeContent $Path
