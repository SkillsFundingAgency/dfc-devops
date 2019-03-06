<#

.SYNOPSIS
Creates a SQL database from a bacpac file in Azure storage

.DESCRIPTION
Creates a SQL database from a bacpac file in Azure storage

.PARAMETER ResourceGroupName
The name of the Resource Group for the Azure SQL Server

.PARAMETER SQLServerName
Azure SQL Server name

.PARAMETER SQLDatabase
Database name to created

.PARAMETER SQLAdminUsername
SQL SA administrator username

.PARAMETER SQLAdminPassword
SQL SA administrator password

.PARAMETER StorageUrl
Url to bacpac file in the storage account

.PARAMETER StorageAccountKey
Storage account key to access storage url

.PARAMETER DatabaseTier
Optional - sets the database tier to use (eg S2)

.PARAMETER DatabaseMaxSize
Optional - the max size the databse can grow to (in bytes)

.PARAMETER ElasticPool
Optional - moves the database into the elastic pool if specified

.EXAMPLE
New-CosmosDbAccountCollections -CosmosDbAccountName "dfc-foo-bar-cdb" -CosmosDbConfigurationFilePath C:\path\to\config.json

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string] $ResourceGroupName = $ENV:ResourceGroup,
    [Parameter(Mandatory = $true)]
    [string] $SQLServerName,
    [Parameter(Mandatory = $true)]
    [string] $SQLDatabase,
    [Parameter(Mandatory = $true)]
    [string] $SQLAdminUsername,
    [Parameter(Mandatory = $true)]
    [string] $SQLAdminPassword,
    [Parameter(Mandatory = $true)]
    [string] $StorageUrl,
    [Parameter(Mandatory = $true)]
    [string] $StorageAccountKey,
    [Parameter(Mandatory = $false)]
    [string] $DatabaseTier = "S2",
    [Parameter(Mandatory = $false)]
    [int] $DatabaseMaxSize = 25000000,
    [Parameter(Mandatory = $false)]
    [string] $ElasticPool
)

$SecureAdminPassword = ConvertTo-SecureString $SQLAdminPassword -AsPlainText -Force

$Database = New-AzureRmSqlDatabaseImport -ResourceGroupName $ResourceGroupName -ServerName $SQLServerName -DatabaseName $SQLDatabase `
                            -StorageKeyType "StorageAccessKey" -StorageKey $StorageAccountKey -StorageUri $StorageUrl `
                            -AdministratorLogin $SQLAdminUsername -AdministratorLoginPassword $SecureAdminPassword `
                            -Edition Standard -ServiceObjectiveName $DatabaseTier -DatabaseMaxSizeBytes $DatabaseMaxSize

$RestoreInProgress = $true

While ($RestoreInProgress) {
    # Wait until restore has completed
    Start-Sleep 30
    $DatabaseStatus = Get-AzureRmSqlDatabaseImportExportStatus -OperationStatusLink $Database.OperationStatusLink -ErrorAction SilentlyContinue
    Write-Output "$($DatabaseStatus.Status): $($DatabaseStatus.StatusMessage)"
    $RestoreInProgress = $DatabaseStatus.Status -ne "Succeeded"
}

if ($ElasticPool) {
    # If an elastic pool has been specified, move db into pool
    Set-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $SQLServerName -DatabaseName $SQLDatabase -ElasticPoolName $ElasticPool
}
else {
    # display the database info
    Get-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $SQLServerName -DatabaseName $SQLDatabase
}