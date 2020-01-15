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

Write-Verbose -Message "Synchronising $SourceKeyVaultName certificates to $DestinationKeyVaultName"
 
Get-AzKeyVaultCertificate -VaultName $SourceKeyVaultName | ForEach-Object { 
    $CertName = $_.Name 
    $SourceCert = Get-AzKeyVaultCertificate -VaultName $SourceKeyVaultName -Name $CertName 
    $DestinationCert = Get-AzKeyVaultCertificate -VaultName $DestinationKeyVaultName -Name $CertName 
    if (!($DestinationCert) -or ($DestinationCert.Updated -lt $SourceCert.Updated)) 
    {
        Write-Verbose -Message "Updating $CertName"
        $certFile = Join-Path($PSScriptRoot,"$CertName.blob") 
        Write-Verbose -Message "Temporary backup file $certFile"
        $SourceCert | Backup-AzKeyVaultCertificate -OutputFile $certFile -Force 
        Restore-AzKeyVaultCertificate -VaultName $SecondaryKVName -Inputfile $certFile
        Remove-Item -Path $certFile 
    } 
    else 
    { 
        Write-Verbose -Message "Cert $CertName already up to date"
    } 
} 
