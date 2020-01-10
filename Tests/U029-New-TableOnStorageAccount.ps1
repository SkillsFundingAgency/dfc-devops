Push-Location -Path $PSScriptRoot\..\PSScripts\

Describe "New-TableOnStorageAccount unit tests" -Tag "Unit" {
        
    # Re-define the three Az cmdlets under test, as we can't mock them directly.
    # They fire a ParameterBindingValidationException on both powershell core and powershell 5.
    # suspect it's due to https://github.com/pester/Pester/issues/619
    function New-AzStorageContext { 
        [CmdletBinding()]
        param($StorageAccountName, $StorageAccountKey)
    }

    function Get-AzStorageTable {
        [CmdletBinding()]
        param($Context, $Name)
    }

    function New-AzStorageTable {
        [CmdletBinding()]
        param($Context, $Name)
    }

    Mock New-AzStorageContext
    Mock New-AzStorageTable
    Mock Get-AzStorageTable -MockWith { return $null }

    Context "When the table exists" {
    
        Mock Get-AzStorageTable -MockWith { 
            return @{}
        }

        ./New-TableOnStorageAccount -StorageAccountName SomeStorageAccount -StorageAccountKey aStorageAccountKey -TableName SomeTable

        It "Should create a new storage context"  {
            Assert-MockCalled New-AzStorageContext -Exactly 1 -ParameterFilter { 
                $StorageAccountName -eq "SomeStorageAccount" -and `
                $StorageAccountKey -eq "aStorageAccountKey"
            }
        }
        
        It "Should get the existing table" {
            Assert-MockCalled Get-AzStorageTable -Exactly 1 -ParameterFilter { $Name -eq "SomeTable" }
        }

        It "Should not create a new table" {
            Assert-MockCalled New-AzStorageTable -Exactly 0 
        }
    }

    Context "When the table does not exist" {

        ./New-TableOnStorageAccount -StorageAccountName SomeStorageAccount -StorageAccountKey aStorageAccountKey -TableName SomeTable

        It "Should create a new storage context"  {
            Assert-MockCalled New-AzStorageContext -Exactly 1 -ParameterFilter { 
                $StorageAccountName -eq "SomeStorageAccount" -and `
                $StorageAccountKey -eq "aStorageAccountKey"
            }
        }
        
        It "Should get the existing table" {
            Assert-MockCalled Get-AzStorageTable -Exactly 1 -ParameterFilter { $Name -eq "SomeTable" }
        }

        It "Should create a new table" {
            Assert-MockCalled New-AzStorageTable -Exactly 1 -ParameterFilter { $Name -eq "SomeTable" }
        }
    }
}