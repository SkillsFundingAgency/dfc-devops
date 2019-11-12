<#
.SYNOPSIS
Registers and application with Azure Active Directory and optionally creates a secret from an Azure DevOps pipeline

.DESCRIPTION
Creates an AAD App Registration and associated Serivce Principal.  Optionally creates a secret for the App Registration and stores that in a KeyVault

.PARAMETER AppRegistrationName
The name of the App Registration and Service Principal that will be created

.PARAMETER IdentifierUris
Defaults to https://localhost

.PARAMETER AddSecret
Creates the Service Principal with a secret that is stored in a KeyVault

.PARAMETER KeyVaultName
Required if AddSecret is set

.EXAMPLE
 .\New-ApplicationRegistration.ps1 -AppRegistrationName BarApplication -AddSecret -KeyVaultName dfc-foo-shared-kv -Verbose

.NOTES
This cmdlet is designed to run from an Azure DevOps pipeline using a Service Connection.  
The Service Principal that the connection authenticates with will need the following permissions to create the application registration:
- Windows Azure Active Directory Directory.ReadWrite.All
- Windows Azure Active Directory Application.ReadWrite.OwnedBy

#>
[CmdletBinding(DefaultParametersetName='None')]
param(
    [Parameter(Mandatory=$true)]
    [string]$AppRegistrationName,
    [Parameter(Mandatory=$false)]
    [string]$IdentifierUris = "https://localhost",
    [Parameter(ParameterSetName="AddSecret", Mandatory=$false)]
    [switch]$AddSecret,
    [Parameter(ParameterSetName="AddSecret", Mandatory=$true)]
    [string]$KeyVaultName
)

function New-Password{
	param(
		[Parameter(Mandatory=$true)]
		[int]$Length
	)
	$passwordString = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count $Length | ForEach {[char]$_})
	if ($passwordString -match "^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)") {
		return $passwordString
	}
	else {
		New-Password -length $Length
	}
}

$Context = Get-AzureRmContext
$AzureDevOpsServicePrincipal = Get-AzureRmADServicePrincipal -ApplicationId $Context.Account.Id

$AdServicePrincipal = Get-AzureRmADServicePrincipal -SearchString $AppRegistrationName
if(!$AdServicePrincipal) {

    Write-Verbose -Message "Registering service principal"
    if ($AddSecret) {

        $Password = New-Password -Length 24
        $SecurePassword = $Password | ConvertTo-SecureString -AsPlainText -Force
        $KeyVault = Get-AzureRmKeyVault -VaultName $KeyVaultName
        if (!$KeyVault) {

            throw "KeyVault $KeyVaultName doesn't exist, nowhere to store secret"

        }
        else {

            Write-Verbose "Checking user access policy for user $($AzureDevOpsServicePrincipal.Id) ..."
            $UserAccessPolicy = $KeyVault.AccessPolicies | Where-Object { $_.ObjectId -eq $AzureDevOpsServicePrincipal.Id }
            if (!$UserAccessPolicy -or !$UserAccessPolicy.PermissionsToSecrets.Contains("Set")) {

                throw "Service Principal $($AzureDevOpsServicePrincipal.Id) doesn't have Set permission on KeyVault $($KeyVault.VaultName)"

            }


        }

        try {

            $AdServicePrincipal = New-AzureRmADServicePrincipal -DisplayName $AppRegistrationName -Password $SecurePassword -EndDate $([DateTime]::new(2299, 12, 31)) -ErrorAction Stop

        }
        catch {

            throw "Error creating Service Principal `n$_"

        }

        Write-Verbose "Adding ServicePrincipal secret to KeyVault $($KeyVault.VaultName)"
        $Secret = Set-AzureKeyVaultSecret -Name $AppRegistrationName -SecretValue $SecurePassword -VaultName $KeyVault.VaultName
        $Secret.Id

    }
    else {

        $AdServicePrincipal = New-AzureRmADServicePrincipal -DisplayName $AppRegistrationName

    }
    
}	
else {

    Write-Verbose -Message "$($AdServicePrincipal.ServicePrincipalNames -join ",") already registered as AD Service Principal, no action"

}