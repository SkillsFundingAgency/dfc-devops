
Describe "Apim Service Deployment Tests" -Tag "Acceptance" {

    BeforeAll {
        # common variables
        $ResourceGroupName = "dfc-test-template-rg"
        $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\APIM\apim-product.json"
    }
  
    Context "When APIM product is deployed with just apimServiceName and productDisplayName" {

        BeforeAll {
            $TemplateParameters = @{
                apimServiceName    = "dfc-foo-bar-apim"
                productDisplayName = "Bar Api"
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