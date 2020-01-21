Push-Location -Path $PSScriptRoot\..\..\PSScripts\

# solves CommandNotFoundException
function Get-AzureRmStorageAccountKey {}
function New-AzureStorageContext {}
function Get-AzureStorageContainer {}
function New-AzureStorageContainer {}

Describe "Set-StorageContainer unit tests" -Tag "Unit" {

    Mock Get-AzureRmStorageAccountKey { return ConvertFrom-Json '[ { "KeyName": "key", "Value": "not4RealKey==" } ]' }
    Mock New-AzureStorageContext
    Mock New-AzureStorageContainer

    It "Ensure New-AzureStorageContainer is called to create a container if it doesnt already exist" {

        Mock Get-AzureStorageContainer { return $null }

        .\Set-StorageContainer -ResourceGroupName dfc-foo-bar-rg -StorageAccountName dfcfoobarstr -ContainerName mockcontainer

        Assert-MockCalled Get-AzureStorageContainer -Exactly 1 -Scope It
        Assert-MockCalled New-AzureStorageContainer -Exactly 1 -Scope It

    }

    It "Ensure New-AzureStorageContainer is not called if container exists" {

        Mock Get-AzureStorageContainer { return ConvertFrom-Json '{ "name": "mockcontainer" }' }

        .\Set-StorageContainer -ResourceGroupName dfc-foo-bar-rg -StorageAccountName dfcfoobarstr -ContainerName mockcontainer

        Assert-MockCalled Get-AzureStorageContainer -Exactly 1 -Scope It
        Assert-MockCalled New-AzureStorageContainer -Exactly 0 -Scope It

    }

}

Push-Location -Path $PSScriptRoot