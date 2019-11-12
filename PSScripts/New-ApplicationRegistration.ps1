<#
.SYNOPSIS
Registers and application with Azure Active Directory and optionally creates a secret

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
$Context
$Context.Account
#force context to grab a token for graph
$AADServicePrincipal = Get-AzureRmADServicePrincipal -ApplicationId $Context.Account.Id
$AADServicePrincipal
Write-Verbose "Connected to AzureRm Context Tenant $($Context.Tenant.Id) with Account $($AADServicePrincipal.DisplayName) & Account.Type $($Context.Account.Type), connecting to AzureAD ..."

$Cache = $Context.TokenCache
$CacheItems = $Cache.ReadItems()

$Token = ($CacheItems | Where-Object { $_.Resource -eq "https://graph.windows.net/" })
if ($Token.ExpiresOn -le [System.DateTime]::UtcNow) {
    $AuthContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]::new("$($Context.Environment.ActiveDirectoryAuthority)$($Context.Tenant.Id)",$Token)
    $Token = $AuthContext.AcquireTokenByRefreshToken($Token.RefreshToken, "1950a258-227b-4e31-a9cf-717495945fc2", "https://graph.windows.net")
}
$AADConn = Connect-AzureAD -AadAccessToken $Token.AccessToken -AccountId $Context.Account.Id -TenantId $Context.Tenant.Id
Write-Verbose "Connected to AzureAD tenant domain $($AADConn.TenantDomain)"

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

            Write-Verbose "Checking user access policy for user $($AADServicePrincipal.Id) ..."
            $UserAccessPolicy = $KeyVault.AccessPolicies | Where-Object { $_.ObjectId -eq $AADServicePrincipal.Id }
            if (!$UserAccessPolicy -or !$UserAccessPolicy.PermissionsToSecrets.Contains("Set")) {

                throw "Service Principal $($AADServicePrincipal.Id) doesn't have Set permission on KeyVault $($KeyVault.VaultName)"

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