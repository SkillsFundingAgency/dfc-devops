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

$ExistingDatabaseDetails = Get-AzureRmSqlDatabase -DatabaseName $ExistingDatabaseName -ServerName $SQLServerName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

if ($ExistingDatabaseDetails) {
    Write-Verbose "$ExistingDatabaseName exists"

    # Check if backup already exists
    $BackupNameRoot = "$ExistingDatabaseName-old"
    $NameLoop       = 0
    $LookingForName = $true

    While ($LookingForName) {
        if ($NameLoop -gt 0) {
            $TryName = "$BackupNameRoot$NameLoop"
        }
        else {
            $TryName = $BackupNameRoot
        }

        Write-Verbose "Checking if $TryName is available"
        $BackupDatabaseDetails = Get-AzureRmSqlDatabase -DatabaseName $TryName -ServerName $SQLServerName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

        if ($BackupDatabaseDetails) {
            # Name already in use
            $NameLoop += 1
        }
        else {
            # Name free
            $LookingForName = $false
            $BackupName     = $TryName
        }

    }

    Write-Output "Renaming existing database $ExistingDatabaseName to $BackupName"
    Set-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $SQLServerName -DatabaseName $ExistingDatabaseName -NewName $BackupName
    Start-Sleep 1
}

Write-Output "Renaming $ReplacementDatabaseName to $ExistingDatabaseName"
Set-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $SQLServerName -DatabaseName $ReplacementDatabaseName -NewName $ExistingDatabaseName
