<#
.SYNOPSIS
Runs the Code Quality tests

.DESCRIPTION
Runs the Code Quality tests

.EXAMPLE
Q002.Powershell.Quality.Tests.ps1

#>

BeforeDiscovery {
    $scriptFolders = @("PSScripts", "PSCoreScripts" )
    $Scripts = @()

    foreach($folder in $scriptFolders) {
        $Scripts += (Get-ChildItem -Path $PSScriptRoot\..\..\$folder\*.ps1 -File -Recurse)
    }
    Write-Host "File count discovered for Code quality Tests: $($Scripts.Count)"
}
Describe "Code quality tests" -ForEach @($Scripts) -Tag "Quality" {

    BeforeDiscovery {
        $ScriptName = $_.FullName
        Write-Output "Script name: $($ScriptName)"
        $ExcludeRules = @(
            "PSUseSingularNouns",
            "PSAvoidUsingWriteHost",
            "PSAvoidUsingEmptyCatchBlock",
            "PSAvoidUsingPlainTextForPassword",
            "PSAvoidUsingConvertToSecureStringWithPlainText",
            "PSUseShouldProcessForStateChangingFunctions"
        )
        Write-Output "Exclude Rules Count: $($ExcludeRules.Count)"
        $Rules = Get-ScriptAnalyzerRule
        Write-Output "Rules Count: $($Rules.Count)"
    }

    Context "Code Quality Test $ScriptName" -Foreach @{scriptName = $scriptName; rules = $Rules; excludeRules = $ExcludeRules } {
        It "Should pass Script Analyzer rule '<_>'" -ForEach @($Rules) {
            $Result = Invoke-ScriptAnalyzer -Path $($scriptName) -IncludeRule $_ -ExcludeRule $ExcludeRules
            $Result.Count | Should -Be 0
        }
    }
}
