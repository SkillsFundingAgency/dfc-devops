<#
.SYNOPSIS
Adds API permissions to an App Registration via the Azure PowerShell Azure DevOps task.

.DESCRIPTION
Adds API permissions to an existing App Registration.  Approval will need to be granted manually via the Azure Portal once the permissions have been added

.PARAMETER AppRegistrationDisplayName
The name of the App Registration

.PARAMETER ApiName
The name of the API, currently limited to Microsoft Graph and any correctly formated dfc API (must start "dfc-<env>-", where <env> is the name of the environment, eg "dev")

.PARAMETER ApplicationPermissions
An array of permissions, eg "Directory.Read.All", "User.Read".  The available permissions can be obtained from the Azure Portal in the Azure Active Directory blade

.PARAMETER DelegatedPermissions
An array of permissions, eg "Directory.Read.All", "User.Read".  The available permissions can be obtained from the Azure Portal in the Azure Active Directory blade

.EXAMPLE
 .\PSScripts\Add-AzureAdApiPermissionsToApp.ps1 -AppRegistrationDisplayName FooBarAppRegistration -ApiName "Microsoft Graph" -DelegatedPermissions "Directory.Read.All",
"User.Read" -Verbose

.NOTES
This cmdlet is designed to run from an Azure DevOps pipeline using a Service Connection.
The Service Principal that the connection authenticates with will need the following permissions to create the application registration:
- Azure Active Directory Graph Application Directory.ReadWrite.All
- Azure Active Directory Graph Application Application.ReadWrite.OwnedBy (this assumes that the same Service Connection was used to create the Service Principal, eg using the New-ApplicationRegistration script)
#>
[CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Low')]
param(
    [Parameter(Mandatory=$true)]
    [String]$AppRegistrationDisplayName,
    [ValidatePattern("^(Microsoft Graph|dfc-\w+-.+)$")]
    [Parameter(Mandatory=$true)]
    [String]$ApiName,
    [Parameter(Mandatory=$true, ParameterSetName="Both")]
    [Parameter(Mandatory=$true, ParameterSetName="Application")]
    [String[]]$ApplicationPermissions,
    [Parameter(Mandatory=$true, ParameterSetName="Both")]
    [Parameter(Mandatory=$true, ParameterSetName="Delegated")]
    [String[]]$DelegatedPermissions
)

function Add-ResourceAccess {
    param(
        #Permissions exposed by the API that can be granted to the AD Application registration
        [Parameter(Mandatory=$true)]
        $ExposedPermissions,
        #The permissions that will be added, these should be passed as a list seperated by spaces
        [Parameter(Mandatory=$true)]
        [String[]]$RequiredPermissions,
        #The Microsoft.Open.AzureAD.Model.RequiredResourceAccess object that the ResourceAccess will be added to
        [Parameter(Mandatory=$true)]
        $RequiredResourceAccessObject,
        #The permission type
        [ValidateSet("Role", "Scope")]
        [Parameter(Mandatory=$true)]
        [String]$PermissionType
    )

    foreach ($Permission in $RequiredPermissions) {

        $RequestedPermissionObject = $ExposedPermissions | Where-Object {$_.Value -contains $Permission}
        Write-Verbose "Collected information for $($RequestedPermissionObject.Value) of type $PermissionType"
        $ResourceAccess = New-Object -TypeName Microsoft.Open.AzureAD.Model.ResourceAccess
        $ResourceAccess.Type = $PermissionType
        $ResourceAccess.Id = $RequestedPermissionObject.Id
        $RequiredResourceAccessObject.ResourceAccess.Add($ResourceAccess)

    }
}

function New-RequireResourceAccessObject {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "", Justification="This function doesn't change system state.  The parent script is decorated with SupportsShouldProcess.")]
    param(
        [Parameter(Mandatory=$true)]
        [Microsoft.Open.AzureAD.Model.ServicePrincipal]$TargetServicePrincipal,
        [Parameter(Mandatory=$false)]
        [String[]]$RequiredApplicationPermissions,
        [Parameter(Mandatory=$false)]
        [String[]]$RequiredDelegatedPermissions
    )

    $RequiredResourceAccess = New-Object Microsoft.Open.AzureAD.Model.RequiredResourceAccess
    $RequiredResourceAccess.ResourceAppId = $TargetServicePrincipal.AppId
    $RequiredResourceAccess.ResourceAccess = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.ResourceAccess]
    if ($RequiredDelegatedPermissions) {

        Add-ResourceAccess -ExposedPermissions $TargetServicePrincipal.Oauth2Permissions -RequiredPermissions $RequiredDelegatedPermissions -RequiredResourceAccessObject $RequiredResourceAccess -PermissionType "Scope"

    }
    if ($RequiredApplicationPermissions) {

        Add-ResourceAccess -ExposedPermissions $TargetServicePrincipal.AppRoles -RequiredPermissions $RequiredApplicationPermissions -RequiredResourceAccessObject $RequiredResourceAccess -PermissionType "Role"

    }
    return $RequiredResourceAccess
}

