Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "New-TableOnStorageAccount unit tests" -Tag "Unit" {
        
    
    Context "When the storage account does not exist" {

        BeforeAll {
            # Re-define the three Az cmdlets under test, as we can't mock them directly.
            # They fire a ParameterBindingValidationException on both powershell core and powershell 5.
            # suspect it's due to https://github.com/pester/Pester/issues/619
            function New-AzStorageContext { 
                [CmdletBinding()]
                param($StorageAccountName, $StorageAccountKey)
            }
    
            function Get-AzStorageAccountKey {
                [CmdletBinding()]
                param($ResourceGroupName, $Name)
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
            Mock Get-AzStorageAccountKey -MockWith { 
                return @{
                    keyName = "key1"
                    Value   = "not-a-real-key"
                }
            }
    
            Mock Get-AzStorageAccountKey -MockWith { return $null }
        }
    

        It "should throw an exception" {
            { 
                ./New-TableOnStorageAccount -StorageAccountName SomeStorageAccount -ResourceGroupName aResourceGroup -TableName SomeTable
            } | Should -throw "Unable to fetch account keys from storage account 'SomeStorageAccount'"
        }

        It "should not get storage account keys" {
            Should -Invoke -CommandName Get-AzStorageAccountKey -Exactly 0
        }

        It "should not create any storage contexts" {
            Should -Invoke -CommandName New-AzStorageContext -Exactly 0
        }

        It "should not get any storage tables" {
            Should -Invoke -CommandName Get-AzStorageTable -Exactly 0
        }

        It "should not create any tables" {
            Should -Invoke -CommandName New-AzStorageTable -Exactly 0
        }
    }

    Context "When the table exists" {

        BeforeAll {
            # Re-define the three Az cmdlets under test, as we can't mock them directly.
            # They fire a ParameterBindingValidationException on both powershell core and powershell 5.
            # suspect it's due to https://github.com/pester/Pester/issues/619
            function New-AzStorageContext { 
                [CmdletBinding()]
                param($StorageAccountName, $StorageAccountKey)
            }
    
            function Get-AzStorageAccountKey {
                [CmdletBinding()]
                param($ResourceGroupName, $Name)
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
            Mock Get-AzStorageAccountKey -MockWith { 
                return @{
                    keyName = "key1"
                    Value   = "not-a-real-key"
                }
            }
    

            Mock Get-AzStorageTable -MockWith {
                return @{
                    Uri = "https://some/uri"
                }
            } 
        }
    



        It "should get storage account keys" {

            ./New-TableOnStorageAccount -StorageAccountName SomeStorageAccount -ResourceGroupName aResourceGroup -TableName SomeTable
            Should -Invoke -CommandName Get-AzStorageAccountKey -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "aResourceGroup" -and `
                    $Name -eq "SomeStorageAccount"
            }
        }

        It "Should create a new storage context" {

            ./New-TableOnStorageAccount -StorageAccountName SomeStorageAccount -ResourceGroupName aResourceGroup -TableName SomeTable
            Should -Invoke -CommandName New-AzStorageContext -Exactly 1 -ParameterFilter {
                $StorageAccountName -eq "SomeStorageAccount" -and `
                    $StorageAccountKey -eq "not-a-real-key"
            }
        }
        
        It "Should get the existing table" {

            ./New-TableOnStorageAccount -StorageAccountName SomeStorageAccount -ResourceGroupName aResourceGroup -TableName SomeTable
            Should -Invoke -CommandName Get-AzStorageTable -Exactly 1 -ParameterFilter { $Name -eq "SomeTable" }
        }

        It "Should not create a new table" {

            ./New-TableOnStorageAccount -StorageAccountName SomeStorageAccount -ResourceGroupName aResourceGroup -TableName SomeTable
            Should -Invoke -CommandName New-AzStorageTable -Exactly 0 
        }
    }

    Context "When the table does not exist" {

        BeforeAll {
            # Re-define the three Az cmdlets under test, as we can't mock them directly.
            # They fire a ParameterBindingValidationException on both powershell core and powershell 5.
            # suspect it's due to https://github.com/pester/Pester/issues/619
            function New-AzStorageContext { 
                [CmdletBinding()]
                param($StorageAccountName, $StorageAccountKey)
            }
    
            function Get-AzStorageAccountKey {
                [CmdletBinding()]
                param($ResourceGroupName, $Name)
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
            Mock Get-AzStorageAccountKey -MockWith { 
                return @{
                    keyName = "key1"
                    Value   = "not-a-real-key"
                }
            }
    
        }

        


        It "should get storage account keys" {
            ./New-TableOnStorageAccount -StorageAccountName SomeStorageAccount -ResourceGroupName aResourceGroup -TableName SomeTable
            Should -Invoke -CommandName Get-AzStorageAccountKey -Exactly 1 -ParameterFilter {
                $ResourceGroupName -eq "aResourceGroup" -and `
                    $Name -eq "SomeStorageAccount"
            }
        }

        It "Should create a new storage context" {
            ./New-TableOnStorageAccount -StorageAccountName SomeStorageAccount -ResourceGroupName aResourceGroup -TableName SomeTable
            Should -Invoke -CommandName New-AzStorageContext -Exactly 1 -ParameterFilter {
                $StorageAccountName -eq "SomeStorageAccount" -and `
                    $StorageAccountKey -eq "not-a-real-key"
            }
        }
        
        It "Should get the existing table" {
            ./New-TableOnStorageAccount -StorageAccountName SomeStorageAccount -ResourceGroupName aResourceGroup -TableName SomeTable
            Should -Invoke -CommandName Get-AzStorageTable -Exactly 1 -ParameterFilter { $Name -eq "SomeTable" }
        }

        It "Should create a new table" {
            ./New-TableOnStorageAccount -StorageAccountName SomeStorageAccount -ResourceGroupName aResourceGroup -TableName SomeTable
            Should -Invoke -CommandName New-AzStorageTable -Exactly 1 -ParameterFilter { $Name -eq "SomeTable" }
        }
    }
}