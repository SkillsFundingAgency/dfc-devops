<#
.SYNOPSIS
Adds/Updates page and region registrations for an application into the composite ui.

.DESCRIPTION
Adds/Updates page and region registrations for an application into the composite ui.

.PARAMETER PathApiUrl
Url to the Composite Page Registration Api

.PARAMETER RegionApiUrl
Url to the Composite Region Registration Api

.PARAMETER RegistrationFile 
Path to the json file describing the applications registrations

.EXAMPLE
New-RegistrationContext -PathApiUrl https://page-registration-url/api -RegionApiUrl https://region-registration-url/api -RegistrationFile c:\Path\To\Registration\File.json

#>

param(    
    [Parameter(Mandatory=$true)]
    [string] $PathApiUrl,
    [Parameter(Mandatory=$true)]
    [string] $RegionApiUrl,
    [Parameter(Mandatory=$true)]
    [string] $ApiKey,
    [Parameter(Mandatory=$true)]
    [string] $RegistrationFile
)

Import-Module ../PSModules/CompositeRegistrationFunctions -Force

$content = Get-Content -Path $RegistrationFile -Raw
$contentAsObject = ConvertFrom-Json -InputObject $content

New-RegistrationContext -PathApiUrl $PathApiUrl -RegionApiUrl $RegionApiUrl -ApiKey $ApiKey

foreach($path in $contentAsObject) {
    Write-Verbose "Getting path registration for Path $($path.Path)."
    $pathEntity = Get-PathRegistration -Path $path.Path
    
    if($null -eq $pathEntity) {
        Write-Verbose "Path registration does not exist, creating new path registration."
        New-PathRegistration -Path $path
    } else {
        Write-Verbose "Path registration exists, checking to see if it needs updating."
        $itemsToUpdate = Get-DifferencesBetweenPathObjects -Left $pathEntity -Right $path

        if($itemsToUpdate.Count -gt 0) {
            Write-Verbose "Fields that require updates:  $($itemsToUpdate.Keys)"
            Write-Verbose "Updating path registration."
            Update-PathRegistration -Path $path.Path -ItemsToUpdate $itemsToUpdate | Out-Null
        }
    }

    foreach($region in $path.Regions) {
        Write-Verbose "Getting region registration for Path $($path.Path), PageRegion $($region.PageRegion)."
        $regionEntity = Get-RegionRegistration -Path $path.Path -PageRegion $region.PageRegion

        if($null -eq $regionEntity) {
            Write-Verbose "Region registration does not exist, creating new region registration."
            New-RegionRegistration -Path $path.Path -Region $region
        } else {
            Write-Verbose "Region registration exists, checking to see if it needs updating."
            $itemsToUpdate = Get-DifferencesBetweenRegionObjects -Left $regionEntity -Right $region

            if($itemsToUpdate.Count -gt 0) {
                Write-Verbose "Fields that require updates:  $($itemsToUpdate.Keys)"
                Write-Verbose "Updating region registration."
                Update-RegionRegistration -Path $path.Path -PageRegion $region.PageRegion -ItemsToUpdate $itemsToUpdate | Out-Null
            }
        }
    }
}
