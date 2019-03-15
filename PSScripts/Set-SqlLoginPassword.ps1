<#

.SYNOPSIS
Resets SQL login password

.DESCRIPTION
Resets SQL login password and optionally runs a user reset script

.PARAMETER ResourceGroupName
The name of the Resource Group for the CosmosDb Account

.PARAMETER SQLServerName
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
Set-SqlLoginPassword -SQLServerName dfc-foo-bar-sql -SQLDatabase dfc-foo-bar-db -SQLAdminUsername sa -SQLAdminPassword password1 -SQLLogin connection_user -SQLLoginPassword abc123

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName = $ENV:ResourceGroup,
    [Parameter(Mandatory = $true)]
    [string] $SQLServerName,
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

$CheckLoopNumber = 1
$DatabaseOffline = $true

while ($DatabaseOffline) {
    Write-Verbose "Check $CheckLoopNumber to see if $SQLDatabase is online"
    $ExistingDatabaseDetails = Get-AzureRmSqlDatabase -DatabaseName $SQLDatabase -ServerName $SQLServerName -ResourceGroupName $ResourceGroupName -ErrorAction SilentlyContinue

    if ($ExistingDatabaseDetails) {
        # When status in Online, set $DatabaseOffline to false
        $DatabaseOffline = $ExistingDatabaseDetails.Status -ne "Online"
    }

    if ($DatabaseOffline) {
        # increment loop, throw error after 6 attempts
        $CheckLoopNumber += 1
        if ($CheckLoopNumber -gt 6) {
            throw "Database not online"
        }
        else {
            Start-Sleep 10
        }
    }
}

$SqlServerDetails = Get-AzureRmSqlServer -ServerName $SQLServerName -ResourceGroupName $ResourceGroupName

# Common SQL parameters
$SQLParams = @{
    ServerInstance    = $SqlServerDetails.FullyQualifiedDomainName
    Database          = $SQLDatabase
    Username          = $SQLAdminUsername
    Password          = $SQLAdminPassword
    EncryptConnection = $true
}

$ResetPasswordQuery = "ALTER USER [$SQLLogin] WITH PASSWORD = '$SQLLoginPassword';"
Write-Verbose $ResetPasswordQuery
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
