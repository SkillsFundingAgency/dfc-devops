<#
.SYNOPSIS
Exports a KeyVault certificate as pem files and saves them to an Azure Storage FileShare.  Linux based containers often require certificates in this format.  FileShares can be mounted to AKS hosted containers.  The pem files are not password protected so it is important that the FileShare they are stored in is adequately secured.

.DESCRIPTION
Exports a KeyVault certificate as pem files and saves them to an Azure Storage FileShare.  The script converts the secret that KeyVault stores the certificate into a pfx file and saves it temporarily to the local filesystem.  The pfx file is protected with a password that is stored in memory and the file is deleted once it has been converted.  The pem files are also saved locally and deleted

.PARAMETER CertificateSecretName
The name of the secret that the certificate has been stored in.  This will be same as the name of the certificate in KeyVault.

.PARAMETER FileShare
The name of the FileShare that the pem files will be saved to.  The directory that the files will be saved into must be specified in the OutputDirectory parameter, the directory must be created seperately.

.PARAMETER FullChainOutputDirectories
An array of directories in the FileShare that the fullchain.pem file will be saved to.  This must be created separately.

.PARAMETER KeyVaultName
The name of the KeyVault that holds the certificate and associated secret.

.PARAMETER PrivKeyOutputDirectories
An array of directories in the FileShare that the privkey.pem file will be saved to.  This must be created separately.

.PARAMETER StorageAccountName
The name of the Storage Account that contains the FileShare.

.PARAMETER StorageResourceGroupName
The name of the Resource Group that contains the Storage Account.

.EXAMPLE
./Export-KeyVaultCertToPemFiles.ps1 -CertificateSecretName aSecret -FileShare SomeFileShare -FullChainOutputDirectories @( "dir1", "dir2") -PrivKeyOutputDirectories @( "dir3", "dir4") -StorageAccountName aStorageAccount -StorageResourceGroupName AResourceGroup
.NOTES
This script has been tested with certificates ordered from a KeyVault integrated CA.  Certificates ordered using other processes may not be exported as expected using this script.
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [String]$CertificateSecretName,
    [Parameter(Mandatory=$true)]
    [String]$FileShare,
    [Parameter(Mandatory=$true)]
    [String[]]$FullChainOutputDirectories,
    [Parameter(Mandatory=$true)]
    [String]$KeyVaultName,
    [Parameter(Mandatory=$true)]
    [String[]]$PrivKeyOutputDirectories,
    [Parameter(Mandatory=$true)]
    [String]$StorageAccountName,
    [Parameter(Mandatory=$true)]
    [String]$StorageResourceGroupName
)

function Invoke-OpenSSLCommand {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingInvokeExpression", "", Justification="This function needs to execute openssl")]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [String]$OpenSslArguments
    )

    $Cmd = "openssl $OpenSslArguments"
    try {

        Write-Verbose "Invoking command: $($Cmd -replace "(pass:)(\w*)", '$1***')"
        $Result = Invoke-Expression -Command $Cmd

    }
    catch {

        throw "OpenSSL command failed:`n$_"

    }
    Write-Verbose "OpenSSL output: $Result"

}

function New-Password {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="This function doesn't change system state it merely returns a random string for use as a password.")]
    [CmdletBinding()]
    param(
		[Parameter(Mandatory=$true)]
		[int]$Length
	)
	$PasswordString = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count $Length | ForEach-Object {[char]$_})
    # Check that PasswordString container lowercase, uppercase and numeric characters
    if ($PasswordString -match "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)") {

        return $PasswordString

	}
	else {

        New-Password -length $Length

	}
}

