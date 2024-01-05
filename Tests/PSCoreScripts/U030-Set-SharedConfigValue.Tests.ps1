Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Set-SharedConfigValue unit tests" -Tag "Unit" {



    Context "When updating from a string and the entry does not exist" {

        BeforeAll {
            Mock Get-AzStorageAccount -MockWith { 
                # This returns a new PSCustom object that implements all the properties that IStorageContest does
                return [PSCustomObject]@{
                    BlobEndPoint         = ""
                    ConnectionString     = ""
                    Context              = $null
                    EmptyContextInstance = ""
                    ExtendedProperties   = ""
                    FileEndPoint         = ""
                    Name                 = ""
                    QueueEndPoint        = ""
                    StorageAccount       = ""
                    StorageAccountName   = ""
                    TableEndPoint        = ""
                }
            }
            Mock Get-AzStorageTable -MockWith { return @{ CloudTable = @{} } }
            Mock Get-AzTableRow
            Mock Add-AzTableRow
            Mock Update-AzTableRow
            Mock Get-Content
            $params = @{
                StorageAccountName = "aStorageAccount"
                ResourceGroupName  = "aResourceGroup"
                TableName          = "someTable"
                PartitionKey       = "aPartitionKey"
                RowKey             = "aRowKey"
                JsonString         = "aJsonObject"
            }
        }
    


        It "should get the storage account" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-AzStorageAccount -Exactly 1 -ParameterFilter { $Name -eq "aStorageAccount" -and $ResourceGroupName -eq "aResourceGroup" }
        }

        It "should get the storage table" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-AzStorageTable -Exactly 1 -ParameterFilter { $Name -eq "someTable" }
        }

        It "should not get the contents of any files" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-Content -Exactly 0
        }

        It "should attempt to get the table row by partition and row key" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-AzTableRow -Exactly 1
        }

        It "should add a new row to the storage table" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Add-AzTableRow -Exactly 1 -ParameterFilter {
                $PartitionKey -eq "aPartitionKey" -and `
                    $RowKey -eq "aRowKey" -and `
                    $property.Data -eq "aJsonObject"
            }
        }

        It "should not update any rows in the storge table" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Update-AzTableRow -Exactly 0
        }
    }

    Context "When updating from a string and the entry exists" {
        BeforeAll {
            Mock Get-AzStorageAccount -MockWith { 
                # This returns a new PSCustom object that implements all the properties that IStorageContest does
                return [PSCustomObject]@{
                    BlobEndPoint         = ""
                    ConnectionString     = ""
                    Context              = $null
                    EmptyContextInstance = ""
                    ExtendedProperties   = ""
                    FileEndPoint         = ""
                    Name                 = ""
                    QueueEndPoint        = ""
                    StorageAccount       = ""
                    StorageAccountName   = ""
                    TableEndPoint        = ""
                }
            }
            Mock Get-AzStorageTable -MockWith { return @{ CloudTable = @{} } }
            Mock Get-AzTableRow
            Mock Add-AzTableRow
            Mock Update-AzTableRow
            Mock Get-Content
            $params = @{
                StorageAccountName = "aStorageAccount"
                ResourceGroupName  = "aResourceGroup"
                TableName          = "someTable"
                PartitionKey       = "aPartitionKey"
                RowKey             = "aRowKey"
                JsonString         = "aJsonObject"
            }
    
            Mock Get-AzTableRow -MockWith { return @{
                    Data         = "someData"
                    PartitionKey = "aPartitionKey"
                    RowKey       = "aRowKey"
                } }
        }
    



        It "should get the storage account" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-AzStorageAccount -Exactly 1 -ParameterFilter { $Name -eq "aStorageAccount" -and $ResourceGroupName -eq "aResourceGroup" }
        }

        It "should get the storage table" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-AzStorageTable -Exactly 1 -ParameterFilter { $Name -eq "someTable" }
        }

        It "should not get the contents of any files" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-Content -Exactly 0
        }

        It "should attempt to get the table row by partition and row key" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-AzTableRow -Exactly 1
        }

        It "should not add any new rows to the storage table" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Add-AzTableRow -Exactly 0
        }

        It "should update the entity in the storge table" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Update-AzTableRow -Exactly 1 -ParameterFilter {
                $entity.PartitionKey -eq "aPartitionKey" -and `
                    $entity.RowKey -eq "aRowKey" -and `
                    $entity.Data -eq "aJsonObject"
            }
        }
    }

    Context "When updating from a file and the entry does not exist" {
        BeforeAll {
            Mock Get-AzStorageAccount -MockWith { 
                # This returns a new PSCustom object that implements all the properties that IStorageContest does
                return [PSCustomObject]@{
                    BlobEndPoint         = ""
                    ConnectionString     = ""
                    Context              = $null
                    EmptyContextInstance = ""
                    ExtendedProperties   = ""
                    FileEndPoint         = ""
                    Name                 = ""
                    QueueEndPoint        = ""
                    StorageAccount       = ""
                    StorageAccountName   = ""
                    TableEndPoint        = ""
                }
            }
            Mock Get-AzStorageTable -MockWith { return @{ CloudTable = @{} } }
            Mock Get-AzTableRow
            Mock Add-AzTableRow
            Mock Update-AzTableRow
            Mock Get-Content
    
            $params = @{
                StorageAccountName = "aStorageAccount"
                ResourceGroupName  = "aResourceGroup"
                TableName          = "someTable"
                PartitionKey       = "aPartitionKey"
                RowKey             = "aRowKey"
                JsonFilePath       = "/Path/To/File.json"
            }
            Mock Get-Content -ParameterFilter { $Path -eq "/Path/To/File.json" } -MockWith { return "jsonObjectFromFile" }
        }



        It "should get the storage account" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-AzStorageAccount -Exactly 1 -ParameterFilter { $Name -eq "aStorageAccount" -and $ResourceGroupName -eq "aResourceGroup" }
        }

        It "should get the storage table" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-AzStorageTable -Exactly 1 -ParameterFilter { $Name -eq "someTable" }
        }

        It "should get the contents of the file" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-Content -Exactly 1 -ParameterFilter { $Path -eq "/Path/To/File.json" }
        }

        It "should attempt to get the table row by partition and row key" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-AzTableRow -Exactly 1 
        }

        It "should add a new row to the storage table" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Add-AzTableRow -Exactly 1  -ParameterFilter {
                $PartitionKey -eq "aPartitionKey" -and `
                    $RowKey -eq "aRowKey" -and `
                    $property.Data -eq "jsonObjectFromFile"
            }
        }

        It "should not update the entity in the storge table" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Update-AzTableRow -Exactly 0
        }
    }

    Context "When updating from a file and the entry exists" {
        BeforeAll {
            Mock Get-AzStorageAccount -MockWith { 
                # This returns a new PSCustom object that implements all the properties that IStorageContest does
                return [PSCustomObject]@{
                    BlobEndPoint         = ""
                    ConnectionString     = ""
                    Context              = $null
                    EmptyContextInstance = ""
                    ExtendedProperties   = ""
                    FileEndPoint         = ""
                    Name                 = ""
                    QueueEndPoint        = ""
                    StorageAccount       = ""
                    StorageAccountName   = ""
                    TableEndPoint        = ""
                }
            }
            Mock Get-AzStorageTable -MockWith { return @{ CloudTable = @{} } }
            Mock Get-AzTableRow
            Mock Add-AzTableRow
            Mock Update-AzTableRow
            Mock Get-Content

            $params = @{
                StorageAccountName = "aStorageAccount"
                ResourceGroupName  = "aResourceGroup"
                TableName          = "someTable"
                PartitionKey       = "aPartitionKey"
                RowKey             = "aRowKey"
                JsonFilePath       = "/Path/To/File.json"
            }
    
            Mock Get-AzTableRow -MockWith { return @{
                    Data         = "someData"
                    PartitionKey = "aPartitionKey"
                    RowKey       = "aRowKey"
                } }
    
            Mock Get-Content -ParameterFilter { $Path -eq "/Path/To/File.json" } -MockWith { return "jsonObjectFromFile" }
    
        }
    

        It "should get the storage account" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-AzStorageAccount -Exactly 1 -ParameterFilter { $Name -eq "aStorageAccount" -and $ResourceGroupName -eq "aResourceGroup" }
        }

        It "should get the storage table" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-AzStorageTable -Exactly 1 -ParameterFilter { $Name -eq "someTable" }
        }

        It "should get the contents of the file" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-Content -Exactly 1 -ParameterFilter { $Path -eq "/Path/To/File.json" }
        }

        It "should attempt to get the table row by partition and row key" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Get-AzTableRow -Exactly 1
        }

        It "should not add a new row to the storage table" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Add-AzTableRow -Exactly 0
        }

        It "should update the entity in the storge table" {
            ./Set-SharedConfigValue.ps1 @params
            Should -Invoke -CommandName Update-AzTableRow -Exactly 1 -ParameterFilter {
                $entity.PartitionKey -eq "aPartitionKey" -and `
                    $entity.RowKey -eq "aRowKey" -and `
                    $entity.Data -eq "jsonObjectFromFile"
            }
        }
    }
}