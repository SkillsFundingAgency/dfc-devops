<#
.SYNOPSIS
Tests if a CosmosDb database exists.

.DESCRIPTION
Tests if a CosmosDb  database exists,  outputting the results into an Azure Devops variable.

This is to help work around the ARM templates requiring a certain property at create time, but not when updating.

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

$allDatabases = Get-AzResource -ResourceGroupName CosmosDbTest -ResourceName "$($CosmosDbAccountName)/sql/" -ResourceType "Microsoft.DocumentDb/databaseAccounts/apis/databases"  -ApiVersion 2016-03-31 -ErrorAction SilentlyContinue
$selectedDatabase = $allDatabases | Where-Object { $_.Properties.id -eq $DatabaseName }

$dbExistsAsString = ($null -ne $selectedDatabase | Out-String).ToLower()

Write-Host "##vso[task.setvariable variable=CosmosDbDatabaseExists]$dbExistsAsString"
