<#
.SYNOPSIS
Adds/Updates page and region registrations for an application into the composite ui.

.DESCRIPTION
Adds/Updates page and region registrations for an application into the composite ui.

.PARAMETER PageApiUrl
Url to the Composite Page Registration Api

.PARAMETER RegionApiUrl
Url to the Composite Region Registration Api

.PARAMETER RegistrationFile Path to the json file describing the applications registrations

.EXAMPLE
New-RegistrationContext -PathApiUrl https://page-registration-url/api -RegionApiUrl https://region-registration-url/api -RegistrationFile c:\Path\To\Registration\File.json

#>

param(    
    [Parameter(Mandatory=$true)]
    [string] $PathApiUrl,
    [Parameter(Mandatory=$true)]
    [string] $RegionApiUrl,
    [Parameter(Mandatory=$true)]
    [string] $RegistrationFile
)

Import-Module ../PSModules/CompositeRegistrationFunctions -Force

$content = Get-Content -Path $RegistrationFile
$contentAsObject = $content | ConvertFrom-Json

New-RegistrationContext -PathApiUrl $PathApiUrl -RegionApiUrl $RegionApiUrl

foreach($path in $contentAsObject) {
    $pathEntity = Get-PathRegistration -Path $path.Path
    
    if($null -eq $pathEntity) {
        New-PathRegistration -Path $path
    } else {
        $itemsToUpdate = Get-DifferencesBetweenPathObjects -ObjectFromApi $pathEntity -ObjectFromFile $path

        if($itemsToUpdate.Count -gt 1) {
            Update-PathRegistration -Path $path.Path -ItemsToUpdate $itemsToUpdate | Out-Null
        }
    }

    foreach($region in $path.Regions) {
        $regionEntity = Get-RegionRegistration -Path $path.Path -PageRegion $region.PageRegion

        if($null -eq $regionEntity) {
            New-RegionRegistration -Path $path.Path -Region $region
        } else {
            $itemsToUpdate = Get-DifferencesBetweenRegionObjects -ObjectFromApi $regionEntity -ObjectFromFile $region

            if($itemsToUpdate.Count -gt 2) {
                Update-RegionRegistration -Path $path.Path -PageRegion $region.PageRegion -ItemsToUpdate $itemsToUpdate | Out-Null
            }
        }
    }
}
