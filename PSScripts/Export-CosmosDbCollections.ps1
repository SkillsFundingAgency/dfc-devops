<#
    .SUMMARY
    Exports documents from CosmosDb collections to Azure Storage blob.  Assumes that collections and databases are identically named as in DSS project.

    .NOTES
    Requires https://cosmosdbportalstorage.blob.core.windows.net/datamigrationtool/2018.02.28-1.8.1/dt-1.8.1.zip to be extracted to C:\Program Files (x86)\AzureCosmosDBDataMigrationTool\

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