function New-PfxFileFromKeyVaultSecret {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="This function creates a cert, which requires system state changes")]
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [Object]$KeyVaultSecret,
        [Parameter(Mandatory=$true)]
        [String]$Password,
        [Parameter(Mandatory=$true)]
        [String]$PfxFilePath
    )

    Write-Verbose "Converting certificate secret to pfx file"
    $CertBytes = [System.Convert]::FromBase64String($KeyVaultSecret.SecretValueText)
    $CertCollection = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2Collection
    $CertCollection.Import($CertBytes,$null,[System.Security.Cryptography.X509Certificates.X509KeyStorageFlags]::Exportable)

    $ProtectedCertificateBytes = $CertCollection.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Pkcs12, $Password)
    Write-Verbose "Writing certificate to pfx file $PfxFilePath"
    [System.IO.File]::WriteAllBytes($PfxFilePath, $ProtectedCertificateBytes)
}

# Check that OpenSSL is installed
Invoke-OpenSSLCommand -OpenSslArguments "version"

# Fetch storage account key via Az module, this is needed later in the script to copy the pem files to the FileShare
Write-Verbose "Fetching storage account keys"
$StorageAccountKeys = Get-AzStorageAccountKey -ResourceGroupName $StorageResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue

if(!$StorageAccountKeys) {

    throw "Unable to fetch account keys from storage account '$($StorageAccountName)'"

}
$AccountKey = ($StorageAccountKeys | Where-Object { $_.keyName -eq "key1" }).Value
Write-Verbose "Creating storage context"
$StorageContext = New-AzStorageContext -StorageAccountName $StorageAccountName -StorageAccountKey $AccountKey

Write-Verbose "Getting $CertificateSecretName from $KeyVaultName"
$Cert = Get-AzKeyVaultSecret -VaultName $KeyVaultName -Name $CertificateSecretName

$Password = New-Password -Length 20
$PfxFilePath = "$PSScriptRoot\PsExportedPfx.pfx"
New-PfxFileFromKeyVaultSecret -KeyVaultSecret $Cert -Password $Password -PfxFilePath $PfxFilePath

Write-Warning "This script will export certificate $CertificateSecretName in an insecure format.  Ensure that the $FileShare is adequately secured."
$CertTempFile = "$PSScriptRoot\cert.pem"
Invoke-OpenSSLCommand -OpenSslArguments "pkcs12 -in $PfxFilePath -out $CertTempFile -nokeys -clcerts -password pass:$Password"
$FullChainTempFile = "$PSScriptRoot\fullchain.pem"
Invoke-OpenSSLCommand -OpenSslArguments "pkcs12 -in $PfxFilePath -out $FullChainTempFile --chain -nokeys -password pass:$Password"
$PrivKeyTempFile = "$PSScriptRoot\privkey.pem"
Invoke-OpenSSLCommand -OpenSslArguments "pkcs12 -in $PfxFilePath -out $PrivKeyTempFile -nocerts -nodes -password pass:$Password"

Write-Verbose "Saving pem files to FileShare $FileShare"
try {

    foreach ($OutputDirectory in $FullChainOutputDirectories) {

        Set-AzStorageFileContent -ShareName $FileShare -Path $OutputDirectory -Source $CertTempFile -Context $StorageContext -Force
        Set-AzStorageFileContent -ShareName $FileShare -Path $OutputDirectory -Source $FullChainTempFile -Context $StorageContext -Force

    }
    foreach ($OutputDirectory in $PrivKeyOutputDirectories) {

        Set-AzStorageFileContent -ShareName $FileShare -Path $OutputDirectory -Source $PrivKeyTempFile -Context $StorageContext -Force

    }

}
catch {

    Write-Error "Error saving pem files to FileShare $FileShare in directory $OutputDirectory `n$_"

}
finally {

    Write-Verbose "Deleting pem file $CertTempFile"
    Remove-Item -Path $CertTempFile -Force
    Write-Verbose "Deleting pem file $FullChainTempFile"
    Remove-Item -Path $FullChainTempFile -Force
    Write-Verbose "Deleting pem file $PrivKeyTempFile"
    Remove-Item -Path $PrivKeyTempFile -Force

}

Write-Verbose "Deleting local copy of pfx file"
Remove-Item -Path $PfxFilePath -Force