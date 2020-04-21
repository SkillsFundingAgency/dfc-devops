Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Copy-SitefinityDatabase unit tests" -Tag "Unit" {
        
    # Re-define the three Az cmdlets under test, as we can't mock them directly.
    # They fire a ParameterBindingValidationException on both powershell core and powershell 5.
    # suspect it's due to https://github.com/pester/Pester/issues/619
    function Get-AzResource { 
        [CmdletBinding()]
        param($Name, $ResourceType)
    }

    function Get-AzWebApp {
        [CmdletBinding()]
        param($ResourceGroupName, $Name)
    }

    function Get-AzSqlDatabase {
        [CmdletBinding()]
        param($ResourceGroupName, $ServerName, $DatabaseName)
    }

    function New-AzSqlDatabaseCopy {
        [CmdletBinding()]
        param($ResourceGroupName, $ServerName, $DatabaseName, $CopyDatabaseName, $ElasticPoolName)
    }

    # mock Get-AzResource: return valid object for dfc-foo-sql and dfc-foo-as, return null if not one of these
    Mock Get-AzResource -ParameterFilter { $Name -eq 'dfc-foo-sql' } -MockWith { return @{
        Name              = 'dfc-foo-sql'
        ResourceGroupName = 'dfc-foo-rg'
        ResourceType      = 'Microsoft.Sql/servers'
        ResourceId        = '/subscriptions/mock-sub/resourceGroups/dfc-foo-rg/providers/Microsoft.Sql/servers/dfc-foo-sql'
    } }
    Mock Get-AzResource -ParameterFilter { $Name -eq 'dfc-foo-as' } -MockWith { return @{
        Name              = 'dfc-foo-as'
        ResourceGroupName = 'dfc-foo-rg'
        ResourceType      = 'Microsoft.Web/sites'
        ResourceId        = '/subscriptions/mock-sub/resourceGroups/dfc-foo-rg/providersMicrosoft.Web/sites/dfc-foo-as'
    } }
    Mock Get-AzResource -MockWith { return $null }

    # mocks either overwritten in tests or that does not return anything
    Mock Get-AzWebApp -MockWith { return $null }
    Mock Get-AzSqlDatabase -MockWith { return $null }
    Mock New-AzSqlDatabaseCopy


    Context "When the Azure resources do not exist" {

        Mock Get-AzWebApp -MockWith { return @{
            Name          = 'dfc-foo-as'
            Kind          = 'app'
            ResourceGroup = 'dfc-foo-rg'
            Type          = 'Microsoft.Web/sites'
            Id            = '/subscriptions/mock-sub/resourceGroups/dfc-foo-rg/providersMicrosoft.Web/sites/dfc-foo-as'
            SiteConfig    = @{ AppSettings = @(
                @{ Name = 'DatabaseVersion'; Value = 'dfc-foo-sitefinitydb' }
            ) }
        } }

        It "should throw an exception if SQL server does not exist" {
            { 
                ./Copy-SitefinityDatabase -ServerName not-a-sql-server -AppServiceName dfc-foo-as  -ReleaseNumber 123
            } | Should throw "Could not find SQL server not-a-sql-server"
        }

        It "should throw an exception if app service does not exist" {
            { 
                ./Copy-SitefinityDatabase -AppServiceName not-an-app-service -ServerName dfc-foo-sql -ReleaseNumber 123
            } | Should throw "Could not find app service not-an-app-service"
        }

        It "should throw an exception if it cannot get the release number" {
            { 
                ./Copy-SitefinityDatabase -AppServiceName dfc-foo-as -ServerName dfc-foo-sql
            } | Should throw "Cannot find environment variable RELEASE_RELEASENAME and no ReleaseNumber passed in"
        }

        It "should throw an exception if the current database does not exist" {
            { 
                ./Copy-SitefinityDatabase -AppServiceName dfc-foo-as -ServerName dfc-foo-sql -ReleaseNumber 123
            } | Should throw "Could not find the current database dfc-foo-sitefinitydb"
        }
    }

    Context "When not specifying the release number and the environment variable is set" {

        Mock Get-AzWebApp -MockWith { return @{
            Name          = 'dfc-foo-as'
            Kind          = 'app'
            ResourceGroup = 'dfc-foo-rg'
            Type          = 'Microsoft.Web/sites'
            Id            = '/subscriptions/mock-sub/resourceGroups/dfc-foo-rg/providersMicrosoft.Web/sites/dfc-foo-as'
            SiteConfig    = @{ AppSettings = @(
                @{ Name = 'DatabaseVersion'; Value = 'dfc-foo-sitefinitydb' }
            ) }
        } }

        Mock Get-AzSqlDatabase -ParameterFilter { $DatabaseName -eq "dfc-foo-sitefinitydb" } -MockWith { return @{
            DatabaseName      = 'dfc-foo-sitefinitydb'
            ServerName        = 'dfc-foo-sql'
            ResourceGroupName = 'dfc-foo-rg'
            ResourceId        = '/subscriptions/mock-sub/resourceGroups/dfc-foo-rg/providers/Microsoft.Sql/servers/dfc-foo-sql/databases/dfc-foo-sitefinitydb'
            SkuName           = 'Standard'
            ElasticPoolName   = $null
        } }

        Mock Get-AzSqlDatabase -ParameterFilter { $DatabaseName -eq "dfc-foo-sitefinitydb-r123" } -MockWith { return $null }

        $env:RELEASE_RELEASENAME =  "199-2"

        ./Copy-SitefinityDatabase -AppServiceName dfc-foo-as -ServerName dfc-foo-sql

        Remove-Item Env:\RELEASE_RELEASENAME

        It "should get the sql server resource description" {
            Assert-MockCalled Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "dfc-foo-sql" }
        }

        It "should get the web app resource description" {
            Assert-MockCalled Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "dfc-foo-as" }
        }

        It "should get the web app details" {
            Assert-MockCalled Get-AzWebApp -Exactly 1 -ParameterFilter {
                $Name -eq "dfc-foo-as" -and `
                $ResourceGroupName -eq "dfc-foo-rg"
            }
        }

        It "should get the existing table" {
            Assert-MockCalled Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "dfc-foo-rg" -and `
                $ServerName -eq "dfc-foo-sql" -and `
                $DatabaseName -eq "dfc-foo-sitefinitydb"
            }
        }

        It "should look for a copy database called dfc-foo-sitefinitydb-r199" {
            Assert-MockCalled Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "dfc-foo-rg" -and `
                $ServerName -eq "dfc-foo-sql" -and `
                $DatabaseName -eq "dfc-foo-sitefinitydb-r199"
            }
        }

        It "Should copy dfc-foo-sitefinitydb to dfc-foo-sitefinitydb-r199" {
            Assert-MockCalled New-AzSqlDatabaseCopy -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "dfc-foo-rg" -and `
                $ServerName -eq "dfc-foo-sql" -and `
                $DatabaseName -eq "dfc-foo-sitefinitydb" -and `
                $CopyDatabaseName -eq "dfc-foo-sitefinitydb-r199" -and `
                $ElasticPoolName -eq $null
            }
        }
    }

    Context "When the web app does not have a DatabaseVersion app setting" {

        Mock Get-AzWebApp -MockWith { return $null }

        It "should throw an exception" {
            { 
                ./Copy-SitefinityDatabase -AppServiceName dfc-foo-as -ServerName dfc-foo-sql -ReleaseNumber 123
            } | Should throw "Could not determine current database version from DatabaseVersion app setting"
        }

    }

    Context "Everything specified exactly and currently a standard (not elastic pool) database with no version number attached" {

        Mock Get-AzWebApp -MockWith { return @{
            Name          = 'dfc-foo-as'
            Kind          = 'app'
            ResourceGroup = 'dfc-foo-rg'
            Type          = 'Microsoft.Web/sites'
            Id            = '/subscriptions/mock-sub/resourceGroups/dfc-foo-rg/providersMicrosoft.Web/sites/dfc-foo-as'
            SiteConfig    = @{ AppSettings = @(
                @{ Name = 'DatabaseVersion'; Value = 'dfc-foo-sitefinitydb' }
            ) }
        } }
    
        Mock Get-AzSqlDatabase -ParameterFilter { $DatabaseName -eq "dfc-foo-sitefinitydb" } -MockWith { return @{
            DatabaseName      = 'dfc-foo-sitefinitydb'
            ServerName        = 'dfc-foo-sql'
            ResourceGroupName = 'dfc-foo-rg'
            ResourceId        = '/subscriptions/mock-sub/resourceGroups/dfc-foo-rg/providers/Microsoft.Sql/servers/dfc-foo-sql/databases/dfc-foo-sitefinitydb'
            SkuName           = 'Standard'
            ElasticPoolName   = $null
        } }

        Mock Get-AzSqlDatabase -ParameterFilter { $DatabaseName -eq "dfc-foo-sitefinitydb-r123" } -MockWith { return $null }

        ./Copy-SitefinityDatabase -AppServiceName dfc-foo-as -ServerName dfc-foo-sql -ReleaseNumber 123

        It "should get the sql server resource description" {
            Assert-MockCalled Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "dfc-foo-sql" }
        }

        It "should get the web app resource description" {
            Assert-MockCalled Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "dfc-foo-as" }
        }

        It "should get the web app details" {
            Assert-MockCalled Get-AzWebApp -Exactly 1 -ParameterFilter {
                $Name -eq "dfc-foo-as" -and `
                $ResourceGroupName -eq "dfc-foo-rg"
            }
        }
        
        It "should get the existing table" {
            Assert-MockCalled Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "dfc-foo-rg" -and `
                $ServerName -eq "dfc-foo-sql" -and `
                $DatabaseName -eq "dfc-foo-sitefinitydb"
            }
        }

        It "should look for a copy database called dfc-foo-sitefinitydb-r123" {
            Assert-MockCalled Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "dfc-foo-rg" -and `
                $ServerName -eq "dfc-foo-sql" -and `
                $DatabaseName -eq "dfc-foo-sitefinitydb-r123"
            }
        }

        It "Should copy dfc-foo-sitefinitydb to dfc-foo-sitefinitydb-r123" {
            Assert-MockCalled New-AzSqlDatabaseCopy -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "dfc-foo-rg" -and `
                $ServerName -eq "dfc-foo-sql" -and `
                $DatabaseName -eq "dfc-foo-sitefinitydb" -and `
                $CopyDatabaseName -eq "dfc-foo-sitefinitydb-r123" -and `
                $ElasticPoolName -eq $null
            }
        }

    }

    Context "FQDN SQL server name passed and currently an elastic pool database with version number" {

        Mock Get-AzWebApp -MockWith { return @{
            Name          = 'dfc-foo-as'
            Kind          = 'app'
            ResourceGroup = 'dfc-foo-rg'
            Type          = 'Microsoft.Web/sites'
            Id            = '/subscriptions/mock-sub/resourceGroups/dfc-foo-rg/providersMicrosoft.Web/sites/dfc-foo-as'
            SiteConfig    = @{ AppSettings = @(
                @{ Name = 'DatabaseVersion'; Value = 'dfc-foo-sitefinitydb-r100' }
            ) }
        } }
    
        Mock Get-AzSqlDatabase -ParameterFilter { $DatabaseName -eq "dfc-foo-sitefinitydb-r100" } -MockWith { return @{
            DatabaseName      = 'dfc-foo-sitefinitydb'
            ServerName        = 'dfc-foo-sql'
            ResourceGroupName = 'dfc-foo-rg'
            ResourceId        = '/subscriptions/mock-sub/resourceGroups/dfc-foo-rg/providers/Microsoft.Sql/servers/dfc-foo-sql/databases/dfc-foo-sitefinitydb-r100'
            SkuName           = 'ElasticPool'
            ElasticPoolName   = 'dfc-foo-epl'
        } }

        Mock Get-AzSqlDatabase -ParameterFilter { $DatabaseName -eq "dfc-foo-sitefinitydb-r124" } -MockWith { return $null }

        ./Copy-SitefinityDatabase -AppServiceName dfc-foo-as -ServerName dfc-foo-sql.database.windows.net -ReleaseNumber 124

        It "should get the sql server resource description using name only" {
            Assert-MockCalled Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "dfc-foo-sql" }
        }

        It "should get the web app resource description" {
            Assert-MockCalled Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "dfc-foo-as" }
        }

        It "should get the web app details" {
            Assert-MockCalled Get-AzWebApp -Exactly 1 -ParameterFilter {
                $Name -eq "dfc-foo-as" -and `
                $ResourceGroupName -eq "dfc-foo-rg"
            }
        }
        
        It "should get the existing table" {
            Assert-MockCalled Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "dfc-foo-rg" -and `
                $ServerName -eq "dfc-foo-sql" -and `
                $DatabaseName -eq "dfc-foo-sitefinitydb-r100"
            }
        }

        It "should look for a copy database called dfc-foo-sitefinitydb-r124" {
            Assert-MockCalled Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "dfc-foo-rg" -and `
                $ServerName -eq "dfc-foo-sql" -and `
                $DatabaseName -eq "dfc-foo-sitefinitydb-r124"
            }
        }

        It "Should copy dfc-foo-sitefinitydb to dfc-foo-sitefinitydb-r124 in elastic pool" {
            Assert-MockCalled New-AzSqlDatabaseCopy -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "dfc-foo-rg" -and `
                $ServerName -eq "dfc-foo-sql" -and `
                $DatabaseName -eq "dfc-foo-sitefinitydb-r100" -and `
                $CopyDatabaseName -eq "dfc-foo-sitefinitydb-r124" -and `
                $ElasticPoolName -eq "dfc-foo-epl"
            }
        }

    }

    Context "When the copy already exists" {

        Mock Get-AzWebApp -MockWith { return @{
            Name          = 'dfc-foo-as'
            Kind          = 'app'
            ResourceGroup = 'dfc-foo-rg'
            Type          = 'Microsoft.Web/sites'
            Id            = '/subscriptions/mock-sub/resourceGroups/dfc-foo-rg/providersMicrosoft.Web/sites/dfc-foo-as'
            SiteConfig    = @{ AppSettings = @(
                @{ Name = 'DatabaseVersion'; Value = 'dfc-foo-sitefinitydb-r101' }
            ) }
        } }
    
        Mock Get-AzSqlDatabase -MockWith { return @{
            DatabaseName      = 'dfc-foo-sitefinitydb-r1xx'
            ServerName        = 'dfc-foo-sql'
            ResourceGroupName = 'dfc-foo-rg'
            ResourceId        = '/subscriptions/mock-sub/resourceGroups/dfc-foo-rg/providers/Microsoft.Sql/servers/dfc-foo-sql/databases/dfc-foo-sitefinitydb-r1xx'
            SkuName           = 'Standard'
        } }

        ./Copy-SitefinityDatabase -AppServiceName dfc-foo-as -ServerName dfc-foo-sql -ReleaseNumber 125

        It "should get the sql server resource description" {
            Assert-MockCalled Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "dfc-foo-sql" }
        }

        It "should get the web app resource description" {
            Assert-MockCalled Get-AzResource -Exactly 1 -ParameterFilter { $Name -eq "dfc-foo-as" }
        }

        It "should get the web app details" {
            Assert-MockCalled Get-AzWebApp -Exactly 1 -ParameterFilter {
                $Name -eq "dfc-foo-as" -and `
                $ResourceGroupName -eq "dfc-foo-rg"
            }
        }
        
        It "should get the existing table" {
            Assert-MockCalled Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "dfc-foo-rg" -and `
                $ServerName -eq "dfc-foo-sql" -and `
                $DatabaseName -eq "dfc-foo-sitefinitydb-r101"
            }
        }

        It "should look for a copy database called dfc-foo-sitefinitydb-r125" {
            Assert-MockCalled Get-AzSqlDatabase -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "dfc-foo-rg" -and `
                $ServerName -eq "dfc-foo-sql" -and `
                $DatabaseName -eq "dfc-foo-sitefinitydb-r125"
            }
        }

        It "Should not copy the database" {
            Assert-MockCalled New-AzSqlDatabaseCopy -Exactly 0
        }

    }

}

Push-Location -Path $PSScriptRoot