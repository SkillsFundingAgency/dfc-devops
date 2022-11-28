<#

.SYNOPSIS
Imports documents from Azure Storage blob into CosmosDb collections.

.DESCRIPTION
Imports a given number of collections within a storage account to an Azure CosmosDb database.

.PARAMETER CosmosAccountName
The name of the cosmos account to import to

.PARAMETER Database
The name of the cosmos database to import to

.PARAMETER Collections
A hashtable representing the names of the collections with the dates of the file to import.
These are case sensitive.

.PARAMETER CosmosKey
An access key for the CosmosDb account

.PARAMETER ContainerUrl
The URL to the blob storage folder to load the data going into the cosmos collections from

.PARAMETER StorageKey
An access key for the storage account

.PARAMETER DataMigrationToolLocation
The full path to the dt.exe binary. Optional!

.NOTES
Requires https://cosmosdbportalstorage.blob.core.windows.net/datamigrationtool/2018.02.28-1.8.1/dt-1.8.1.zip to be extracted to C:\Program Files (x86)\AzureCosmosDBDataMigrationTool\

.EXAMPLE
Import-CosmosDbCollections -CosmosDbAccount aCosmosdbAccount -Database aDatabase -Collections @(container="datetime";container2="datetime") -CosmosKey aCosmosAccessKey -ContainerUrl https://storageAccount.blob.core.windows.net/backupFolder -StorageKey accessKeyToStorageAccount

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$CosmosAccountName,
    [Parameter(Mandatory=$false)]
    [string]$Database,
    [Parameter(Mandatory=$false)]
    [hashtable]$Collections,
    [Parameter(Mandatory=$true)]
    [string]$CosmosKey,
    [Parameter(Mandatory=$true)]
    [string]$ContainerUrl,
    [Parameter(Mandatory=$true)]
    [string]$StorageKey,
    [Parameter(Mandatory=$false)]
    [string]$DataMigrationToolLocation = 'C:\Program Files (x86)\AzureCosmosDBDataMigrationTool\dt.exe'
)

Write-Verbose -Message "Number of collections: $($Collections.Count)"

foreach ($collection in $Collections.GetEnumerator()) {
    Write-Verbose -Message "Backing up collection $collection"

    $parameters = "/s:JsonFile /s.Files:blobs://$StorageKey@$($ContainerUrl.Replace('https://', ''))/$($collection.Value)-$($collection.Key)-backup.json /t:DocumentDB /t.ConnectionString:AccountEndpoint=https://$CosmosAccountName.documents.azure.com:443/;AccountKey=$CosmosKey;Database=$Database /t.Collection:$($Collection.Key) /t:RetryInterval:00:00:02" 
    Write-Verbose -Message "Parameters: $parameters"
    $cmd = $DataMigrationToolLocation
    $params = $parameters.Split(" ")
    
    & $cmd $params
}