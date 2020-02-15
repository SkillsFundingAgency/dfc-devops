Push-Location -Path $PSScriptRoot\..\..\PSScripts\

Describe "Add-AzureAdApiPermissionsToApp unit tests" -Tag "Unit" {

    Mock Get-AzureRmContext { [PsCustomObject]
        @{
            Account = @{
                Id = "35fd12f7-97c7-4f8c-8b10-00bf198ff4f8"
            }
            TokenCache = New-Object Microsoft.IdentityModel.Clients.ActiveDirectory.TokenCache
        }

    }
    Mock Get-AzureRmADServicePrincipal -ParameterFilter { $ApplicationId } { [PsCustomObject]
        @{
            Id = "4a11d94c-9c97-4c0b-8f85-476c1ef15956"
        }
    }
    Mock Get-AzureRmADApplication { [PsCustomObject] 
        @{
            ObjectId = "b68bcf9f-9ec6-47b6-bcc4-8efa9a0c497d"
            DisplayName = "dfc-foo-bar-app"
        }
    }
    Mock Set-AzureAdApplication

    #Script relies on .NET method which can't be mocked.  Lines 100 - 115 will need to be moved into a seperate external function which can be mocked.
    It "Should call Set-AzureAdApplication when called with delegated permissions" -Skip {

        $CmdletParameters = @{
            AppRegistrationDisplayName = "dfc-foo-bar-app"
            ApiName = "Microsoft Graph"
            DelegatedPermissions =  @("Directory.Read.All", "User.Read")
        }

        .\Add-AzureAdApiPermissionsToApp @CmdletParameters

        Assert-MockCalled Get-AzureRmADApplication -Exactly 1 -Scope It
        Assert-MockCalled Set-AzureRmADApplication -Exactly 1 -Scope It -ParameterFilter { $ObjectId -eq "b68bcf9f-9ec6-47b6-bcc4-8efa9a0c497d" -and $RequiredResourceAccess }
    }
}