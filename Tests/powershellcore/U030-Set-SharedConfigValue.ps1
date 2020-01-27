Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Set-SharedConfigValue unit tests" -Tag "Unit" {

    Mock Get-AzStorageAccount -MockWith { 
        # This returns a new PSCustom object that implements all the properties that IStorageContest does
        return [PSCustomObject]@{
            BlobEndPoint = ""
            ConnectionString = ""
            Context = $null
            EmptyContextInstance = ""
            ExtendedProperties = ""
            FileEndPoint = ""
            Name = ""
            QueueEndPoint = ""
            StorageAccount = ""
            StorageAccountName = ""
            TableEndPoint = ""
        }
    }
    Mock Get-AzStorageTable -MockWith { return @{ CloudTable = @{} } }
    Mock Get-AzTableRow
    Mock Add-AzTableRow
    Mock Update-AzTableRow
    Mock Get-Content

    Context "When updating from a string and the entry does not exist" {
        $params = @{
            StorageAccountName = "aStorageAccount"
            ResourceGroupName = "aResourceGroup"
            TableName = "someTable"
            PartitionKey = "aPartitionKey"
            RowKey = "aRowKey"
            JsonString = "aJsonObject"
        }

        ./Set-SharedConfigValue.ps1 @params

        It "should get the storage account" {
            Assert-MockCalled Get-AzStorageAccount -Exactly 1 -ParameterFilter { $Name -eq "aStorageAccount" -and $ResourceGroupName -eq "aResourceGroup" }
        }

        It "should get the storage table" {
            Assert-MockCalled Get-AzStorageTable -Exactly 1 -ParameterFilter { $Name -eq "someTable" }
        }

        It "should not get the contents of any files" {
            Assert-MockCalled Get-Content -Exactly 0
        }

        It "should attempt to get the table row by partition and row key" {
            Assert-MockCalled Get-AzTableRow -Exactly 1 -ParameterFilter {
                $TableName -eq "someTable" -and `
                $PartitionKey -eq "aPartitionKey" -and `
                $RowKey -eq "aRowKey"
            }
        }

        It "should add a new row to the storage table" {
            Assert-MockCalled Add-AzTableRow -Exactly 1 -ParameterFilter {
                $PartitionKey -eq "aPartitionKey" -and `
                $RowKey -eq "aRowKey" -and `
                $property.Data -eq "aJsonObject"
            }
        }

        It "should not update any rows in the storge table" {
            Assert-MockCalled Update-AzTableRow -Exactly 0
        }
    }

    Context "When updating from a string and the entry exists" {
        $params = @{
            StorageAccountName = "aStorageAccount"
            ResourceGroupName = "aResourceGroup"
            TableName = "someTable"
            PartitionKey = "aPartitionKey"
            RowKey = "aRowKey"
            JsonString = "aJsonObject"
        }

        Mock Get-AzTableRow -MockWith { return @{
            Data = "someData"
            PartitionKey = "aPartitionKey"
            RowKey = "aRowKey"
        }}

        ./Set-SharedConfigValue.ps1 @params

        It "should get the storage account" {
            Assert-MockCalled Get-AzStorageAccount -Exactly 1 -ParameterFilter { $Name -eq "aStorageAccount" -and $ResourceGroupName -eq "aResourceGroup" }
        }

        It "should get the storage table" {
            Assert-MockCalled Get-AzStorageTable -Exactly 1 -ParameterFilter { $Name -eq "someTable" }
        }

        It "should not get the contents of any files" {
            Assert-MockCalled Get-Content -Exactly 0
        }

        It "should attempt to get the table row by partition and row key" {
            Assert-MockCalled Get-AzTableRow -Exactly 1 -ParameterFilter {
                $TableName -eq "someTable" -and `
                $PartitionKey -eq "aPartitionKey" -and `
                $RowKey -eq "aRowKey"
            }
        }

        It "should not add any new rows to the storage table" {
            Assert-MockCalled Add-AzTableRow -Exactly 0
        }

        It "should update the entity in the storge table" {
            Assert-MockCalled Update-AzTableRow -Exactly 1 -ParameterFilter {
                $entity.PartitionKey -eq "aPartitionKey" -and `
                $entity.RowKey -eq "aRowKey" -and `
                $entity.Data -eq "aJsonObject"
            }
        }
    }

    Context "When updating from a file and the entry does not exist" {
        $params = @{
            StorageAccountName = "aStorageAccount"
            ResourceGroupName = "aResourceGroup"
            TableName = "someTable"
            PartitionKey = "aPartitionKey"
            RowKey = "aRowKey"
            JsonFilePath = "/Path/To/File.json"
        }

        Mock Get-Content -ParameterFilter { $Path -eq "/Path/To/File.json" } -MockWith { return "jsonObjectFromFile" }

        ./Set-SharedConfigValue.ps1 @params

        It "should get the storage account" {
            Assert-MockCalled Get-AzStorageAccount -Exactly 1 -ParameterFilter { $Name -eq "aStorageAccount" -and $ResourceGroupName -eq "aResourceGroup" }
        }

        It "should get the storage table" {
            Assert-MockCalled Get-AzStorageTable -Exactly 1 -ParameterFilter { $Name -eq "someTable" }
        }

        It "should get the contents of the file" {
            Assert-MockCalled Get-Content -Exactly 1 -ParameterFilter { $Path -eq "/Path/To/File.json" }
        }

        It "should attempt to get the table row by partition and row key" {
            Assert-MockCalled Get-AzTableRow -Exactly 1 -ParameterFilter {
                $TableName -eq "someTable" -and `
                $PartitionKey -eq "aPartitionKey" -and `
                $RowKey -eq "aRowKey"
            }
        }

        It "should add a new row to the storage table" {
            Assert-MockCalled Add-AzTableRow -Exactly 1  -ParameterFilter {
                $PartitionKey -eq "aPartitionKey" -and `
                $RowKey -eq "aRowKey" -and `
                $property.Data -eq "jsonObjectFromFile"
            }
        }

        It "should not update the entity in the storge table" {
            Assert-MockCalled Update-AzTableRow -Exactly 0
        }
    }

    Context "When updating from a file and the entry exists" {
        $params = @{
            StorageAccountName = "aStorageAccount"
            ResourceGroupName = "aResourceGroup"
            TableName = "someTable"
            PartitionKey = "aPartitionKey"
            RowKey = "aRowKey"
            JsonFilePath = "/Path/To/File.json"
        }

        Mock Get-AzTableRow -MockWith { return @{
            Data = "someData"
            PartitionKey = "aPartitionKey"
            RowKey = "aRowKey"
        }}

        Mock Get-Content -ParameterFilter { $Path -eq "/Path/To/File.json" } -MockWith { return "jsonObjectFromFile" }

        ./Set-SharedConfigValue.ps1 @params

        It "should get the storage account" {
            Assert-MockCalled Get-AzStorageAccount -Exactly 1 -ParameterFilter { $Name -eq "aStorageAccount" -and $ResourceGroupName -eq "aResourceGroup" }
        }

        It "should get the storage table" {
            Assert-MockCalled Get-AzStorageTable -Exactly 1 -ParameterFilter { $Name -eq "someTable" }
        }

        It "should get the contents of the file" {
            Assert-MockCalled Get-Content -Exactly 1 -ParameterFilter { $Path -eq "/Path/To/File.json" }
        }

        It "should attempt to get the table row by partition and row key" {
            Assert-MockCalled Get-AzTableRow -Exactly 1 -ParameterFilter {
                $TableName -eq "someTable" -and `
                $PartitionKey -eq "aPartitionKey" -and `
                $RowKey -eq "aRowKey"
            }
        }

        It "should not add a new row to the storage table" {
            Assert-MockCalled Add-AzTableRow -Exactly 0
        }

        It "should update the entity in the storge table" {
            Assert-MockCalled Update-AzTableRow -Exactly 1 -ParameterFilter {
                $entity.PartitionKey -eq "aPartitionKey" -and `
                $entity.RowKey -eq "aRowKey" -and `
                $entity.Data -eq "jsonObjectFromFile"
            }
        }
    }
}
