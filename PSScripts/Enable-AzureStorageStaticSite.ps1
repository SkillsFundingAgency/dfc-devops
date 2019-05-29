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
    if ($PSVersionTable.PSVersion.Major -ge 6) {

        $SiteAddressResolved = Test-Connection -TargetName $SiteAddress -ResolveDestination -TCPPort 80 -Quiet

    }
    else {

        $SiteAddressResolved = Resolve-DnsName -Name $SiteAddress -ErrorAction SilentlyContinue

    }

    if ($SiteAddressResolved) { 
        
        Write-Verbose "Resovled address: $SiteAddress"

    }
    else {

        Write-Verbose "Address not resovled: $SiteAddress, waiting 30 seconds."
        Start-Sleep -Seconds 30

    }

}
