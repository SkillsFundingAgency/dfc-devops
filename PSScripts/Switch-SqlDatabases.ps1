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

$AzureRmVersion = Get-Module AzureRM -ListAvailable | Sort-Object { $_.Version.Major } -Descending | Select-Object -First 1

# Check if existing database already exists
if ($AzureRmVersion.Version.Major -gt 5) {
    $ExistingDatabaseDetails = Get-AzureRmResource -Name $ExistingDatabaseName -ResourceType Microsoft.Sql/servers/databases -ResourceGroupName $ResourceGroupName
}
else {
    $ExistingDatabaseDetails = Find-AzureRmResource -ResourceNameEquals $ExistingDatabaseName -ResourceType Microsoft.Sql/servers/databases -ResourceGroupNameEquals $ResourceGroupName
}

if ($ExistingDatabaseDetails) {
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
        if ($AzureRmVersion.Version.Major -gt 5) {
            $BackupDatabaseDetails = Get-AzureRmResource -Name $TryName -ResourceType Microsoft.Sql/servers/databases -ResourceGroupName $ResourceGroupName

        }
        else {
            $BackupDatabaseDetails = Find-AzureRmResource -ResourceNameEquals $TryName -ResourceType Microsoft.Sql/servers/databases -ResourceGroupNameEquals $ResourceGroupName
        }

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

    Write-Output "Renaming $ExistingDatabaseName to $BackupName"
    Set-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $SQLServerName -DatabaseName $ExistingDatabaseName -NewName $BackupName
    Start-Sleep 1
}

Write-Output "Renaming $ReplacementDatabaseName to $ExistingDatabaseName"
Set-AzureRmSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $SQLServerName -DatabaseName $ReplacementDatabaseName -NewName $ExistingDatabaseName
