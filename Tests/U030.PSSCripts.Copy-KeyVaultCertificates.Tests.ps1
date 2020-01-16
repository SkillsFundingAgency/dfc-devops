Push-Location -Path $PSScriptRoot\..\PSScripts\

# Used to stop cmdlet not found errors
function Get-AzKeyVaultCertificate {
    param ($VaultName, $Name)
}
function Backup-AzKeyVaultCertificate {
    param ($InputObject, $OutputFile)
}
function Restore-AzKeyVaultCertificate {
    param ($VaultName, $Inputfile)
}
function Get-AzKeyVault {
    param ($VaultName)
}

Describe "Copy-KeyVaultCertificates unit tests" -Tag "Unit" {



    Mock Get-AzKeyVaultCertificate -ParameterFilter { $name -eq 'oldcert' } -MockWith {
        return [PsCustomObject] @(
            @{
                Name    = 'oldcert'
                Updated = Get-Date "2019-01-01T12:00:00"
            }
        )
    }

    # if this gets called throw an error as tests have gone wrong
    Mock Get-AzKeyVaultCertificate -MockWith { throw "Certificate name not found" }

    Mock Get-AzKeyVault -ParameterFilter { $VaultName -eq 'dfc-from-foo-kv' } -MockWith {
        return [PsCustomObject] @{  
            VaultName = 'dfc-from-foo-kv'
        }
    }

    Mock Get-AzKeyVault -ParameterFilter { $VaultName -eq 'dfc-to-foo-kv' } -MockWith {
        return [PsCustomObject] @{  
            VaultName = 'dfc-to-foo-kv'
        }
    }

    # if the key vault name is not one of the above throw an error as tests have gone wrong
    Mock Get-AzKeyVault -MockWith { throw "vaultname did not match" }

    Mock Backup-AzKeyVaultCertificate
    Mock Restore-AzKeyVaultCertificate
    Mock Remove-Item

    Context "When the source key vault does not exist" {

        Mock Get-AzKeyVault -ParameterFilter { $VaultName -eq 'dfc-from-foo-kv' } -MockWith { return $null }
        
        It "should throw an exception" {
            { 
                ./Copy-KeyVaultCertificates -SourceKeyVaultName dfc-from-foo-kv -DestinationKeyVaultName dfc-to-foo-kv
            } | Should throw "Cannot find dfc-from-foo-kv"
        }

    }

    Context "When the destination key vault does not exist" {

        Mock Get-AzKeyVault -ParameterFilter { $VaultName -eq 'dfc-to-foo-kv' } -MockWith { return $null }
        
        It "should throw an exception" {
            { 
                ./Copy-KeyVaultCertificates -SourceKeyVaultName dfc-from-foo-kv -DestinationKeyVaultName dfc-to-foo-kv
            } | Should throw "Cannot find dfc-to-foo-kv"
        }

    }

    Context "When no certificates are in the source key vault" {

        Mock Get-AzKeyVaultCertificate -MockWith { return [PsCustomObject] @() }

        ./Copy-KeyVaultCertificates -SourceKeyVaultName dfc-from-foo-kv -DestinationKeyVaultName dfc-to-foo-kv

        It "should only have called Get-AzKeyVaultCertificate once (to return an empty list)" {
            Assert-MockCalled Get-AzKeyVaultCertificate -Exactly 1
        }

        It "should not backup any certs" {
            Assert-MockCalled Backup-AzKeyVaultCertificate -Exactly 0
        }

        It "should not restore any certs" {
            Assert-MockCalled Restore-AzKeyVaultCertificate -Exactly 0
        }

        It "should not try deleting the backup" {
            Assert-MockCalled Remove-Item -Exactly 0
        }
    }

    Context "When a certificate exists in the source but not in the destination key vault" {

        Mock Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-from-foo-kv' -and $name -eq 'newcert' } -MockWith {
            return [PsCustomObject] @(
                @{
                    Name    = 'newcert'
                    Updated = Get-Date 
                }
            )
        }

        Mock Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-to-foo-kv' -and $Name -eq 'newcert' } -MockWith {
            return $null
        }

        Mock Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-from-foo-kv' -and -not $Name } -MockWith { return [PsCustomObject] @(
            @{
                Name = 'newcert'
            }
        ) }

        ./Copy-KeyVaultCertificates -SourceKeyVaultName dfc-from-foo-kv -DestinationKeyVaultName dfc-to-foo-kv -verbose

        It "should call Get-AzKeyVaultCertificate to get a list of certs (returns 1)" {
            Assert-MockCalled Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-from-foo-kv' -and -not $Name } -Exactly 1
        }

        It "should call Get-AzKeyVaultCertificate to get the cert details in source" {
            Assert-MockCalled Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-from-foo-kv' -and $name -eq 'newcert' } -Exactly 1
        }

        It "should call Get-AzKeyVaultCertificate to get the cert in the destination" {
            Assert-MockCalled Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-to-foo-kv' -and $Name -eq 'newcert' } -Exactly 1
        }

        It "should backup a certs" {
            Assert-MockCalled Backup-AzKeyVaultCertificate -Exactly 1
        }

        It "should restore a certs" {
            Assert-MockCalled Restore-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-to-foo-kv' } -Exactly 1
        }

        It "should delete the backup" {
            Assert-MockCalled Remove-Item -Exactly 1
        }
    }

    Context "When a certificate exists in the source and destination key vault with the same age" {

        Mock Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-from-foo-kv' -and $name -eq 'currentcert' } -MockWith {
            return [PsCustomObject] @(
                @{
                    Name    = 'currentcert'
                    Updated = Get-Date "2020-01-01T12:00:00"
                }
            )
        }

        Mock Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-to-foo-kv' -and $name -eq 'currentcert' } -MockWith {
            return [PsCustomObject] @(
                @{
                    Name    = 'currentcert'
                    Updated = Get-Date "2020-01-01T12:00:00"
                }
            )
        }

        Mock Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-from-foo-kv' -and -not $Name } -MockWith { return [PsCustomObject] @(
            @{
                Name = 'currentcert'
            }
        ) }

        ./Copy-KeyVaultCertificates -SourceKeyVaultName dfc-from-foo-kv -DestinationKeyVaultName dfc-to-foo-kv -verbose

        It "should call Get-AzKeyVaultCertificate to get a list of certs (returns 1)" {
            Assert-MockCalled Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-from-foo-kv' -and -not $Name } -Exactly 1
        }

        It "should call Get-AzKeyVaultCertificate to get the cert details in source" {
            Assert-MockCalled Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-from-foo-kv' -and $name -eq 'currentcert' } -Exactly 1
        }

        It "should call Get-AzKeyVaultCertificate to get the cert in the destination" {
            Assert-MockCalled Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-to-foo-kv' -and $Name -eq 'currentcert' } -Exactly 1
        }

        It "should not backup any certs" {
            Assert-MockCalled Backup-AzKeyVaultCertificate -Exactly 0
        }

        It "should not restore any certs" {
            Assert-MockCalled Restore-AzKeyVaultCertificate -Exactly 0
        }

        It "should not try deleting the backup" {
            Assert-MockCalled Remove-Item -Exactly 0
        }

    }

    Context "When a certificate exists in the source and destination key vault but the source is newer" {

        Mock Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-from-foo-kv' -and -not $Name } -MockWith { return [PsCustomObject] @(
            @{
                Name = 'updatedcert'
            }
        ) }
        Mock Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-from-foo-kv' -and $name -eq 'updatedcert' } -MockWith {
            return [PsCustomObject] @(
                @{
                    Name    = 'updatedcert'
                    Updated = Get-Date "2020-01-01T12:00:00" # newer
                }
            )
        }
        Mock Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-to-foo-kv' -and $name -eq 'updatedcert' } -MockWith {
            return [PsCustomObject] @(
                @{
                    Name    = 'updatedcert'
                    Updated = Get-Date "2019-01-01T12:00:00" # older
                }
            )
        }
    
        ./Copy-KeyVaultCertificates -SourceKeyVaultName dfc-from-foo-kv -DestinationKeyVaultName dfc-to-foo-kv -verbose

        It "should call Get-AzKeyVaultCertificate to get a list of certs (returns 1)" {
            Assert-MockCalled Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-from-foo-kv' -and -not $Name } -Exactly 1
        }

        It "should call Get-AzKeyVaultCertificate to get the cert details in source" {
            Assert-MockCalled Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-from-foo-kv' -and $name -eq 'updatedcert' } -Exactly 1
        }

        It "should call Get-AzKeyVaultCertificate to get the cert in the destination" {
            Assert-MockCalled Get-AzKeyVaultCertificate -ParameterFilter { $VaultName -eq 'dfc-to-foo-kv' -and $Name -eq 'updatedcert' } -Exactly 1
        }

        It "should backup the cert" {
            Assert-MockCalled Backup-AzKeyVaultCertificate -Exactly 1
        }

        It "should restore the cert" {
            Assert-MockCalled Restore-AzKeyVaultCertificate -Exactly 1
        }

        It "should delete the backup" {
            Assert-MockCalled Remove-Item -Exactly 1
        }

    }
}

Push-Location -Path $PSScriptRoot