Push-Location -Path $PSScriptRoot\..\..\PSScripts\

# solves CommandNotFoundException
function New-AzSqlDatabaseImport {}
function Get-AzSqlDatabaseImportExportStatus {}
function Set-AzSqlDatabase {}
function Get-AzSqlDatabase {}

Describe "New-DatabaseFromBlobFile unit tests" -Tag "Unit" {

    BeforeAll {
        Mock New-AzSqlDatabaseImport { return ConvertFrom-Json '{ "OperationStatusLink": "https://management.azure.com/subscriptions/blah/guid?apiversion=1-2-3" }' }
        Mock Get-AzSqlDatabaseImportExportStatus { return ConvertFrom-Json '{ "Status": "Succeeded", "StatusMessage": "" }' }
        Mock Set-AzSqlDatabase
        Mock Get-AzSqlDatabase

        $params = @{
            ResourceGroupName = "dfc-foo-bar-rg"
            SQLServerName     = "dfc-foo-bar-sql"
            SQLDatabase       = "dfc-foo-bar-db" 
            SQLAdminUsername  = "admin"
            SQLAdminPassword  = "not-a-real-password"
            StorageAccountKey = "not-a-real-key"
            StorageUrl        = "https://dfcfoobarstr.blob.core.windows.net/backup/db.bacpac"
        }
    }

    It "Should create a database" {
        .\New-DatabaseFromBlobFile @params -Verbose

        Should -Invoke -CommandName New-AzSqlDatabaseImport -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzSqlDatabaseImportExportStatus -Exactly 1 -Scope It
        Should -Invoke -CommandName Set-AzSqlDatabase -Exactly 0 -Scope It
        Should -Invoke -CommandName Get-AzSqlDatabase -Exactly 1 -Scope It
    }

    It "Should add database to elastic pool if one is specified" {
        $params['ElasticPool'] = "dfc-foo-bar-epl"

        .\New-DatabaseFromBlobFile @params -Verbose

        Should -Invoke -CommandName New-AzSqlDatabaseImport -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzSqlDatabaseImportExportStatus -Exactly 1 -Scope It
        Should -Invoke -CommandName Set-AzSqlDatabase -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzSqlDatabase -Exactly 0 -Scope It
    }

}

Push-Location -Path $PSScriptRoot