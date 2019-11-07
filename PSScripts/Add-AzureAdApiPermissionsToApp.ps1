[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [String]$AppRegistrationDisplayName,
    [ValidateSet("Microsoft Graph")]
    [Parameter(Mandatory=$true)]
    [String]$ApiName,
    [Parameter(Mandatory=$true, ParameterSetName="Application")]
    $ApplicationPermissions,
    [Parameter(Mandatory=$true, ParameterSetName="Delegated")]
    $DelegatedPermissions
)

function Add-ResourceAccess {
    param(
        #Permissions exposed by the API that can be granted to the AD Application registration
        [Parameter(Mandatory=$true)]
        $ExposedPermissions,
        #The permissions that will be added, these should be passed as a list seperated by spaces
        [Parameter(Mandatory=$true)]
        [String]$RequiredPermissions, ##TO DO: change to String[]
        #The Microsoft.Open.AzureAD.Model.RequiredResourceAccess object that the ResourceAccess will be added to
        [Parameter(Mandatory=$true)]
        $RequiredResourceAccessObject, 
        #The permission type
        [ValidateSet("Role", "Scope")]
        [Parameter(Mandatory=$true)]
        [String]$PermissionType
    )

    foreach ($Permission in $RequiredPermissions.Trim().Split(" ")) {
        $RequestedPermissionObject = $ExposedPermissions | Where-Object {$_.Value -contains $Permission}
        Write-Verbose "Collected information for $($RequestedPermissionObject.Value) of type $PermissionType"
        $ResourceAccess = New-Object -TypeName Microsoft.Open.AzureAD.Model.ResourceAccess
        $ResourceAccess.Type = $PermissionType
        $ResourceAccess.Id = $RequestedPermissionObject.Id    
        $RequiredResourceAccessObject.ResourceAccess.Add($ResourceAccess)
    }
}
    
function New-RequireResourceAccessObject {
    param(
        [Parameter(Mandatory=$true)]
        [Microsoft.Open.AzureAD.Model.ServicePrincipal]$TargetServicePrincipal,
        [Parameter(Mandatory=$false)]
        [String]$RequiredApplicationPermissions,
        [Parameter(Mandatory=$false)]
        [String]$RequiredDelegatedPermissions 
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
Write-Verbose "Connected to AzureRm Context Tenant $($Context.Tenant.Id) with Account $($Context.Account.Id), connecting to AzureAd ..."
$Conn = Connect-AzureAD -TenantId $Context.Tenant.Id -AccountId $Context.Account.Id

Write-Verbose "Getting API Service Principal ..."
$ApiServicePrincipal = Get-AzureADServicePrincipal -SearchString $ApiName
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