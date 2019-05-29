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
Enable-AzStorageStaticWebsite -Context $Context -IndexDocument index.html -ErrorDocument404Path error404.html
$SiteAddress = "$StorageAccountName.z6.web.core.windows.net"
$SiteAddressResolved = $false
While (!$SiteAddressResolved) { 

    # PowerShell 5.1 syntax as Azure PowerShell task currently doesn't support PowerShell Core
    if (Test-Connection -ComputerName $SiteAddress -ResolveDestination -TCPPort 80) { 
        
        Write-Verbose "Resovled address: $SiteAddress"
        $SiteAddressResolved = $true 

    }
    else {

        Write-Verbose "Address not resovled: $SiteAddress, waiting 30 seconds."
        Start-Sleep -Seconds 30

    }

}
