<#

.SYNOPSIS
Exports documents from CosmosDb collections to Azure Storage blob.

.DESCRIPTION
Exports a given number of collections within an Azure CosmosDb database to a storage account.

.PARAMETER CosmosAccountName
The name of the cosmos account to export from

.PARAMETER Database
The name of the cosmos database to export from

.PARAMETER Collections
An array of strings representing the names of the collections to export.
These are case sensitive.

.PARAMETER CosmosKey
An access key for the CosmosDb account

.PARAMETER ContainerUrl
The URL to the blob storage folder to save the exported cosmos collections to

.PARAMETER StorageKey
An access key for the storage account

.PARAMETER DataMigrationToolLocation
The full path to the dt.exe binary. Optional!

.NOTES
Requires https://cosmosdbportalstorage.blob.core.windows.net/datamigrationtool/2018.02.28-1.8.1/dt-1.8.1.zip to be extracted to C:\Program Files (x86)\AzureCosmosDBDataMigrationTool\

.EXAMPLE
Export-CosmosdbCollections -CosmosDbAccount aCosmosdbAccount -Database aDatabase -Collections @("coll1", "coll2") -CosmosKey aCosmosAccessKey -ContainerUrl https://storageAccount.blob.core.windows.net/backupFolder -StorageKey accessKeyToStorageAccount

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$CosmosAccountName,
    [Parameter(Mandatory=$false)]
    [string]$Database,
    [Parameter(Mandatory=$false)]
    [array]$Collections,
    [Parameter(Mandatory=$true)]
    [string]$CosmosKey,
    [Parameter(Mandatory=$true)]
    [string]$ContainerUrl,
    [Parameter(Mandatory=$true)]
    [string]$StorageKey,
    [Parameter(Mandatory=$false)]
    [string]$DataMigrationToolLocation = 'C:\Program Files (x86)\AzureCosmosDBDataMigrationTool\dt.exe'
)

foreach ($collection in $Collections) {
    Write-Verbose -Message "Backing up collection $collection"

    $parameters = "/s:DocumentDB /s.ConnectionString:AccountEndpoint=https://$CosmosAccountName.documents.azure.com:443/;AccountKey=$CosmosKey;Database=$Database /s.Collection:$Collection /t:JsonFile /t.File:blobs://$StorageKey@$($ContainerUrl.Replace('https://', ''))/$([DateTime]::Now.ToString("yyyy-MM-dd_HHmm"))-$Collection-backup.json"
    Write-Verbose -Message "Parameters: $parameters"
    $cmd = $DataMigrationToolLocation
    $params = $parameters.Split(" ")
    & $cmd $params
}