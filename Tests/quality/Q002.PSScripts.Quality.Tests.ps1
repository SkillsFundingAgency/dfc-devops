Describe "Code quality tests" -Tag "Quality" {

    $scriptFolders = @("PSScripts", "PSCoreScripts" )
    $Scripts = @()

    foreach($folder in $scriptFolders) {
        $Scripts += (Get-ChildItem -Path $PSScriptRoot\..\..\$folder\*.ps1 -File -Recurse)
    }

    $Rules = Get-ScriptAnalyzerRule
    $ExcludeRules = @(
        "PSAvoidUsingWriteHost",
        "PSAvoidUsingEmptyCatchBlock",
        "PSAvoidUsingPlainTextForPassword",
        "PSAvoidUsingConvertToSecureStringWithPlainText"
    )

    foreach ($Script in $Scripts) {
        Context $Script.BaseName {
            forEach ($Rule in $Rules) {
                It "Should pass Script Analyzer rule $Rule" {
                    $Result = Invoke-ScriptAnalyzer -Path $Script.FullName -IncludeRule $Rule -ExcludeRule $ExcludeRules
                    $Result.Count | Should Be 0
                }
            }
        }
    }
}
