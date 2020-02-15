###########################################################################################
##                                    WARNING                                            ##
## This script is for backwards compatibility.                                           ##
## Please make any changes to the version of this script in the PSCoreScripts folder     ##
###########################################################################################

<#
.SYNOPSIS
Removes one (or more) apis from an API management instance

.DESCRIPTION
Removes one (or more) apis from an API management instance

.PARAMETER ApisToRemove
One or more APIs to remove from the APIM instance

.PARAMETER ApimResourceGroup
The resource group that the APIM instance is in

.PARAMETER ApimServiceName
The name of the APIM instance

.EXAMPLE
Remove-ApisFromApiManagement -ApisToRemove @( "Echo API" ) -ApimResourceGroup aResourceGroup -ApimServiceName anApimInstance

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string[]]$ApisToRemove,
    [Parameter(Mandatory=$true)]
    [string]$ApimResourceGroup,
    [Parameter(Mandatory=$true)]
    [string]$ApimServiceName
)

$Context = New-AzApiManagementContext -ResourceGroupName $ApimResourceGroup -ServiceName $ApimServiceName

foreach ($ApiToRemove in $ApisToRemove) {
    $Api = Get-AzApiManagementApi -Context $Context -Name $ApiToRemove

    if($Api) {
        Remove-AzApiManagementApi -Context $Context -ApiId $Api.ApiId
    }
}

