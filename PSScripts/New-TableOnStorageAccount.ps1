###########################################################################################
##                                    WARNING                                            ##
## This script is for backwards compatibility.                                           ##
## Please make any changes to the version of this script in the PSCoreScripts folder     ##
###########################################################################################

<#
.SYNOPSIS
Creates a table on a storage account if it doesn't already exist

.DESCRIPTION
Creates a table on a storage account if it doesn't already exist

.PARAMETER ResourceGroupName
The name of the resource group containing the storage account

.PARAMETER StorageAccountName
The Storage Account to create the table upon

.PARAMETER TableName
The name of the table to create

.EXAMPLE
New-TableOnStorageAccount.ps1 -StorageAccountName dfcfoostr -StorageAccountKey not-a-real-key -TableName aTableToCreate

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string] $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string] $StorageAccountName,
    [Parameter(Mandatory=$true)]
    [string] $TableName
)

# Fetch storage account key via Az module
Write-Verbose "Fetching storage account keys"
$storageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue

if(!$storageAccountKeys) {
    throw "Unable to fetch account keys from storage account '$($StorageAccountName)'"
}
$accountKey = ($storageAccountKeys | Where-Object { $_.keyName -eq "key1" }).Value

Write-Verbose "Creating storage context"
$context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $accountKey

Write-Verbose "Attempting to fetch table '$($TableName)'"
$table = Get-AzStorageTable -Name $TableName -Context $context -ErrorAction SilentlyContinue

if(!$table) {
    Write-Verbose "Table '$($TableName)' does not exist, creating"
    New-AzStorageTable -Context $context -Name $TableName
} else {
    Write-Verbose "Table '$($TableName)' already exists, skipping creation"
}
