<#
.SYNOPSIS
Creates a table on a storage account if it doesn't already exist

.DESCRIPTION
Creates a table on a storage account if it doesn't already exist

.PARAMETER StorageAccountName
The Storage Account to create the table upon

.PARAMETER StorageAccountKey
The key to the storage account specified in the StorageAccountName parameter

.PARAMETER TableName
The name of the table to create

.EXAMPLE
New-TableOnStorageAccount.ps1 -StorageAccountName dfcfoostr -StorageAccountKey not-a-real-key -TableName aTableToCreate

#>

param(
    [Parameter(Mandatory=$true)]
    [string] $StorageAccountName,
    [Parameter(Mandatory=$true)]
    [string] $StorageAccountKey,
    [Parameter(Mandatory=$true)]
    [string] $TableName
)

Write-Verbose "Creating storage context"
$context = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $StorageAccountKey

Write-Verbose "Attempting to fetch table '$($TableName)'"
$table = Get-AzStorageTable -Name $TableName -Context $context -ErrorAction SilentlyContinue

if($null -eq $table) {
    Write-Verbose "Table '$($TableName)' does not exist, creating"
    New-AzStorageTable -Context $context -Name $TableName
} else {
    Write-Verbose "Table '$($TableName)' already exists, skipping creation"
}