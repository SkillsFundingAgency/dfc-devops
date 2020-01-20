###########################################################################################
##                                    WARNING                                            ##
## This script is for backwards compatibility.                                           ##
## Please make any changes to the version of this script in the PSCoreScripts folder     ##
###########################################################################################

<#
.SYNOPSIS
Tests if a CosmosDb database exists.

.DESCRIPTION
Tests if a CosmosDb  database exists,  outputting the results into an Azure Devops variable.

This is to help work around the ARM templates requiring a certain property at create time, but not when updating.  The cmdlet outputs true if the database doesn't exist.
This value will be passed to databaseNeedsCreation parameter of the cosmos-database ARM template.

Requires running Azure  Powershell using the Az cmdlets.

.PARAMETER ResourceGroup
The resource group the CosmosDb account containing the database resides within

.PARAMETER CosmosDbAccountName
The CosmosDb account containing the database

.PARAMETER DatabaseName
The name of the database to check the existance of

.EXAMPLE
Test-CosmosDbDatabaseExists.ps1 -ResourceGroup SomeResourceGroup -CosmosDbAccountName SomeDatabaseAccount -DatabaseName SomeDatabase

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string] $ResourceGroup,
    [Parameter(Mandatory=$true)]
    [string] $CosmosDbAccountName,
    [Parameter(Mandatory=$true)]
    [string] $DatabaseName
    )

$allDatabases = Get-AzResource -ResourceGroupName $ResourceGroup -ResourceName "$($CosmosDbAccountName)/sql/" -ResourceType "Microsoft.DocumentDb/databaseAccounts/apis/databases"  -ApiVersion 2016-03-31 -ErrorAction SilentlyContinue
Write-Verbose "Retrieved $($allDatabases.Count) databases from $CosmosDbAccountName"
$selectedDatabase = $allDatabases | Where-Object { $_.Properties.id -eq $DatabaseName }

$dbDoesntExistAsString = ($null -eq $selectedDatabase | Out-String).ToLower()

Write-Verbose "Setting CosmosDbDatabaseDoesntExist Azure DevOps variable to: $dbDoesntExistAsString"
Write-Host "##vso[task.setvariable variable=CosmosDbDatabaseDoesntExist]$dbDoesntExistAsString"
