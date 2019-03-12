Push-Location -Path $PSScriptRoot\..\PSScripts\

# solves CommandNotFoundException
function Get-AzureRmResource {}
function Find-AzureRmResource {}
function Set-AzureRmSqlDatabase {}

function mock-resource {
    $mock = '{ "SiteConfig": { "AppSettings": [ { "name": "foo", "value": "bar"}, { "name": "this", "value": "that" } ] } }'
    return ConvertFrom-Json $mock
}
Describe "Switch-SqlDatabases unit tests" -Tag "Unit" {

    Mock Set-AzureRmSqlDatabase

    It "Should do a single rename if the existing database doesnt exist" {
        Mock Get-AzureRmResource { return $null }
        Mock Find-AzureRmResource { return $null }

        .\Switch-SqlDatabases -ResourceGroupName dfc-foo-bar-rg -SQLServerName dfc-foo-bar-sql -ExistingDatabaseName foobar-db -ReplacementDatabaseName foobar-new

        Assert-MockCalled Set-AzureRmSqlDatabase -Exactly 1 -Scope It
    }

    It "Should do a two renames if the existing database exists" {
        Mock Get-AzureRmResource { return mock-resource }
        Mock Find-AzureRmResource { return mock-resource }

        .\Switch-SqlDatabases -ResourceGroupName dfc-foo-bar-rg -SQLServerName dfc-foo-bar-sql -ExistingDatabaseName foobar-db -ReplacementDatabaseName foobar-new

        Assert-MockCalled Set-AzureRmSqlDatabase -Exactly 2 -Scope It
    }

}

Push-Location -Path $PSScriptRoot