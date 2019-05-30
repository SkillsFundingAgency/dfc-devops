# Current testing approach doesn't support PowerShell 5.1 and PowerShell Core side-by-side

<#Push-Location -Path $PSScriptRoot\..\PSScripts\

$strname = "dfcfoobarstr"

Describe "Enable-AzureStorageStaticSite unit tests" -Tag "Unit" {

    It "Should call the Azure cmdlets" {
        Mock New-AzStorageContext
        Mock Enable-AzStorageStaticWebsite
        Mock Resolve-DnsName{ [PsCustomObject]
            @{
                Name = "$strname.z6.web.core.windows.net"
            }
        }
        Mock Start-Sleep

        .\Enable-AzureStorageStaticSite -StorageAccountName $strname

        Assert-MockCalled New-AzStorageContext -Exactly 1
        Assert-MockCalled Enable-AzStorageStaticWebsite -Exactly 1
        Assert-MockCalled Resolve-DnsName -Exactly 1
        Assert-MockCalled Start-Sleep -Exactly 0
    }

}

Push-Location -Path $PSScriptRoot
#>