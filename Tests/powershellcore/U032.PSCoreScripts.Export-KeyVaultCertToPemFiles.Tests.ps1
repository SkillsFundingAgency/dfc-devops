Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Export-KeyVaultCertToPemFiles unit tests" -Tag "Unit" {

    ##set up mocks
    function New-PfxFileFromKeyVaultSecret {}
    
    Mock Get-AzStorageAccountKey -MockWith { return @(
        @{
            KeyName = "key1"
            Value = "not-a-real-key"
            Permissions = "full"
        },
        @{
            KeyName = "key2"
            Value = "not-a-real-key-either"
            Permissions = "full"
        }
    )}
    Mock New-AzStorageContext
    Mock Get-AzKeyVaultSecret
    Mock New-PfxFileFromKeyVaultSecret
    Mock Invoke-Expression
    Mock Set-AzStorageFileContent
    Mock Remove-Item
    
    Mock Set-AzStorageFileContent

    $Params = @{
                
        CertificateSecretName = "foo-bar-gov-uk"
        FileShare = "foofiles"
        KeyVaultName = "dfc-foo-shared-kv"
        StorageAccountName = "dfcfoosharedstr"
        StorageResourceGroupName = "dfc-foo-shared-rg"
    }

    Context "When passed a single output directory" {

        It "should create 4 cert files, copy 3 of those to a single fileshare then delete all 4 local files" {
            
            $Params["FullChainOutputDirectories"] = @("/https")
            $Params["PrivKeyOutputDirectories"] = @("/https")

            .\Export-KeyVaultCertToPemFiles @Params

            Assert-MockCalled Get-AzStorageAccountKey -Exactly 1
            Assert-MockCalled New-AzStorageContext -Exactly 1
            Assert-MockCalled Get-AzKeyVaultSecret -Exactly 1
            Assert-MockCalled Invoke-Expression -Exactly 1 -ParameterFilter { $Command -match "openssl pkcs12 -in .*\\PsExportedPfx.pfx -out .*\\cert.pem -nokeys -clcerts -password pass:\w{20}" }
            Assert-MockCalled Invoke-Expression -Exactly 1 -ParameterFilter { $Command -match "openssl pkcs12 -in .*\\PsExportedPfx.pfx -out .*\\fullchain.pem --chain -nokeys -password pass:\w{20}" }
            Assert-MockCalled Invoke-Expression -Exactly 1 -ParameterFilter { $Command -match "openssl pkcs12 -in .*\\PsExportedPfx.pfx -out .*\\privkey.pem -nocerts -nodes -password pass:\w{20}" }
            Assert-MockCalled Set-AzStorageFileContent -Exactly 3
            Assert-MockCalled Remove-Item -Exactly 4

        }

    }

    Context "When passed a two FullChainOutputDirectories" {

        It "should create 4 cert files, copy cert and fulllchain to two fileshares and privkey to one fileshare, then delete all 4 local files" {
            
            $Params["FullChainOutputDirectories"] = @("/https", "/https/trusted")
            $Params["PrivKeyOutputDirectories"] = @("/https")

            .\Export-KeyVaultCertToPemFiles @Params

            Assert-MockCalled Get-AzStorageAccountKey -Exactly 1
            Assert-MockCalled New-AzStorageContext -Exactly 1
            Assert-MockCalled Get-AzKeyVaultSecret -Exactly 1
            Assert-MockCalled Invoke-Expression -Exactly 1 -ParameterFilter { $Command -match "openssl pkcs12 -in .*\\PsExportedPfx.pfx -out .*\\cert.pem -nokeys -clcerts -password pass:\w{20}" }
            Assert-MockCalled Invoke-Expression -Exactly 1 -ParameterFilter { $Command -match "openssl pkcs12 -in .*\\PsExportedPfx.pfx -out .*\\fullchain.pem --chain -nokeys -password pass:\w{20}" }
            Assert-MockCalled Invoke-Expression -Exactly 1 -ParameterFilter { $Command -match "openssl pkcs12 -in .*\\PsExportedPfx.pfx -out .*\\privkey.pem -nocerts -nodes -password pass:\w{20}" }
            Assert-MockCalled Set-AzStorageFileContent -Exactly 5
            Assert-MockCalled Remove-Item -Exactly 4

        }

    }

}