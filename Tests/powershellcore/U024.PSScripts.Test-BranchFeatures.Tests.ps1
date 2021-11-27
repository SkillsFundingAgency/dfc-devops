Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Test-BranchFeatures" -Tag "Unit" {

    Context "When testing if a branch supports SonarCloud execution" {  
        $testData = @(
            @{ SourceBranch = "dev"; ShouldHaveSonarOutput = "True" }
            @{ SourceBranch = "master"; ShouldHaveSonarOutput = "True" }
            @{ SourceBranch = "someFeatureBranch"; ShouldHaveSonarOutput = "False" }
            @{ SourceBranch = "v1-dev"; ShouldHaveSonarOutput = "True" }
            @{ SourceBranch = "v1-master"; ShouldHaveSonarOutput = "True" }
            @{ SourceBranch = "v1-someFeatureBranch"; ShouldHaveSonarOutput = "False" }
            @{ SourceBranch = "dev-v1"; ShouldHaveSonarOutput = "True" }
            @{ SourceBranch = "master-v1"; ShouldHaveSonarOutput = "True" }
            @{ SourceBranch = "someFeatureBranch-v1"; ShouldHaveSonarOutput = "False" }
            @{ SourceBranch = "v999999-dev"; ShouldHaveSonarOutput = "True" }
            @{ SourceBranch = "v999999-master"; ShouldHaveSonarOutput = "True" }
            @{ SourceBranch = "v999999-someFeatureBranch"; ShouldHaveSonarOutput = "False" }
            @{ SourceBranch = "dev-v999999"; ShouldHaveSonarOutput = "True" }
            @{ SourceBranch = "master-v999999"; ShouldHaveSonarOutput = "True" }
            @{ SourceBranch = "someFeatureBranch-v999999"; ShouldHaveSonarOutput = "False" }
        )
        
        It "Should return '<ShouldHaveSonarOutput>' for branch '<SourceBranch>'" -TestCases $testData {
            param($SourceBranch, $ShouldHaveSonarOutput)

            $env:Build_SourceBranchName = $SourceBranch

            $output = & ./Test-BranchFeatures

            $output | Should Be "##vso[task.setvariable variable=ShouldRunSonarCloud]$ShouldHaveSonarOutput"
        }

        It "Should return 'True' for pull requests" {
            $env:Build_SourceBranchName = "someSourceBranch"
            $env:Build_Reason = "PullRequest"

            $output = & ./Test-BranchFeatures

            $output | Should Be "##vso[task.setvariable variable=ShouldRunSonarCloud]True"

        }
    }
}

Pop-Location