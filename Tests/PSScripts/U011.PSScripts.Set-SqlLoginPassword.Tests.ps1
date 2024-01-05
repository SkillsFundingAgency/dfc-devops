Push-Location -Path $PSScriptRoot\..\..\PSScripts\


Describe "Set-SqlLoginPassword unit tests" -Tag "Unit" {


    BeforeEach {

        $SQLLogin = "connection-user"
        $SQLLoginPassword = "not-a-real-password"
    
        $params = @{
            ResourceGroupName = "dfc-foo-bar-rg"
            SQLServerName     = "dfc-foo-bar-sql"
            SQLDatabase       = "dfc-foo-bar-db" 
            SQLAdminUsername  = "admin"
            SQLAdminPassword  = "not-a-real-password"
            SQLLogin          = $SQLLogin
            SQLLoginPassword  = $SQLLoginPassword
        }
    
        # solves CommandNotFoundException
        function Invoke-Sqlcmd {}
        function Get-AzSqlServer {}
        function Get-AzSqlDatabase {}
    
        $SQLScript = "$TestDrive\Mock.sql"
    
        Mock Invoke-Sqlcmd
        Mock Get-AzSqlServer {
            $mock = '{ "ResourceGroupName": "dfc-foo-bar-rg", "ServerName": "dfc-foo-bar-sql", "FullyQualifiedDomainName": "dfc-foo-bar-sql.database.windows.net" }'
            return ConvertFrom-Json $mock
        }
    
        # mock Get-AzSqlDatabase returns offline
        Mock Get-AzSqlDatabase {
            $offlinemock = '{ "ResourceGroupName": "dfc-foo-bar-rg", "ServerName": "dfc-foo-bar-sql", "DatabaseName": "dfc-foo-bar-db", "Status": "Offline" }'
            return ConvertFrom-Json $offlinemock
        }
    
    }

    It "Should throw an error if database is not online" {

        { .\Set-SqlLoginPassword @params } | Should -Throw

    }


    It "Should issue a single Invoke-Sqlcmd when just reseting password" {

        # mock Get-AzSqlDatabase returns online
        Mock Get-AzSqlDatabase {
            $onlinemock = '{ "ResourceGroupName": "dfc-foo-bar-rg", "ServerName": "dfc-foo-bar-sql", "DatabaseName": "dfc-foo-bar-db", "Status": "Online" }'
            return ConvertFrom-Json $onlinemock
        }
        

        $ResetQuery = $ResetPasswordQuery = "ALTER USER [$SQLLogin] WITH PASSWORD = '$SQLLoginPassword';"

        .\Set-SqlLoginPassword @params

        Should -Invoke -CommandName Invoke-Sqlcmd -Exactly 1 -Scope It

    }

    It "Should error if optional SQL script passed but does not exist" {

        # mock Get-AzSqlDatabase returns online
        Mock Get-AzSqlDatabase {
            $onlinemock = '{ "ResourceGroupName": "dfc-foo-bar-rg", "ServerName": "dfc-foo-bar-sql", "DatabaseName": "dfc-foo-bar-db", "Status": "Online" }'
            return ConvertFrom-Json $onlinemock
        }
        
        Mock Write-Error

        $global:LoopsBeforeOnline = 0

        .\Set-SqlLoginPassword -UserScript $SQLScript @params

        Should -Invoke -CommandName Write-Error

    }

    It "Should run Invoke-Sqlcmd with inputfile when valid script is passed" {

        # mock Get-AzSqlDatabase returns online
        Mock Get-AzSqlDatabase {
            $onlinemock = '{ "ResourceGroupName": "dfc-foo-bar-rg", "ServerName": "dfc-foo-bar-sql", "DatabaseName": "dfc-foo-bar-db", "Status": "Online" }'
            return ConvertFrom-Json $onlinemock
        }

                
        Set-Content -Path $SQLScript -Value "SELECT 1"

        $global:LoopsBeforeOnline = 0

        .\Set-SqlLoginPassword @params

        Should -Invoke -CommandName Invoke-Sqlcmd -Exactly 1 -Scope It

    }

}

Push-Location -Path $PSScriptRoot