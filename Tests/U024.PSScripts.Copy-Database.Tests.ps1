Push-Location -Path $PSScriptRoot\..\PSScripts\

# solves CommandNotFoundException
function Get-AzResource {}
function Get-AzWebApp {}
function Get-AzSqlDatabase {}
function New-AzSqlDatabaseCopy {}
function Set-AzSqlDatabaseBackupShortTermRetentionPolicy {}

Describe "Copy-Database" -Tag "Unit" {

    # mocks
    Mock Get-AzResource -ParameterFilter { $Name -eq "dfc-foo-bar-sql" } -MockWith { return @{
        Name              = "dfc-foo-bar-sql"
        ResourceGroupName = "dfc-foo-bar-rg"
        ResourceType      = "Microsoft.Sql/servers"
    }}
    Mock Get-AzResource -ParameterFilter { $Name -eq "dfc-foo-bar-as" } -MockWith { return @{
        Name              = "dfc-foo-bar-as"
        ResourceGroupName = "dfc-foo-bar-rg"
        ResourceType      = "Microsoft.Web/sites"
    }}
    Mock Get-AzWebApp -MockWith { return @{
        SiteConfig = @{
            AppSettings = @(
                @{ Name = "DatabaseName"; Value ="dfc-foo-db"},
                @{ Name = "DatabaseVersion"; Value ="dfc-bar-db-r101"}
    )}}}
    Mock Get-AzSqlDatabase -ParameterFilter { $DatabaseName.EndsWith('-r123') } -MockWith { return $null }
    Mock Get-AzSqlDatabase -MockWith { return  @{
        ServerName        = "dfc-foo-bar-sql"
        ResourceGroupName = "dfc-foo-bar-rg"
        DatabaseName      = "dfc-foo-bar-db" 
    }}
    Mock New-AzSqlDatabaseCopy -MockWith { return  @{
        ServerName        = "dfc-foo-bar-sql"
        ResourceGroupName = "dfc-foo-bar-rg"
        DatabaseName      = "dfc-foo-bar-db" 
    }}
    Mock Set-AzSqlDatabaseBackupShortTermRetentionPolicy

    $MockParameters = @{
        ServerName     = "dfc-foo-bar-sql.database.windows.net"
        AppServiceName = "dfc-foo-bar-as"
        ReleaseNumber  = 123
    }

    Context "When the Azure SQL Server does not exist" {
        Mock Get-AzResource -ParameterFilter { $Name -eq "dfc-foo-bar-sql" } -MockWith { return $null }

        It "should throw an error" {
            { .\Copy-Database @MockParameters } | Should -Throw
        }

        It "should attempt to get the Azure SQL Server resourse (strip the FQDN)" {
            Assert-MockCalled Get-AzResource -ParameterFilter { $Name -eq "dfc-foo-bar-sql" } -Exactly 1
        }

        It "should not have called any other Azure cmdlet" {
            Assert-MockCalled Get-AzWebApp -Exactly 0
            Assert-MockCalled Get-AzSqlDatabase -Exactly 0
            Assert-MockCalled New-AzSqlDatabaseCopy -Exactly 0
            Assert-MockCalled Set-AzSqlDatabaseBackupShortTermRetentionPolicy -Exactly 0
        }
    }

    Context "When the App Service does not exist" {
        Mock Get-AzResource -ParameterFilter { $Name -eq "dfc-foo-bar-as" } -MockWith { return $null }

        It "Should throw an error" {
            { .\Copy-Database @MockParameters } | Should -Throw
        }

        It "should attempt to get the App Service resourse" {
            Assert-MockCalled Get-AzResource -ParameterFilter { $Name -eq "dfc-foo-bar-as" } -Exactly 1
        }

        It "should not have called any other Azure cmdlet" {
            Assert-MockCalled Get-AzWebApp -Exactly 0
            Assert-MockCalled Get-AzSqlDatabase -Exactly 0
            Assert-MockCalled New-AzSqlDatabaseCopy -Exactly 0
            Assert-MockCalled Set-AzSqlDatabaseBackupShortTermRetentionPolicy -Exactly 0
        }
    }

    Context "When the source database does not exist" {
        Mock Get-AzSqlDatabase -MockWith { return $null }

        It "Should throw an error" {
            { .\Copy-Database @MockParameters } | Should -Throw
        }
    }

    Context "When copy database as specified by app service" {

        $output = .\Copy-Database @MockParameters


        It "should attempt to get info on both Azure SQL Server and App Service resourses" {
            Assert-MockCalled Get-AzResource -Exactly 2
        }

        It "should get the App Service details" {
            Assert-MockCalled Get-AzWebApp -Exactly 1
        }

        It "should check for both source and destination databases" {
            Assert-MockCalled Get-AzSqlDatabase -Exactly 2
        }

        It "should copy the database dfc-bar-db-r101 to dfc-bar-db-r123" {
            Assert-MockCalled New-AzSqlDatabaseCopy #-ParameterFilter { $DatabaseName -eq "dfc-bar-db-r101" -and $CopyDatabaseName -eq "dfc-bar-db-r123" } -Exactly 1
        }

        It "should set the short term retention period to 35 days (default)" {
            Assert-MockCalled Set-AzSqlDatabaseBackupShortTermRetentionPolicy #-ParameterFilter { $RetentionDays -eq 35 } -Exactly 1
        }

        It "output should contain copy message" {
            $output | Should contain "Copying dfc-bar-db-r101 to dfc-bar-db-r123"
        }    
    }

    Context "When copy database with the defaults changed" {
        $MockParameters.DatabaseNameAppSetting = "DatabaseName"
        $MockParameters.RetentionDays = 28

        $output = .\Copy-Database @MockParameters


        It "should attempt to get info on both Azure SQL Server and App Service resourses" {
            Assert-MockCalled Get-AzResource -Exactly 2
        }

        It "should get the App Service details" {
            Assert-MockCalled Get-AzWebApp -Exactly 1
        }

        It "should check for both source and destination databases" {
            Assert-MockCalled Get-AzSqlDatabase -Exactly 2
        }

        It "should copy the database dfc-foo-db (from DatabaseName app setting) to dfc-foo-db-r123" {
            Assert-MockCalled New-AzSqlDatabaseCopy -ParameterFilter { $DatabaseName -eq "dfc-foo-db" -and $CopyDatabaseName -eq "dfc-foo-db-r123" } -Exactly 1
        }

        It "should set the short term retention period to 28 days (value passed in)" {
            Assert-MockCalled Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ParameterFilter { $RetentionDays -eq 28 } -Exactly 1
        }

        It "output should contain copy message" {
            $output | Should contain "Copying dfc-foo-db to dfc-foo-db-r123"
        }
    }

    Context "When the copy database already exists" {
        $MockParameters.ReleaseNumber = 101

        $output = .\Copy-Database @MockParameters


        It "should attempt to get info on both Azure SQL Server and App Service resourses" {
            Assert-MockCalled Get-AzResource -Exactly 2
        }

        It "should get the App Service details" {
            Assert-MockCalled Get-AzWebApp -Exactly 1
        }

        It "should check for both source and destination databases" {
            Assert-MockCalled Get-AzSqlDatabase -Exactly 2
        }

        It "should not copy the database" {
            Assert-MockCalled New-AzSqlDatabaseCopy -Exactly 0
        }

        It "should not set the short term retention period" {
            Assert-MockCalled Set-AzSqlDatabaseBackupShortTermRetentionPolicy -Exactly 0
        }

        It "output should contain skipping message" {
            $output | Should contain "A database copy with name dfc-foo-db-r101 exists. Skipping"
        }
    }

}

Push-Location -Path $PSScriptRoot