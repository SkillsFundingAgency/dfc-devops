Push-Location -Path $PSScriptRoot\..\..\PSScripts\



Describe "Set-CorsOnStorageAccount unit tests" -Tag "Unit" {

    It "Should call the Azure cmdlets" {

        $strname = "dfcfoobarstr"
        $strkey  = "foo="
        $origin  = "foo.example.org"

        Mock New-AzStorageContext
        Mock Get-AzStorageCORSRule
        Mock Set-AzStorageCORSRule

        .\Set-CorsOnStorageAccount -StorageAccountName $strname -StorageAccountKey $strkey -AllowedOrigins $origin

        Should -Invoke -CommandName New-AzStorageContext -Exactly 1 -ParameterFilter { $StorageAccountName -eq $strname -and $StorageAccountKey -eq $strkey } -Scope It
        Should -Invoke -CommandName Get-AzStorageCORSRule -Exactly 1
        Should -Invoke -CommandName Set-AzStorageCORSRule -Exactly 1
    }

}

Push-Location -Path $PSScriptRoot