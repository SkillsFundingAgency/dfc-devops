Push-Location -Path $PSScriptRoot\..\..\PSScripts\



Describe "Set-CorsOnStorageAccount unit tests" -Tag "Unit" {

    It "Should call the Azure cmdlets" {

        $strname = "dfcfoobarstr"
        $strkey  = "foo="
        $origin  = "foo.example.org"
        
        Mock New-AzureStorageContext
        Mock Get-AzureStorageCORSRule
        Mock Set-AzureStorageCORSRule

        .\Set-CorsOnStorageAccount -StorageAccountName $strname -StorageAccountKey $strkey -AllowedOrigins $origin

        Should -Invoke -CommandName New-AzureStorageContext -Exactly 1 -ParameterFilter { $StorageAccountName -eq $strname -and $StorageAccountKey -eq $strkey } -Scope It
        Should -Invoke -CommandName Get-AzureStorageCORSRule -Exactly 1
        Should -Invoke -CommandName Set-AzureStorageCORSRule -Exactly 1
    }

}

Push-Location -Path $PSScriptRoot