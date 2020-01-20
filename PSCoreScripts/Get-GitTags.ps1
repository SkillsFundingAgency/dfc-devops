<#
.SYNOPSIS
Converts the Git tags to VSTS tags

.DESCRIPTION
Checks if the branch has any tags in git and add these tags to VSTS.
Also allows an optional additional tag to be added in VSTS.

.PARAMETER RepositoryPath
Path to the git root directory (the one with the .git directory in)

.PARAMETER RenameFilter
[Optional] Allows you to change the tag created
Takes a dictionary where the key is the tag to create if the git tab matches the value. The value accepts wildcards

.PARAMETER AdditionalTag
[Optional] Add an additional tag to VSTS

.EXAMPLE
Get-GitTags -RepositoryPath $(Build.Repository.LocalPath)

.EXAMPLE
Get-GitTags -RepositoryPath $GitPath -RenameFilter @{ lab = "lab-*" }

.EXAMPLE
Get-GitTags -RepositoryPath $GitPath -AdditionalTag $(BUILD_SOURCEBRANCHNAME)

#>
param(
    [Parameter(Mandatory=$true)]
    [string] $RepositoryPath,
    [Parameter(Mandatory=$false)]
    [hashtable] $RenameFilter,
    [Parameter(Mandatory=$false)]
    [string] $AdditionalTag
)

function Invoke-GitTag {
    param (
        [Parameter(Mandatory=$true)] [string] $RepositoryPath
    )
    git --git-dir="$RepositoryPath\.git" tag -l --points-at HEAD
}

Write-Output "Repository Path is $RepositoryPath"
$GitTags = Invoke-GitTag -RepositoryPath $RepositoryPath

if ($GitTags) {
    foreach ($Tag in $GitTags) {
        Write-Output "Processing Git tag: $Tag"
        if ($RenameFilter) {
            # Rename filter passed in, loop through values to see if any like the tag
            foreach ($Rename in $RenameFilter.Keys) {
                if ($Tag -like $RenameFilter[$Rename]) {
                    $Tag = $Rename
                    Write-Output "Renamed by filter to $Tag"
                    break
                }
            }
        }
        Write-Output "##vso[build.addbuildtag]$Tag"
    }
}
else {
    Write-Output "No tags present in git branch"
}

if ($AdditionalTag) {
    Write-Output "Adding tag $AdditionalTag"
    Write-Output "##vso[build.addbuildtag]$AdditionalTag"
}
