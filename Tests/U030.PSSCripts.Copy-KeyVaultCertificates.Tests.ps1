Push-Location -Path $PSScriptRoot\..\PSScripts\

Describe "Copy-KeyVaultCertificates unit tests" -Tag "Unit" {

    # Re-define the Az cmdlets under test, as we can't mock them directly.
    # They fire a ParameterBindingValidationException on both powershell core and powershell 5.
    # suspect it's due to https://github.com/pester/Pester/issues/619
    function Get-AzKeyVaultCertificate { 
        [CmdletBinding()]
        param($StorageAccountName, $StorageAccountKey)
    }

    function Backup-AzKeyVaultCertificate { 
        [CmdletBinding()]
        param($StorageAccountName, $StorageAccountKey)
    }

    function Restore-AzKeyVaultCertificate { 
        [CmdletBinding()]
        param($StorageAccountName, $StorageAccountKey)
    }

    Mock Get-AzKeyVaultCertificate
    Mock Backup-AzKeyVaultCertificate
    Mock Restore-AzKeyVaultCertificate

    Context "When no certificates are in the source key vault" {
        Mock Get-AzKeyVaultCertificate -MockWith { return $null }

        ./Copy-KeyVaultCertificates -SourceKeyVaultName dfc-from-foo-kv -DestinationKeyVaultName dfc-to-foo-kv

        It "should not create any storage contexts" {
            Assert-MockCalled Backup-AzKeyVaultCertificate -Exactly 0
        }

        It "should not get any storage tables" {
            Assert-MockCalled Restore-AzKeyVaultCertificate -Exactly 0
        }
    }

    Context "When a certificate exists in the source but not in the destination key vault" {
    }

    Context "When a certificate exists in the source and destination key vault with the same age" {
    }

    Context "When a certificate exists in the source and destination key vault but the source is newer" {
    }
}