$Context = Get-AzureRmContext
#force context to grab a token for graph
$AzureDevOpsServicePrincipal = Get-AzureRmADServicePrincipal -ApplicationId $Context.Account.Id
Write-Verbose "Connected to AzureRm Context Tenant $($Context.Tenant.Id) with Account $($AzureDevOpsServicePrincipal.DisplayName) & Account.Type $($Context.Account.Type), connecting to AzureAD ..."

$Cache = $Context.TokenCache
$CacheItems = $Cache.ReadItems()

$Token = ($CacheItems | Where-Object { $_.Resource -eq "https://graph.windows.net/" })
if ($Token.ExpiresOn -le [System.DateTime]::UtcNow) {

    $AuthContext = [Microsoft.IdentityModel.Clients.ActiveDirectory.AuthenticationContext]::new("$($Context.Environment.ActiveDirectoryAuthority)$($Context.Tenant.Id)",$Token)
    $Token = $AuthContext.AcquireTokenByRefreshToken($Token.RefreshToken, "1950a258-227b-4e31-a9cf-717495945fc2", "https://graph.windows.net")

}
$AADConn = Connect-AzureAD -AadAccessToken $Token.AccessToken -AccountId $Context.Account.Id -TenantId $Context.Tenant.Id
Write-Verbose "Connected to AzureAD tenant domain $($AADConn.TenantDomain)"

Write-Verbose "Getting API Service Principal ..."
$ApiServicePrincipal = Get-AzureADServicePrincipal -Filter "DisplayName eq '$ApiName'"
if (!$ApiServicePrincipal) {

    throw "$ApiName Service Principal is not registered"

}

# Add Required API Access
Write-Verbose "Creating Microsoft.Open.AzureAD.Model.RequiredResourceAccess list"
$RequiredResourcesAccessList = New-Object System.Collections.Generic.List[Microsoft.Open.AzureAD.Model.RequiredResourceAccess]
$RequiredResourceAccessObject = New-RequireResourceAccessObject -TargetServicePrincipal $ApiServicePrincipal -RequiredApplicationPermissions $ApplicationPermissions -RequiredDelegatedPermissions $DelegatedPermissions
$RequiredResourcesAccessList.Add($RequiredResourceAccessObject)

Write-Verbose "Getting App Registration ..."
$AdApplication = Get-AzureRmADApplication -DisplayName $AppRegistrationDisplayName
Write-Verbose "Adding permissions to AD Application $($AdApplication.DisplayName)"
Set-AzureAdApplication -ObjectId $AdApplication.ObjectId -RequiredResourceAccess $RequiredResourcesAccessList
Write-Warning -Message "If not already approved, permission grants need to be approved in the Azure Portal via Azure Active Directory > App registrations > $($AdApplication.DisplayName) > API Permissions > Grant admin consent for Default Directory"