<#
.SYNOPSIS
...

.DESCRIPTION
...

.PARAMETER SourceKeyVaultName
Source ey vault to get the certificates from

.PARAMETER DestinationKeyVaultName
Destinatio key vault to ensure all the certificates also exist in

.EXAMPLE
Copy-KeyVaultCertificates -SourceKeyVaultName dfc-from-foo-kv -DestinationKeyVaultName dfc-to-foo-kv

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string] $SourceKeyVaultName,
    [Parameter(Mandatory=$true)]
    [string] $DestinationKeyVaultName
)

$sourceKeyVault = Get-AzKeyVault -VaultName $SourceKeyVaultName
if (!$sourceKeyVault) {
    throw "Cannot find $SourceKeyVaultName"
}

$destinationKeyVault = Get-AzKeyVault -VaultName $destinationKeyVaultName
if (!$destinationKeyVault) {
    throw "Cannot find $destinationKeyVaultName"
}

function Import-Certificate {
    param (
        [Parameter(Mandatory=$true)]
        $Certificate,
        [Parameter(Mandatory=$true)]
        $DestinationKeyVaultName
    )
    
    $certName = $Certificate.Name
    $certFile = Join-Path $PSScriptRoot -ChildPath "$CertName.blob"
    Write-Verbose -Message "Temporary backup file $certFile"
    Backup-AzKeyVaultCertificate -InputObject $Certificate -OutputFile $certFile -Force 
    Restore-AzKeyVaultCertificate -VaultName $DestinationKeyVaultName -Inputfile $certFile
    Remove-Item -Path $certFile 
}

Write-Verbose -Message "Synchronising $SourceKeyVaultName certificates to $DestinationKeyVaultName"

Get-AzKeyVaultCertificate -VaultName $SourceKeyVaultName | ForEach-Object { 
    $CertName = $_.Name 
    $SourceCert = Get-AzKeyVaultCertificate -VaultName $SourceKeyVaultName -Name $CertName
    Write-Verbose -Message "Source cert $($SourceCert.name) updated on $($SourceCert.Updated)"
    $DestinationCert = Get-AzKeyVaultCertificate -VaultName $DestinationKeyVaultName -Name $CertName 
    Write-Verbose -Message "Destination cert $($DestinationCert.name) updated on $($DestinationCert.Updated)"
    if (!($DestinationCert)) {
        Write-Verbose -Message "Certificate $CertName does not exist in destination ... importing"
        Import-Certificate -Certificate $SourceCert -DestinationKeyVaultName $DestinationKeyVaultName
    }
    elseif ($DestinationCert.Updated -lt $SourceCert.Updated) {
        Write-Verbose -Message "Certificate $CertName has been updated ... importing"
        Import-Certificate -Certificate $SourceCert -DestinationKeyVaultName $DestinationKeyVaultName
    } 
    else { 
        Write-Verbose -Message "Cert $CertName already up to date"
    } 
} 
