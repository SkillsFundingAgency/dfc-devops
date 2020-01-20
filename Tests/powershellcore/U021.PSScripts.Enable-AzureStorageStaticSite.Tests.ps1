Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

$strname = "dfcfoobarstr"

Describe "Enable-AzureStorageStaticSite unit tests" -Tag "Unit" {

    # Skipped due to https://github.com/pester/Pester/issues/1289
    # Test-Connection returns a "MethodInvocationException: Exception calling "GetParamBlock" with "1" argument(s)" exception
    It "Should call the Azure cmdlets" -Skip {
        Mock New-AzStorageContext
        Mock Test-Connection -MockWith { return $true }
        Mock Enable-AzStorageStaticWebsite
        Mock Start-Sleep

        .\Enable-AzureStorageStaticSite -StorageAccountName $strname

        Assert-MockCalled New-AzStorageContext -Exactly 1
        Assert-MockCalled Enable-AzStorageStaticWebsite -Exactly 1
        Assert-MockCalled Test-Connection -Exactly 1
        Assert-MockCalled Start-Sleep -Exactly 0
    }

}

Push-Location -Path $PSScriptRoot