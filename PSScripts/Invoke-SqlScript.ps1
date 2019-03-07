<#

.SYNOPSIS
Runs the SQL scripts

.DESCRIPTION
Wrapper around Invoke-SqlCmd which runs the passed in file

.PARAMETER SQLServerFqdn
Azure SQL Server name

.PARAMETER SQLDatabase
Database name to created

.PARAMETER SQLAdminUsername
SQL SA administrator username

.PARAMETER SQLAdminPassword
SQL SA administrator password

.PARAMETER SQLScript
SQL script to run

.EXAMPLE
Set-SqlLoginPassword -SQLServerFqdn dfc-foo-bar-sql.database.windows.net -SQLDatabase dfc-foo-bar-db -SQLAdminUsername sa -SQLAdminPassword password1 SQLScript C:\Path\To\Script.sql

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string] $SQLServerFqdn,
    [Parameter(Mandatory = $true)]
    [string] $SQLDatabase,
    [Parameter(Mandatory = $true)]
    [string] $SQLAdminUsername,
    [Parameter(Mandatory = $true)]
    [string] $SQLAdminPassword,
    [Parameter(Mandatory = $true)]
    [string] $SQLScript
)

# Common SQL parameters
$SQLParams = @{
    ServerInstance    = $SQLServerFqdn
    Database          = $SQLDatabase
    Username          = $SQLAdminUsername
    Password          = $SQLAdminPassword
    EncryptConnection = $true
}

if (Test-Path $SQLScript) {
    Invoke-Sqlcmd -InputFile $SQLScript @SQLParams
}
else {
    Write-Error "Unable to find SQL script $SQLScript"
}