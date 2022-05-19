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
