param(
    [Parameter(Mandatory=$true)]
    [string] $ResourceGroup,
    [Parameter(Mandatory=$true)]
    [string] $CosmosDbAccountName,
    [Parameter(Mandatory=$true)]
    [string] $DatabaseName
    )

$allDatabases = Get-AzResource -ResourceGroupName CosmosDbTest -ResourceName "$($CosmosDbAccountName)/sql/" -ResourceType "Microsoft.DocumentDb/databaseAccounts/apis/databases"  -ApiVersion 2016-03-31 -ErrorAction SilentlyContinue
$selectedDatabase = $allDatabases | Where-Object { $_.Properties.id -eq $DatabaseName }

Write-Host "##vso[task.setvariable variable=CosmosDbDatabaseExists]$($selectedDatabase -ne $null)"
