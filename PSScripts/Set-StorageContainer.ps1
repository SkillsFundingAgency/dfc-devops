<#

.SYNOPSIS
Creates storage account container if it doesnt exist

.DESCRIPTION
Checks if the storage container exists and creates it if necessary

.PARAMETER ResourceGroupName
The name of the Resource Group for the Storage Account

.PARAMETER StorageAccountName
Storage Account name

.PARAMETER ContainerName
Container to create if applicable

.EXAMPLE
Set-StorageContainer.ps1 -ResourceGroupName dfc-foo-bar-rg -StorageAccountName dfcfoobarstr -ContainerName mycontainer

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $ResourceGroupName = $ENV:ResourceGroup,
    [Parameter(Mandatory = $true)]
    [string] $StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string] $ContainerName
)

$AccountKeys = Get-AzureRmStorageAccountKey -ResourceGroupName $ResourceGroupName -name $StorageAccountName
$StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $AccountKeys[0].Value

$StorageContainer = Get-AzureStorageContainer -Name $ContainerName -Context $StorageContext -ErrorAction SilentlyContinue
if ($null -eq $StorageContainer) {
    # create storage container
    Write-Output "Creating container $ContainerName"
    New-AzureStorageContainer -Name $ContainerName -Context $StorageContext
}