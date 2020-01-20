Push-Location -Path $PSScriptRoot\..\..\PSScripts\

$strname = "dfcfoobarstr"
$strkey  = "foo="
$origin  = "foo.example.org"

Describe "Set-CorsOnStorageAccount unit tests" -Tag "Unit" {

    It "Should call the Azure cmdlets" {
        Mock New-AzureStorageContext
        Mock Get-AzureStorageCORSRule
        Mock Set-AzureStorageCORSRule

        .\Set-CorsOnStorageAccount -StorageAccountName $strname -StorageAccountKey $strkey -AllowedOrigins $origin

        Assert-MockCalled New-AzureStorageContext -Exactly 1 -ParameterFilter { $StorageAccountName -eq $strname -and $StorageAccountKey -eq $strkey } -Scope It
        Assert-MockCalled Get-AzureStorageCORSRule -Exactly 1
        Assert-MockCalled Set-AzureStorageCORSRule -Exactly 1
    }

}

Push-Location -Path $PSScriptRoot