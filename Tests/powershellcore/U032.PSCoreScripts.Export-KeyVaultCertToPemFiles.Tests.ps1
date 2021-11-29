Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Export-KeyVaultCertToPemFiles unit tests" -Tag "Unit" {


    Context "When passed a single output directory" {

        BeforeAll {

            ##set up mocks
            function New-PfxFileFromKeyVaultSecret {}
    
            Mock Get-AzStorageAccountKey -MockWith { return @(
                    @{
                        KeyName     = "key1"
                        Value       = "not-a-real-key"
                        Permissions = "full"
                    },
                    @{
                        KeyName     = "key2"
                        Value       = "not-a-real-key-either"
                        Permissions = "full"
                    }
                ) }
            Mock New-AzStorageContext
            Mock Get-AzKeyVaultSecret
            Mock New-PfxFileFromKeyVaultSecret
            Mock Invoke-Expression
            Mock Set-AzStorageFileContent
            Mock Remove-Item
    
            Mock Set-AzStorageFileContent

            $Params = @{
                
                CertificateSecretName    = "foo-bar-gov-uk"
                FileShare                = "foofiles"
                KeyVaultName             = "dfc-foo-shared-kv"
                StorageAccountName       = "dfcfoosharedstr"
                StorageResourceGroupName = "dfc-foo-shared-rg"
            }

        }
        It "should create 4 cert files, copy 3 of those to a single fileshare then delete all 4 local files" {
            
            $Params["FullChainOutputDirectories"] = @("/https")
            $Params["PrivKeyOutputDirectories"] = @("/https")

            .\Export-KeyVaultCertToPemFiles @Params

            Should -Invoke -CommandName Get-AzStorageAccountKey -Exactly 1
            Should -Invoke -CommandName New-AzStorageContext -Exactly 1
            Should -Invoke -CommandName Get-AzKeyVaultSecret -Exactly 1
            Should -Invoke -CommandName Invoke-Expression -Exactly 1 -ParameterFilter { $Command -match "openssl pkcs12 -in .*\\PsExportedPfx.pfx -out .*\\cert.pem -nokeys -clcerts -password pass:\w{20}" }
            Should -Invoke -CommandName Invoke-Expression -Exactly 1 -ParameterFilter { $Command -match "openssl pkcs12 -in .*\\PsExportedPfx.pfx -out .*\\fullchain.pem --chain -nokeys -password pass:\w{20}" }
            Should -Invoke -CommandName Invoke-Expression -Exactly 1 -ParameterFilter { $Command -match "openssl pkcs12 -in .*\\PsExportedPfx.pfx -out .*\\privkey.pem -nocerts -nodes -password pass:\w{20}" }
            Should -Invoke -CommandName Set-AzStorageFileContent -Exactly 3
            Should -Invoke -CommandName Remove-Item -Exactly 4

        }

    }

    Context "When passed a two FullChainOutputDirectories" {

        BeforeAll {

            ##set up mocks
            function New-PfxFileFromKeyVaultSecret {}
    
            Mock Get-AzStorageAccountKey -MockWith { return @(
                    @{
                        KeyName     = "key1"
                        Value       = "not-a-real-key"
                        Permissions = "full"
                    },
                    @{
                        KeyName     = "key2"
                        Value       = "not-a-real-key-either"
                        Permissions = "full"
                    }
                ) }
            Mock New-AzStorageContext
            Mock Get-AzKeyVaultSecret
            Mock New-PfxFileFromKeyVaultSecret
            Mock Invoke-Expression
            Mock Set-AzStorageFileContent
            Mock Remove-Item
    
            Mock Set-AzStorageFileContent

            $Params = @{
                
                CertificateSecretName    = "foo-bar-gov-uk"
                FileShare                = "foofiles"
                KeyVaultName             = "dfc-foo-shared-kv"
                StorageAccountName       = "dfcfoosharedstr"
                StorageResourceGroupName = "dfc-foo-shared-rg"
            }

        }
        It "should create 4 cert files, copy cert and fulllchain to two fileshares and privkey to one fileshare, then delete all 4 local files" {
            
            $Params["FullChainOutputDirectories"] = @("/https", "/https/trusted")
            $Params["PrivKeyOutputDirectories"] = @("/https")

            .\Export-KeyVaultCertToPemFiles @Params

            Should -Invoke -CommandName Get-AzStorageAccountKey -Exactly 1
            Should -Invoke -CommandName New-AzStorageContext -Exactly 1
            Should -Invoke -CommandName Get-AzKeyVaultSecret -Exactly 1
            Should -Invoke -CommandName Invoke-Expression -Exactly 1 -ParameterFilter { $Command -match "openssl pkcs12 -in .*\\PsExportedPfx.pfx -out .*\\cert.pem -nokeys -clcerts -password pass:\w{20}" }
            Should -Invoke -CommandName Invoke-Expression -Exactly 1 -ParameterFilter { $Command -match "openssl pkcs12 -in .*\\PsExportedPfx.pfx -out .*\\fullchain.pem --chain -nokeys -password pass:\w{20}" }
            Should -Invoke -CommandName Invoke-Expression -Exactly 1 -ParameterFilter { $Command -match "openssl pkcs12 -in .*\\PsExportedPfx.pfx -out .*\\privkey.pem -nocerts -nodes -password pass:\w{20}" }
            Should -Invoke -CommandName Set-AzStorageFileContent -Exactly 5
            Should -Invoke -CommandName Remove-Item -Exactly 4

        }

    }

}