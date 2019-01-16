<#
.SYNOPSIS
Imports pfx certificate to a keyvault for use in Azure

.DESCRIPTION
Imports pfx certificate to a keyvault for use in Azure

.PARAMETER keyVaultName
Keyvault to add the secret to

.PARAMETER secretName
Name of the 

.PARAMETER pfxFilePath
 Full path to the pfx file including file name

.PARAMETER pfxPassword
Password for the pfx file

.EXAMPLE
Add-KeyVaultCertificate -keyVaultName dfc-foo-kv -secretName mycert -pfxFilePath C:\path\to\cert.pfx -pfxPassword myPa$$w0rd

#>
param(
    [Parameter(Mandatory=$true)]
    [string] $keyVaultName,
    [Parameter(Mandatory=$true)]
    [string] $secretName,
    [Parameter(Mandatory=$true)]
    [string] $pfxFilePath,
    [Parameter(Mandatory=$true)]
    [string] $pfxPassword
)
  
$collection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
$collection.Import($pfxFilePath, $pfxPassword, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)
    
# create secret variables from cert
$expdate = $collection.NotAfter | Sort-Object | Select-Object -First 1 # earliest expiring cert in pfx
$clearBytes = $collection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12)
$fileContentEncoded = [System.Convert]::ToBase64String($clearBytes)
$secret = ConvertTo-SecureString -String $fileContentEncoded -AsPlainText -Force
$secretContentType = 'application/x-pkcs12'
$secretName = $secretName.Replace('.' , '-')
Set-AzureKeyVaultSecret -VaultName $keyVaultName -Name $secretName -SecretValue $Secret -ContentType $secretContentType -Expires $expdate
