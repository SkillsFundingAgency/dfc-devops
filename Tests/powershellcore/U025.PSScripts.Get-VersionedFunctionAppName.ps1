Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Get-VersionedFunctionAppName" -Tag "Unit" {

    Context "When getting a versioned function app name with poorly formatted function app" {

        It "should throw an exception" {
            $env:Build_SourceBranchName = "dev"
            $env:FunctionAppBaseName = "someFunctionApp"

            {
                & ./Get-VersionedFunctionAppName
            } | Should Throw
        }
    }

    Context "When getting a versioned app" {
        $testData = @(
            @{ SourceBranch = "dev"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "dfc-dev-test-v1-fa" }
            @{ SourceBranch = "master"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "dfc-dev-test-v1-fa" }
            @{ SourceBranch = "v1-dev"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "dfc-dev-test-v1-fa" }
            @{ SourceBranch = "v1-master"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "dfc-dev-test-v1-fa" }
            @{ SourceBranch = "dev-v1"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "dfc-dev-test-v1-fa" }
            @{ SourceBranch = "master-v1"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "dfc-dev-test-v1-fa" }
            @{ SourceBranch = "v999999-dev"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "dfc-dev-test-v999999-fa" }
            @{ SourceBranch = "v999999-master"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "dfc-dev-test-v999999-fa" }
            @{ SourceBranch = "dev-v999999"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "dfc-dev-test-v999999-fa" }
            @{ SourceBranch = "master-v999999"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "dfc-dev-test-v999999-fa" }
            @{ SourceBranch = "dev-v5"; FunctionBaseName = "dfc-dev-draft-component-fa"; ExpectedResult = "dfc-dev-draft-component-v5-fa" }
        )

        It "Should return '<ExpectedResult>' for branch <SourceBranch>' and functionName '<FunctionBaseName>'" -TestCases $testData {
            param($SourceBranch, $FunctionBaseName, $ExpectedResult)

            $env:Build_SourceBranchName = $SourceBranch
            $env:FunctionAppBaseName = $FunctionBaseName

            $allOutput = & ./Get-VersionedFunctionAppName

            $functionAppOutput = $allOutput | Where-Object { $_ -like "*FunctionAppName*" }

            $functionAppOutput | Should Be "##vso[task.setvariable variable=FunctionAppName;isOutput=false]$ExpectedResult"
        }
    }

    Context "When getting an api version" {
        $testData = @(
            @{ SourceBranch = "dev"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "v1" }
            @{ SourceBranch = "master"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "v1" }
            @{ SourceBranch = "v1-dev"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "v1" }
            @{ SourceBranch = "v1-master"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "v1" }
            @{ SourceBranch = "dev-v1"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "v1" }
            @{ SourceBranch = "master-v1"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "v1" }
            @{ SourceBranch = "v999999-dev"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "v999999" }
            @{ SourceBranch = "v999999-master"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "v999999" }
            @{ SourceBranch = "dev-v999999"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "v999999" }
            @{ SourceBranch = "master-v999999"; FunctionBaseName = "dfc-dev-test-fa"; ExpectedResult = "v999999" }
        )

        It "Should return '<ExpectedResult>' for branch <SourceBranch>' and functionName '<FunctionBaseName>'" -TestCases $testData {
            param($SourceBranch, $FunctionBaseName, $ExpectedResult)

            $env:Build_SourceBranchName = $SourceBranch
            $env:FunctionAppBaseName = $FunctionBaseName

            $allOutput = & ./Get-VersionedFunctionAppName

            $functionAppOutput = $allOutput | Where-Object { $_ -like "*ApiVersion*" }

            $functionAppOutput | Should Be "##vso[task.setvariable variable=ApiVersion;isOutput=false]$ExpectedResult"
        }
    }
}

Pop-Location