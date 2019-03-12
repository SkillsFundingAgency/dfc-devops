<#
.SYNOPSIS
Imports pfx certificate to a keyvault for use in Azure

.DESCRIPTION
Imports pfx certificate to a keyvault for use in Azure

.PARAMETER KeyVaultName
Keyvault to add the secret to

.PARAMETER SecretName
Name of the secret to create

.PARAMETER PfxFilePath
 Full path to the pfx file including file name

.PARAMETER PfxPassword
Password for the pfx file

.EXAMPLE
Add-KeyVaultCertificate -KeyVaultName dfc-foo-kv -SecretName mycert -PfxFilePath C:\path\to\cert.pfx -PfxPassword myPa$$w0rd

#>
param(
    [Parameter(Mandatory=$true)]
    [string] $KeyVaultName,
    [Parameter(Mandatory=$true)]
    [string] $SecretName,
    [Parameter(Mandatory=$true)]
    [string] $PfxFilePath,
    [Parameter(Mandatory=$true)]
    [string] $PfxPassword
)

$Collection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
$Collection.Import($PfxFilePath, $PfxPassword, [System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

# create secret variables from cert
$ExpiryDate = $Collection.NotAfter | Sort-Object | Select-Object -First 1 # earliest expiring cert in pfx
$ClearBytes = $Collection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12)
$FileContentEncoded = [System.Convert]::ToBase64String($ClearBytes)
$SecretValue = ConvertTo-SecureString -String $FileContentEncoded -AsPlainText -Force
$SecretContentType = 'application/x-pkcs12'
$SecretName = $SecretName.Replace('.' , '-')
Set-AzureKeyVaultSecret -VaultName $KeyVaultName -Name $SecretName -SecretValue $SecretValue -ContentType $SecretContentType -Expires $ExpiryDate
