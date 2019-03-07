Push-Location -Path $PSScriptRoot\..\PSScripts\

# solves CommandNotFoundException
function Set-AzureRmSqlDatabase {}


Describe "Switch-SqlDatabases unit tests" -Tag "Unit" {

    Mock Set-AzureRmSqlDatabase

    It "Should create a database" {
        .\Switch-SqlDatabases -ResourceGroupName dfc-foo-bar-rg -SQLServerName dfc-foo-bar-sql -ExistingDatabaseName foobar-db -ReplacementDatabaseName foobar-new

        Assert-MockCalled Set-AzureRmSqlDatabase -Exactly 2 -Scope It
    }

}

Push-Location -Path $PSScriptRoot