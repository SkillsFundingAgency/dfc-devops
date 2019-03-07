<#

.SYNOPSIS
Swaps replacement database for existing database

.DESCRIPTION
Renames existing database to -old and renames replacement database to existing name

.PARAMETER ResourceGroupName
The name of the Resource Group for the CosmosDb Account

.PARAMETER SQLServerName
Azure SQL Server name

.PARAMETER ExistingDatabaseName
Database name to created

.PARAMETER ReplacementDatabaseName
SQL SA administrator username

.PARAMETER SQLAdminPassword
SQL SA administrator password

.PARAMETER SQLScript
SQL script to run

.EXAMPLE
Switch-SqlDatabases -SQLServerName dfc-foo-bar-sql -ExistingDatabaseName dfc-old-db -ReplacementDatabaseName dfc-new-db

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName = $ENV:ResourceGroup,
    [Parameter(Mandatory = $true)]
    [string] $SQLServerName,
    [Parameter(Mandatory = $true)]
    [string] $ExistingDatabaseName,
    [Parameter(Mandatory = $true)]
    [string] $ReplacementDatabaseName
)

$BackupName = "$ExistingDatabaseName-old"
Write-Output "Renaming $ExistingDatabaseName to $BackupName"
Set-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $SQLServerName -DatabaseName $ExistingDatabaseName -NewName $BackupName

Start-Sleep 1
Write-Output "Renaming $ReplacementDatabaseName to $ExistingDatabaseName"
Set-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $SQLServerName -DatabaseName $ReplacementDatabaseName -NewName $ExistingDatabaseName
