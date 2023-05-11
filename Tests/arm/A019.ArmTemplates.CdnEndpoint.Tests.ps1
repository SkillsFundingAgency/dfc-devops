Describe "CDN Endpoint Deployment Tests" -Tag "Acceptance" {

    
    BeforeAll {
        # common variables
        $ResourceGroupName = "dfc-test-template-rg"
        $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\CDN\cdn-endpoint.json"
        $TemplateParametersDefault = @{
            cdnProfileName  = "dfc-foo-shared-cdn"
            cdnEndPointName = "dfc-foo-bar-assets"
            originHostName  = "https://dfcfoobarstr.z6.web.core.windows.net/"
        }
    }

    Context "When CDN Endpoint is deployed with cdnProfileName, cdnEndPointName and originHostName" {

        BeforeAll{
            $TemplateParameters = $TemplateParametersDefault
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

    Context "When CDN Endpoint is deployed with cdnProfileName, cdnEndPointName, originHostName and cacheExpirationOverride" {

        BeforeAll{
            $TemplateParameters = $TemplateParametersDefault
            $TemplateParameters['cacheExpirationOverride'] = "7"
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