Push-Location -Path $PSScriptRoot\..\..\PSScripts\

# solves CommandNotFoundException
function Invoke-Sqlcmd {}

Describe "Invoke-SqlScript unit tests" -Tag "Unit" {

    $params = @{
        SQLServerFqdn     = "dfc-foo-bar-sql"
        SQLDatabase       = "dfc-foo-bar-db" 
        SQLAdminUsername  = "admin"
        SQLAdminPassword  = "not-a-real-password"
        SQLScript         = "$TestDrive\Mock.sql"
    }
    
    Mock Invoke-Sqlcmd

    It "Should error if SQL script does not exist" {

        Mock Write-Error

        .\Invoke-SqlScript @params

        Assert-MockCalled Write-Error

    }

    Set-Content -Path $params.SQLScript -Value "SELECT 1"

    It "Should run Invoke-Sqlcmd with inputfile when valid script is passed" {

        .\Invoke-SqlScript @params

        Assert-MockCalled Invoke-Sqlcmd -Exactly 1 -Scope It

    }

}

Push-Location -Path $PSScriptRoot