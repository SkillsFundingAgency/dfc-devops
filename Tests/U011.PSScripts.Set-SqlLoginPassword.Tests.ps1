Push-Location -Path $PSScriptRoot\..\PSScripts\

$SQLLogin = "connection-user"
$SQLLoginPassword = "not-a-real-password"

$params = @{
    SQLServerFqdn     = "dfc-foo-bar-sql"
    SQLDatabase       = "dfc-foo-bar-db" 
    SQLAdminUsername  = "admin"
    SQLAdminPassword  = "not-a-real-password"
    SQLLogin          = $SQLLogin
    SQLLoginPassword  = $SQLLoginPassword
}

Describe "Set-SqlLoginPassword unit tests" -Tag "Unit" {

    $SQLScript = "$TestDrive\Mock.sql"

    Mock Invoke-Sqlcmd

    It "Should issue a single Invoke-Sqlcmd when just reseting password" {

        $ResetQuery = $ResetPasswordQuery = "ALTER USER [$SQLLogin] WITH PASSWORD = '$SQLLoginPassword';"

        .\Set-SqlLoginPassword @params

        Assert-MockCalled Invoke-Sqlcmd -Exactly 1 -Scope It
        Assert-MockCalled Invoke-Sqlcmd -ParameterFilter { $Query -eq $ResetQuery }

    }

    It "Should error if optional SQL script passed but does not exist" {

        Mock Write-Error

        .\Set-SqlLoginPassword -UserScript $SQLScript @params

        Assert-MockCalled Write-Error

    }

    It "Should run Invoke-Sqlcmd with inputfile when valid script is passed" {

        Set-Content -Path $SQLScript -Value "SELECT 1"

        .\Set-SqlLoginPassword @params

        Assert-MockCalled Invoke-Sqlcmd

    }

}

Push-Location -Path $PSScriptRoot