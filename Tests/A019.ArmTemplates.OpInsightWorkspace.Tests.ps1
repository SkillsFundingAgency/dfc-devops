# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\ArmTemplates\opinsight-workspace.json"

Describe "Operational Insights Workspace Tests" -Tag "Acceptance" {
  
    Context "Default deployment of workspace" {

        $TemplateParameters = @{
            oiwName = "dfc-foo-bar-oms"
        }
        $TestTemplateParams = @{
            ResourceGroupName       = $ResourceGroupName
            TemplateFile            = $TemplateFile
            TemplateParameterObject = $TemplateParameters
        }

        $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams
        Write-Verbose $output.Message

        It "Should be deployed successfully" {
            $output | Should -Be $null
        }

    }

}