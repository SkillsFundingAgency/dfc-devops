Push-Location -Path $PSScriptRoot\..\..\PSScripts\

# solves CommandNotFoundException
function Get-AzStorageAccountKey {}
function New-AzStorageContext {}
function Get-AzStorgeContainer {}
function New-AzStorageContainer {}

Describe "Set-StorageContainer unit tests" -Tag "Unit" {

    BeforeEach {
        Mock Get-AzStorageAccountKey { return ConvertFrom-Json '[ { "KeyName": "key", "Value": "not4RealKey==" } ]' }
        Mock New-AzStorageContext
        Mock New-AzStorageContainer
    }

    It "Ensure New-AzureStorageContainer is called to create a container if it doesnt already exist" {

        Mock Get-AzStorageContainer { return $null }

        .\Set-StorageContainer -ResourceGroupName dfc-foobar-rg -StorageAccountName dfcfoobarstr -ContainerName mockcontainer

        Should -Invoke -CommandName Get-AzStorageContainer -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzStorageContainer -Exactly 1 -Scope It

    }

    It "Ensure New-AzureStorageContainer is not called if container exists" {

        Mock Get-AzStorageContainer { return ConvertFrom-Json '{ "name": "mockcontainer" }' }

        .\Set-StorageContainer -ResourceGroupName dfc-foobar-rg -StorageAccountName dfcfoobarstr -ContainerName mockcontainer

        Should -Invoke -CommandName Get-AzStorageContainer -Exactly 1 -Scope It
        Should -Invoke -CommandName New-AzStorageContainer -Exactly 0 -Scope It

    }

}

Push-Location -Path $PSScriptRoot