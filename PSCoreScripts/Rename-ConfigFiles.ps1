<#
.SYNOPSIS
Renames config.template files to config

.DESCRIPTION
Renames config.template files to config

.PARAMETER RootPath
Path to the root directory to start the rename from

.EXAMPLE
Rename-ConfigFiles -RootPath $(BUILD_SOURCESDIRECTORY)

#>
param(
    [Parameter(Mandatory=$true)]
    [string] $RootPath
)

$CurrentLocation = Get-Location
Write-Output "Root folder $RootPath"
Set-Location $RootPath

foreach ($ConfigFile in Get-ChildItem -Filter "*.config.template" -Recurse) {
    $NewName = $ConfigFile.Name -replace '.config.template','.config'
    Write-Output "Renaming $($ConfigFile.FullName) to $NewName"
    Rename-Item -Path $ConfigFile.FullName -NewName $NewName
}

Set-Location $CurrentLocation