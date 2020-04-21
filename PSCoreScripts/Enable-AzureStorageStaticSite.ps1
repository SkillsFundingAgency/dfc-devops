<#
.SYNOPSIS
Enables the static website on an Azure Storage Account and tests that the DNS name can be resolved.

.DESCRIPTION
Enables the static website on an Azure Storage Account and tests that the DNS name can be resolved.

.PARAMETER StorageAccountName
Name of the storage account that the static site will be enabled on

.PARAMETER IndexDocument
[Optional] Name of the index file, defaults to index.html

.PARAMETER ErrorDocument404Path
[Optional] Name of the error page, defaults to error404.html

.EXAMPLE
Enable-AzureStorageStaticSite.ps1 -StorageAccountName dfcfoosharedstr
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName,
    [Parameter(Mandatory=$false)]
    [string]$IndexDocument = "index.html",
    [Parameter(Mandatory=$false)]
    [string]$ErrorDocument404Path = "error404.html"
)

$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount
Write-Verbose "Enabling static website on: $StorageAccountName"
Enable-AzStorageStaticWebsite -Context $Context -IndexDocument $IndexDocument -ErrorDocument404Path $ErrorDocument404Path
$SiteAddress = "$StorageAccountName.z6.web.core.windows.net"
$SiteAddressResolved = $false
While (!$SiteAddressResolved) {

    Write-Verbose "Resolving $SiteAddress with PSVerion: $($PSVersionTable.PSVersion.Major)"
    $SiteAddressResolved = Test-Connection -TargetName $SiteAddress -ResolveDestination -TCPPort 80 -Quiet

    if ($SiteAddressResolved) {
        Write-Verbose "Resovled address: $SiteAddress"
    }
    else {

        Write-Verbose "Address not resovled: $SiteAddress, waiting 30 seconds."
        Start-Sleep -Seconds 30
    }
}