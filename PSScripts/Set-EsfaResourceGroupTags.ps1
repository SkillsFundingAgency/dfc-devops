[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string]$ResourceGroupName,
    [Parameter(Mandatory=$false)]
    [string]$Location = "West Europe",
    [Parameter(Mandatory=$true)]
    [ValidateSet("Production", "PreProduction", "Dev/Test")]
    [string]$Environment,
    [Parameter(Mandatory=$true)]
    [ValidateSet("National Careers Service", "National Careers Service (PP)")]
    [string]$ParentBusiness,
    [Parameter(Mandatory=$true)]
    [ValidateSet("Course Directory", "Course Directory (PP)", "Data Sharing Service", "Data Sharing Service (PP)", "Digital First Career Service (DFCS) Website", "Digital First Career Service (DFCS) Website (PP)", "NCS Website", "NCS Website (PP)")]
    [string]$ServiceOffering
)

$Tags = @{
    Environment = $Environment
    'Parent Business' = $ParentBusiness
    'Service Offering' = $ServiceOffering
}

Write-Verbose -Message "Attempting to retrieve existing resource group $ResourceGroupName"
$ResourceGroup = Get-AzureRmResourceGroup -Name $ResourceGroupName

if(!$ResourceGroup) {

    Write-Verbose -Message "Resource group $ResourceGroupName doesn't exist, creating resource group"
    New-AzureRmResourceGroup -Name $ResourceGroupName -Location $Location -Tag $Tags

}
else {

    Write-Verbose -Message "Resource group $ResourceGroupName exists, validating tags"
    $UpdatedTags = $ResourceGroup.Tags
    $UpdateTags = $false

    foreach ($Key in ($Tags.GetEnumerator() | Select-Object -Property Key)) {

        Write-Verbose "Current value of Resource Group Tag $($Key.Key) is $($ResourceGroup.Tags["$($Key.Key)"])"
        if ($($ResourceGroup.Tags["$($Key.Key)"]) -eq $($Tags["$($Key.Key)"])) {

            Write-Verbose -Message "Current value of tag ($($ResourceGroup.Tags["$($Key.Key)"])) matches parameter ($($Tags["$($Key.Key)"]))"

        }
        elseif ($null -eq $($ResourceGroup.Tags["$($Key.Key)"])){

            Write-Verbose -Message ("Tag value is not set, adding tag {0} with value {1}" -f $($Key.Key), $($Tags["$($Key.Key)"]))
            $UpdatedTags["$($Key.Key)"] = $($Tags["$($Key.Key)"])
            $UpdateTags = $true

        }
        else {

            Write-Verbose -Message ("Tag value is incorrect, setting tag {0} with value {1}" -f $($Key.Key), $($Tags["$($Key.Key)"]))
            $UpdatedTags["$($Key.Key)"] = $($Tags["$($Key.Key)"])
            $UpdateTags = $true
            
        }

    }

    if ($UpdateTags) {

        Write-Host "Replacing existing tags:"
        $UpdatedTags
        Set-AzureRmResourceGroup -Name $ResourceGroup.ResourceGroupName -Tag $UpdatedTags

    }


}



