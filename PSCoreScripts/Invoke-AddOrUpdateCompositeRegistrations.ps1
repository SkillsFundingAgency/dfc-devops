<#
.SYNOPSIS
Adds/Updates page registrations for an application in composite ui.

.DESCRIPTION
Adds/Updates page registrations for an application in composite ui.

.PARAMETER AppRegistryApiUrl
Url to the App Registry Api

.PARAMETER AppRegistryApiKey
The API key for the App Registry Api endpoint

.PARAMETER RegistrationFile
Path to the json file describing the applications registrations

.EXAMPLE
Invoke-AddOrUpdateCompositeRegistrations -AppRegistryApiUrl https://page-registration-url -AppRegistryApiKey <key> -RegistrationFile c:\Path\To\Registration\File.json
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $AppRegistryApiUrl,
    [Parameter(Mandatory=$true)]
    [string] $AppRegistryApiKey,
    [Parameter(Mandatory=$true)]
    [string] $RegistrationFile
)

Import-Module ../PSModules/CompositeRegistrationFunctionsv2 -Force

$content = Get-Content -Path $RegistrationFile -Raw
$contentAsObject = ConvertFrom-Json -InputObject $content

New-RegistrationContext -AppRegistryApiUrl $AppRegistryApiUrl -AppRegistryApiKey $AppRegistryApiKey

foreach($path in $contentAsObject) {
    Write-Output "Getting path registration for Path $($path.Path)."
    $pathEntity = Get-PathRegistration -Path $path.Path

    if($null -eq $pathEntity) {
        Write-Output "Path registration does not exist, creating new path registration."
        New-PathRegistration -Path $path
    } else {
        Write-Output "Path registration exists, checking to see if it needs updating."

        $apiPathAsHashtable = ConvertTo-HashTable -Object $pathEntity
        $definitionPathAsHashtable = ConvertTo-HashTable -Object $path

        $patchDocuments = Get-PatchDocuments -OriginalValues $apiPathAsHashtable -ReplacementValues $definitionPathAsHashtable

        if($patchDocuments.Count -gt 0) {
            $propertiesToPatch = $patchDocuments | Foreach-Object { return $_.Path -Replace "/", "" }
            Write-Output "Fields that require updates:  $($propertiesToPatch)"
            Write-Output "Updating path registration."
            Update-PathRegistration -Path $path.Path -ItemsToPatch $patchDocuments | Out-Null
        }
    }
}