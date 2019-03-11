<#

.SYNOPSIS
Resets SQL login password

.DESCRIPTION
Resets SQL login password and optionally runs a user reset script

.PARAMETER SQLServerFqdn
Azure SQL Server name

.PARAMETER SQLDatabase
Database name to created

.PARAMETER SQLAdminUsername
SQL SA administrator username

.PARAMETER SQLAdminPassword
SQL SA administrator password

.PARAMETER SQLLogin
SQL login to reset

.PARAMETER SQLLoginPassword
New SQL login password

.PARAMETER UserScript
Optional additional script to run

.EXAMPLE
Set-SqlLoginPassword -SQLServerFqdn dfc-foo-bar-sql.database.windows.net -SQLDatabase dfc-foo-bar-db -SQLAdminUsername sa -SQLAdminPassword password1 -SQLLogin connection_user -SQLLoginPassword abc123

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
    [string] $SQLLogin,
    [Parameter(Mandatory = $true)]
    [string] $SQLLoginPassword,
    [Parameter(Mandatory = $false)]
    [string] $UserScript
)

# Common SQL parameters
$SQLParams = @{
    ServerInstance    = $SQLServerFqdn
    Database          = $SQLDatabase
    Username          = $SQLAdminUsername
    Password          = $SQLAdminPassword
    EncryptConnection = $true
}

Write-Output "Using SQL credentials: $SQLAdminUsername - Password length $($SQLAdminPassword.length)"
$ResetPasswordQuery = "ALTER USER [$SQLLogin] WITH PASSWORD = '$SQLLoginPassword';"
Write-Output $ResetPasswordQuery 
Invoke-Sqlcmd -Query $ResetPasswordQuery @SQLParams

if ($UserScript) {
    # Optional script provided
    if (Test-Path $UserScript) {
        Write-Output "Running SQL script $UserScript"
        Invoke-Sqlcmd -InputFile $UserScript @SQLParams
    }
    else {
        Write-Error "Unable to find SQL script $UserScript"
    }
}