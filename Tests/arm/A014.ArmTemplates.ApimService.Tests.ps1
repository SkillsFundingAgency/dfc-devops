# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\apim-service.json"

Describe "Apim Service Deployment Tests" -Tag "Acceptance" {
  
    Context "When APIM service is deployed with just name, admin email, environment name and organisation name" {
        $TemplateParameters = @{
            adminEmail          = "foo@bar.com"
            apimServiceName     = "dfc-foo-bar-apim"
            environmentName     = "foo"
            organizationName    = "Foo Bar"
        }
        $TestTemplateParams = @{
            ResourceGroupName       = $ResourceGroupName
            TemplateFile            = $TemplateFile
            TemplateParameterObject = $TemplateParameters
        }

        $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams
  
        It "Should be deployed successfully" {
            $output | Should -Be $null
        }

    }

}