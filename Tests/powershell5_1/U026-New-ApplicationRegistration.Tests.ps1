Push-Location -Path $PSScriptRoot\..\..\PSScripts\

Describe "New-ApplicationRegistration unit tests" -Tag "Unit" {

    BeforeAll {
        Mock Get-AzureRmContext { [PsCustomObject]
            @{
                Account = @{
                    Id = "35fd12f7-97c7-4f8c-8b10-00bf198ff4f8"
                }
            }

        }
        Mock Get-AzureRmADServicePrincipal -ParameterFilter { $ApplicationId } { [PsCustomObject]
            @{
                Id = "4a11d94c-9c97-4c0b-8f85-476c1ef15956"
            }
        }
        Mock Get-AzureRmADServicePrincipal
        Mock New-AzureRmADServicePrincipal
    }
    It "Should throw an error if a secret is requested and the KeyVault doesn't exist" {

        Mock Get-AzureRmKeyVault 

        $CmdletParameters = @{
            AppRegistrationName = "dfc-foo-bar-app"
            AddSecret           = $true
            KeyVaultName        = "dfc-foo-shared-kv"
        }

        { .\New-ApplicationRegistration @CmdletParameters } | Should -Throw "KeyVault dfc-foo-shared-kv doesn't exist, nowhere to store secret"

        Should -Invoke -CommandName Get-AzureRmContext -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzureRmADServicePrincipal -ParameterFilter { $ApplicationId } -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzureRmADServicePrincipal -Exactly 2 -Scope It
        Should -Invoke -CommandName Get-AzureRmKeyVault -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzureRmADServicePrincipal -Exactly 0 -Scope It

    }

    It "Should throw an error if a secret is requested and Azure DevOps SPN doesn't have SET permissions on the KeyVault" {

        Mock Get-AzureRmKeyVault { [PSCustomObject]
            @{
                VaultName      = "dfc-foo-shared-kv"
                AccessPolicies = @(
                    @{
                        ObjectId             = "4a11d94c-9c97-4c0b-8f85-476c1ef15956"
                        PermissionsToSecrets = @("Get", "List")
                    }
                )
            }
        }

        $CmdletParameters = @{
            AppRegistrationName = "dfc-foo-bar-app"
            AddSecret           = $true
            KeyVaultName        = "dfc-foo-shared-kv"
        }

        { .\New-ApplicationRegistration @CmdletParameters } | Should -Throw "Service Principal 4a11d94c-9c97-4c0b-8f85-476c1ef15956 doesn't have Set permission on KeyVault dfc-foo-shared-kv"

        Should -Invoke -CommandName Get-AzureRmContext -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzureRmADServicePrincipal -ParameterFilter { $ApplicationId } -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzureRmADServicePrincipal -Exactly 2 -Scope It
        Should -Invoke -CommandName Get-AzureRmKeyVault -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzureRmADServicePrincipal -Exactly 0 -Scope It

    }

    It "Should call New-AzureRmADServicePrincipal if the KeyVault exists and Azure DevOps SPN has SET permissions" {

        Mock Get-AzureRmKeyVault { [PSCustomObject]
            @{
                VaultName      = "dfc-foo-shared-kv"
                AccessPolicies = @(
                    @{
                        ObjectId             = "4a11d94c-9c97-4c0b-8f85-476c1ef15956"
                        PermissionsToSecrets = @("Get", "List", "Set")
                    }
                )
            }
        }
        Mock Set-AzureKeyVaultSecret

        $CmdletParameters = @{
            AppRegistrationName = "dfc-foo-bar-app"
            AddSecret           = $true
            KeyVaultName        = "dfc-foo-shared-kv"
        }

        .\New-ApplicationRegistration @CmdletParameters

        Should -Invoke -CommandName Get-AzureRmContext -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzureRmADServicePrincipal -ParameterFilter { $ApplicationId } -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzureRmADServicePrincipal -Exactly 2 -Scope It
        Should -Invoke -CommandName Get-AzureRmKeyVault -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzureRmADServicePrincipal -Exactly 1 -Scope It

    }

}

Push-Location -Path $PSScriptRoot