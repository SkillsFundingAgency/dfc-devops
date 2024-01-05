Push-Location -Path $PSScriptRoot\..\..\PSScripts\

# Note: this test/script requires Az 6.6.0 to run.
# This is because AZ 7 ONWARDS switched the *AzAd* cmdlets to use MSGraph instead of AzureAD 

function New-AzADServicePrincipal {}
function Get-AzADServicePrincipal {}
function Get-AzADServicePrincipal {}
function Get-AzContext {}


Describe "New-ApplicationRegistration unit tests" -Tag "Unit" {

    BeforeAll {
        Mock Get-AzContext { [PsCustomObject]
            @{
                Account = @{
                    Id = "35fd12f7-97c7-4f8c-8b10-00bf198ff4f8"
                }
            }

        }
        Mock Get-AzADServicePrincipal -ParameterFilter { $ApplicationId } { [PsCustomObject]
            @{
                Id = "4a11d94c-9c97-4c0b-8f85-476c1ef15956"
            }
        }
        Mock Get-AzADServicePrincipal
        Mock New-AzADServicePrincipal
    }
    It "Should throw an error if a secret is requested and the KeyVault doesn't exist" {

        Mock Get-AzKeyVault

        $CmdletParameters = @{
            AppRegistrationName = "dfc-foo-bar-app"
            AddSecret           = $true
            KeyVaultName        = "dfc-foo-shared-kv"
        }

        { .\New-ApplicationRegistration @CmdletParameters } | Should -Throw "KeyVault dfc-foo-shared-kv doesn't exist, nowhere to store secret"

        Should -Invoke -CommandName Get-AzContext -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzADServicePrincipal -ParameterFilter { $ApplicationId } -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzADServicePrincipal -Exactly 2 -Scope It
        Should -Invoke -CommandName Get-AzKeyVault -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzADServicePrincipal -Exactly 0 -Scope It

    }

    It "Should throw an error if a secret is requested and Azure DevOps SPN doesn't have SET permissions on the KeyVault" {

        Mock Get-AzKeyVault { [PSCustomObject]
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

        Should -Invoke -CommandName Get-AzContext -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzADServicePrincipal -ParameterFilter { $ApplicationId } -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzADServicePrincipal -Exactly 2 -Scope It
        Should -Invoke -CommandName Get-AzKeyVault -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzADServicePrincipal -Exactly 0 -Scope It

    }

    It "Should call New-AzADServicePrincipal if the KeyVault exists and Azure DevOps SPN has SET permissions" {

        Mock Get-AzKeyVault { [PSCustomObject]
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
        Mock Set-AzKeyVaultSecret

        $CmdletParameters = @{
            AppRegistrationName = "dfc-foo-bar-app"
            AddSecret           = $true
            KeyVaultName        = "dfc-foo-shared-kv"
        }

        .\New-ApplicationRegistration @CmdletParameters

        Should -Invoke -CommandName Get-AzContext -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzADServicePrincipal -ParameterFilter { $ApplicationId } -Exactly 1 -Scope It
        Should -Invoke -CommandName Get-AzADServicePrincipal -Exactly 2 -Scope It
        Should -Invoke -CommandName Get-AzKeyVault -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzADServicePrincipal -Exactly 1 -Scope It

    }

}

Push-Location -Path $PSScriptRoot