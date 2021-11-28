Push-Location -Path $PSScriptRoot\..\..\PSScripts\


Describe "Invoke-SqlScript unit tests" -Tag "Unit" {

    BeforeAll {
        # solves CommandNotFoundException
        function Invoke-Sqlcmd {}

        $params = @{
            SQLServerFqdn    = "dfc-foo-bar-sql"
            SQLDatabase      = "dfc-foo-bar-db" 
            SQLAdminUsername = "admin"
            SQLAdminPassword = "not-a-real-password"
            SQLScript        = "$TestDrive\Mock.sql"
        }
    
        Mock Invoke-Sqlcmd

        

    }

    It "Should error if SQL script does not exist" {

        Mock Write-Error

        .\Invoke-SqlScript @params

        Should -Invoke -CommandName Write-Error

    }

  

    It "Should run Invoke-Sqlcmd with inputfile when valid script is passed" {

        Set-Content -Path $params.SQLScript -Value "SELECT 1"

        .\Invoke-SqlScript @params

        Should -Invoke -CommandName Invoke-Sqlcmd -Exactly 1 -Scope It

    }

}

Push-Location -Path $PSScriptRoot