Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Get-GitTags unit tests" -Tag "Unit" {

    # Create Invoke-GitTag so it can be mocked (cannot mock git directly)
    function Invoke-GitTag {}
    $gitpath = "$TestDrive\Mock"

    It "Should create no tags if not tags are in Git" {
        Mock Invoke-GitTag { return "" }

        $output = .\Get-GitTags -RepositoryPath $gitpath
        $output -contains "No tags present in git branch" | Should be $true
    }

    It "Should create one tag if git returns a single tag" {
        Mock Invoke-GitTag { return "onetag" }

        $output = .\Get-GitTags -RepositoryPath $gitpath
        $output -contains "##vso[build.addbuildtag]onetag" | Should be $true
    }

    It "Should create multiple tags if Git has multiple tags" {
        Mock Invoke-GitTag { return @("firsttag","secondtag") }

        $output = .\Get-GitTags -RepositoryPath $gitpath
        $output -contains "##vso[build.addbuildtag]firsttag" | Should be $true
        $output -contains "##vso[build.addbuildtag]secondtag" | Should be $true
    }

    It "Should create rename a tag if tag matches a value in RenameFilter" {
        Mock Invoke-GitTag { return @("mytesttag") }

        $output = .\Get-GitTags -RepositoryPath $gitpath -RenameFilter @{ SIT = "*test*" }
        $output -contains "##vso[build.addbuildtag]SIT" | Should be $true
    }

    It "Optional additional tag should be written if present" {
        Mock Invoke-GitTag { return "" }

        $output = .\Get-GitTags -RepositoryPath $gitpath -AdditionalTag "foobar"
        $output -contains "##vso[build.addbuildtag]foobar" | Should be $true
    }

}

Push-Location -Path $PSScriptRoot