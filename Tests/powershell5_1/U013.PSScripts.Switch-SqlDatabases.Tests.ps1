Push-Location -Path $PSScriptRoot\..\..\PSScripts\

# solves CommandNotFoundException
function Get-AzureRmSqlDatabase {}
function Set-AzureRmSqlDatabase {}

Describe "Switch-SqlDatabases unit tests" -Tag "Unit" {

    Mock Set-AzureRmSqlDatabase
    Mock Get-AzureRmSqlDatabase {
        $mock = '{ "ResourceGroupName": "dfc-foo-bar-rg", "ServerName": "dfc-foo-bar-sql", "DatabaseName": "dfc-foo-bar-db", "Location": "westeurope" }'
        if ($global:NumDatabaseExists -gt 0) {
            $global:NumDatabaseExists -= 1
            return ConvertFrom-Json $mock
        }
    }

    It "Should do a single check and a single rename if the existing database does not exist" {

        .\Switch-SqlDatabases -ResourceGroupName dfc-foo-bar-rg -SQLServerName dfc-foo-bar-sql -ExistingDatabaseName foobar-db -ReplacementDatabaseName foobar-new

        Assert-MockCalled Get-AzureRmSqlDatabase -Exactly 1 -Scope It
        Assert-MockCalled Set-AzureRmSqlDatabase -Exactly 1 -Scope It

    }

    It "Should do 2 checks (existingdbname and backupdbname) and two renames if the existing database exists" {

        $global:NumDatabaseExists = 1

        .\Switch-SqlDatabases -ResourceGroupName dfc-foo-bar-rg -SQLServerName dfc-foo-bar-sql -ExistingDatabaseName foobar-db -ReplacementDatabaseName foobar-new

        Assert-MockCalled Get-AzureRmSqlDatabase -Exactly 2 -Scope It
        Assert-MockCalled Set-AzureRmSqlDatabase -Exactly 2 -Scope It

    }

    It "Should do 4 checks if first 2 backup names tried already in use; two renames of the database" {

        $global:NumDatabaseExists = 3

        .\Switch-SqlDatabases -ResourceGroupName dfc-foo-bar-rg -SQLServerName dfc-foo-bar-sql -ExistingDatabaseName foobar-db -ReplacementDatabaseName foobar-new

        Assert-MockCalled Get-AzureRmSqlDatabase -Exactly 4 -Scope It
        Assert-MockCalled Set-AzureRmSqlDatabase -Exactly 2 -Scope It

    }

}

Push-Location -Path $PSScriptRoot