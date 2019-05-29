[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$StorageAccountName
)

$Context = New-AzStorageContext -StorageAccountName $StorageAccountName -UseConnectedAccount
Enable-AzStorageStaticWebsite -Context $Context -IndexDocument index.html -ErrorDocument404Path error404.html
$SiteAddress = "$StorageAccountName.z6.web.core.windows.net"
$SiteAddressResolved = $false
While (!$SiteAddressResolved) { 

    if (Test-Connection -TargetName $SiteAddress -ResolveDestination -TCPPort 80) { 
        
        Write-Verbose "Resovled address: $SiteAddress"
        SiteAddressResolved = $true 

    }
    else {

        Write-Verbose "Address not resovled: $SiteAddress, waiting 30 seconds."
        Start-Sleep -Seconds 30

    }

}
