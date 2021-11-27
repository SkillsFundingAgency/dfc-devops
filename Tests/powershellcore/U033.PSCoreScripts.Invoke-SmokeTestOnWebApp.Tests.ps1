﻿Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Invoke-SmokeTestsOnWebApp unit tests" -Tag "Unit" {
    BeforeAll {
        Mock Start-Sleep
        Mock Invoke-WebRequest -MockWith {
            return @{ StatusCode = 200 }
        }
        Mock Get-AzWebAppSlot -MockWith {
            return @{ DefaultHostName = "site.azurewebsites.net" }
        }
    
    }

    Context "When performing a smoke test that is initially succesful" {

        BeforeAll {
            $params = @{
                AppName               = "SomeWebApp"
                ResourceGroup         = "SomeResourceGroup"
                Slot                  = "ASlot"
                Path                  = "/path"
                BackOffPeriodInSecs   = 10
                TimeoutInSecs         = 7
                AttemptsBeforeFailure = 3
            }
    
           
        }

        It "should get the web app by slot" {

            Assert-MockCalled Get-AzWebAppSlot -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq $params.ResourceGroup -and `
                    $Name -eq $params.AppName -and `
                    $Slot -eq $params.Slot
            }
        }

        It "should perform a web request to the site" {

            {
                ./Invoke-SmokeTestOnWebApp.ps1 @params
            } | Should -Not -Throw
    
            Assert-MockCalled Invoke-WebRequest -Exactly 1 -ParameterFilter {
                $Uri -eq "https://site.azurewebsites.net/path" -and `
                    $TimeoutSec -eq $params.TimeoutInSecs -and `
                    $Method -eq "Get" -and `
                    $MaximumRedirection -eq 0 -and `
                    $UseBasicParsing.IsPresent
            }
        }

        It "should not sleep" {
            Assert-MockCalled Start-Sleep -Exactly 0
        }
    }

    Context "When performing a smoke test that times out" {

        BeforeAll {
            $params = @{
                AppName               = "SomeWebApp"
                ResourceGroup         = "SomeResourceGroup"
                Slot                  = "ASlot"
                Path                  = "/path"
                BackOffPeriodInSecs   = 10
                TimeoutInSecs         = 7
                AttemptsBeforeFailure = 3
            }
    
            Mock Invoke-WebRequest -MockWith { throw "timeout" }
    
            {
                ./Invoke-SmokeTestOnWebApp.ps1 @params
            } | Should -Throw "Smoke test exhausted all retry attempts and is still not responding"
        }

        It "should get the web app by slot" {
            Assert-MockCalled Get-AzWebAppSlot -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq $params.ResourceGroup -and `
                    $Name -eq $params.AppName -and `
                    $Slot -eq $params.Slot
            }
        }

        It "should perform a web requests to the site" {
            Assert-MockCalled Invoke-WebRequest -Exactly 3 -ParameterFilter {
                $Uri -eq "https://site.azurewebsites.net/path" -and `
                    $TimeoutSec -eq $params.TimeoutInSecs -and `
                    $Method -eq "Get" -and `
                    $MaximumRedirection -eq 0 -and `
                    $UseBasicParsing.IsPresent
            }
        }

        It "should sleep on each loop apart from the last" {
            Assert-MockCalled Start-Sleep -Exactly 2 -ParameterFilter { $Seconds -eq $params.BackOffPeriodInSecs }
        }
    }

    Context "When performing a smoke test that returns a non-OK status code" {

        BeforeAll {
            $params = @{
                AppName               = "SomeWebApp"
                ResourceGroup         = "SomeResourceGroup"
                Slot                  = "ASlot"
                Path                  = "/path"
                BackOffPeriodInSecs   = 10
                TimeoutInSecs         = 7
                AttemptsBeforeFailure = 3
            }

            Mock Invoke-WebRequest -MockWith { return @{ StatusCode = 302 } }

            {
                ./Invoke-SmokeTestOnWebApp.ps1 @params
            } | Should -Throw "Smoke test exhausted all retry attempts and is still not responding"

        }
        It "should get the web app by slot" {
            Assert-MockCalled Get-AzWebAppSlot -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq $params.ResourceGroup -and `
                    $Name -eq $params.AppName -and `
                    $Slot -eq $params.Slot
            }
        }

        It "should perform a web requests to the site" {
            Assert-MockCalled Invoke-WebRequest -Exactly 3 -ParameterFilter {
                $Uri -eq "https://site.azurewebsites.net/path" -and `
                    $TimeoutSec -eq $params.TimeoutInSecs -and `
                    $Method -eq "Get" -and `
                    $MaximumRedirection -eq 0 -and `
                    $UseBasicParsing.IsPresent
            }
        }

        It "should sleep on each loop apart from the last" {
            Assert-MockCalled Start-Sleep -Exactly 2 -ParameterFilter { $Seconds -eq $params.BackOffPeriodInSecs }
        }
    }

    Context "When performing a smoke test that fails then succeeds" {

        BeforeAll{

            $script:actualAttempts = 0

            Mock Invoke-WebRequest -MockWith {
                # Conditional mock that only returns true on the third run of Invoke-WebRequest
                $script:actualAttempts++
    
                if ($script:actualAttempts -eq 3) {
                    return @{ StatusCode = 200 }
                }
                return @{ StatusCode = 500 }
            }
    
            $params = @{
                AppName               = "SomeWebApp"
                ResourceGroup         = "SomeResourceGroup"
                Slot                  = "ASlot"
                Path                  = "/path"
                BackOffPeriodInSecs   = 10
                TimeoutInSecs         = 7
                AttemptsBeforeFailure = 5
            }
    
            ./Invoke-SmokeTestOnWebApp.ps1 @params
            }

        It "should get the smoke test url from the web app" {
            Assert-MockCalled Get-AzWebAppSlot -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq $params.ResourceGroup -and `
                    $Name -eq $params.AppName -and `
                    $Slot -eq $params.Slot
            }
        }

        It "should perform a web requests to the site" {
            Assert-MockCalled Invoke-WebRequest -Exactly 3 -ParameterFilter {
                $Uri -eq "https://site.azurewebsites.net/path" -and `
                    $TimeoutSec -eq $params.TimeoutInSecs -and `
                    $Method -eq "Get" -and `
                    $MaximumRedirection -eq 0 -and `
                    $UseBasicParsing.IsPresent -eq $true
            }
        }

        It "should sleep on each loop apart from the last" {
            Assert-MockCalled Start-Sleep -Exactly 2
        }
    }
}

Push-Location -Path $PSScriptRoot