Push-Location -Path $PSScriptRoot\..\PSScripts\

# solves CommandNotFoundException
function Get-AzureRmResource {}
function Find-AzureRmResource {}
function Set-AzureRmSqlDatabase {}

Describe "Switch-SqlDatabases unit tests" -Tag "Unit" {

    Mock Set-AzureRmSqlDatabase

    It "Should do a single rename if the existing database doesnt exist" {
        Mock Get-AzureRmResource { return $null }
        Mock Find-AzureRmResource { return $null }

        .\Switch-SqlDatabases -ResourceGroupName dfc-foo-bar-rg -SQLServerName dfc-foo-bar-sql -ExistingDatabaseName foobar-db -ReplacementDatabaseName foobar-new

        Assert-MockCalled Set-AzureRmSqlDatabase -Exactly 1 -Scope It
    }

    # TODO: Mock the existing database existing

    # TODO: Mock existing databas existing and at least $backup-old existing

}

Push-Location -Path $PSScriptRoot