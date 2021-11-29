
Describe "Apim Service Deployment Tests" -Tag "Acceptance" {

    BeforeAll {
        # common variables
        $ResourceGroupName = "dfc-test-template-rg"
        $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\APIM\apim-api.json"
    }
  
    Context "When APIM api is deployed with just name, product and api name" {

        BeforeAll {
            $TemplateParameters = @{
                apimProductInstanceName = "product-bar-foo"
                apimServiceName         = "dfc-foo-bar-apim"
                apiName                 = "foo"
            }
            $TestTemplateParams = @{
                ResourceGroupName       = $ResourceGroupName
                TemplateFile            = $TemplateFile
                TemplateParameterObject = $TemplateParameters
            }
        }

        It "Should be deployed successfully" {
            $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams
            $output | Should -Be $null
        }
    }
}