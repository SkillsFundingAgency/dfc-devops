<#

.SYNOPSIS
Copies a number of collections from one cosmos account to another.

.DESCRIPTION
Copies a number of collections from one cosmos account to another.

.PARAMETER CosmosAccountName
The name of the source cosmos account

.PARAMETER Database
The name of the database containing collections to transfer from the source cosmos account

.PARAMETER Collections
The name of the collection to transfer from the source cosmos account

.PARAMETER CosmosKey
The account key of the source comsos account

.PARAMETER CosmosAccountNameTarget
The name of the target cosmos account

.PARAMETER DatabaseTarget
The name of the database to transfer the source collcetion to

.PARAMETER CosmosKeyTarget
The account key of the destination comsos account

.PARAMETER DataMigrationToolLocation
The location of the Microsoft Azure Cosmos Data Migration tool (defaults to C:\Program Files (x86)\AzureCosmosDBDataMigrationTool\dt.exe)

.EXAMPLE
./Export-import-CosmosDbColletions -Parameters @param
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
    [string]$CosmosAccountNameTarget,
    [Parameter(Mandatory=$false)]
    [string]$DatabaseTarget,
    [Parameter(Mandatory=$false)]
    [string]$CosmosKeyTarget,
    [Parameter(Mandatory=$true)]
    [string]$DataMigrationToolLocation = 'C:\Program Files (x86)\AzureCosmosDBDataMigrationTool\dt.exe'
)

foreach ($collection in $Collections) {
    Write-Verbose -Message "Backing up collection $collection"

    $parameters = "/s:DocumentDB /s.ConnectionString:AccountEndpoint=https://$CosmosAccountName.documents.azure.com:443/;AccountKey=$CosmosKey;Database=$Database /s.Collection:$Collection /t:DocumentDBTarget /t.ConnectionString:AccountEndpoint=https://$CosmosAccountNameTarget.documents.azure.com:443/;AccountKey=$CosmosKeyTarget;Database=$DatabaseTarget /t.Collection:$Collection"

    Write-Verbose -Message "Parameters: $parameters"
    $cmd = $DataMigrationToolLocation
    $params = $parameters.Split(" ")
    & $cmd $params
}
