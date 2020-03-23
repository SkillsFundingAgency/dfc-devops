###########################################################################################
##                                    WARNING                                            ##
## This script is for backwards compatibility.                                           ##
## Please make any changes to the version of this script in the PSCoreScripts folder     ##
###########################################################################################

<#
.SYNOPSIS
Creates an APIM Product if one does not already exist

.DESCRIPTION
Creates an APIM Product if one does not already exist

.PARAMETER ApimResourceGroup
The name of the resource group that contains the APIM instnace

.PARAMETER InstanceName
The name of the APIM instance

.PARAMETER ApiProductId
The ApiProductId within APIM of the Product to add; different to the display name (it cannot contain spaces, the display name can)

.PARAMETER ApiProductTitle
[Optional] Api Product Title (display name) within APIM of the Product to add; defaults to the ApiProductId if not specified

.EXAMPLE
Set-ApimProductAndLogger -ApimResourceGroup dfc-foo-shared-rg -InstanceName dfc-foo-shared-apim -ApiProductId bar-product
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [String]$ApimResourceGroup,
    [Parameter(Mandatory=$true)]
    [String]$InstanceName,
    [Parameter(Mandatory=$true)]
    [String]$ApiProductId,
    [Parameter(Mandatory=$false)]
    [String]$ApiProductTitle = $ApiProductId
)

$Context = New-AzApiManagementContext -ResourceGroupName $ApimResourceGroup -ServiceName $InstanceName
$Product = Get-AzApiManagementProduct -Context $Context -ProductId $ApiProductId -ErrorAction SilentlyContinue

if (!$Product) {

    Write-Output "Creating APIM Product $ApiProductId"
    $Product = New-AzApiManagementProduct -Context $Context -ProductId $ApiProductId -Title $ApiProductTitle -State 'Published'

}

if ($Product.State -ne 'Published') {

    Write-Output "Publishing $ApiProductId"
    $null = Set-AzApiManagementProduct -Context $Context -ProductId $ApiProductId -State 'Published'

}