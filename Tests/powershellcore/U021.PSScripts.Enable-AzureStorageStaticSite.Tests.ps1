Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\



Describe "Enable-AzureStorageStaticSite unit tests" -Tag "Unit" {

    # Skipped due to https://github.com/pester/Pester/issues/1289
    # Test-Connection returns a "MethodInvocationException: Exception calling "GetParamBlock" with "1" argument(s)" exception
    It "Should call the Azure cmdlets" -Tag "DontRun" {

        $strname = "dfcfoobarstr"
        Mock New-AzStorageContext
        Mock Test-Connection -MockWith { return $true }
        Mock Enable-AzStorageStaticWebsite
        Mock Start-Sleep

        .\Enable-AzureStorageStaticSite -StorageAccountName $strname

        Should -Invoke -CommandName New-AzStorageContext -Exactly 1
        Should -Invoke -CommandName Enable-AzStorageStaticWebsite -Exactly 1
        Should -Invoke -CommandName Test-Connection -Exactly 1
        Should -Invoke -CommandName Start-Sleep -Exactly 0
    }

}

Push-Location -Path $PSScriptRoot