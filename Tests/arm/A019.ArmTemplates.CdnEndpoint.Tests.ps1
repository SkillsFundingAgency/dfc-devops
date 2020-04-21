# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\CDN\cdn-endpoint.json"
$TemplateParametersDefault = @{
    cdnProfileName = "dfc-foo-shared-cdn"
    cdnEndPointName = "dfc-foo-bar-assets"
    originHostName = "https://dfcfoobarstr.z6.web.core.windows.net/"
}

Describe "CDN Endpoint Deployment Tests" -Tag "Acceptance" {
  
    Context "When CDN Endpoint is deployed with cdnProfileName, cdnEndPointName and originHostName" {

        $TemplateParameters = $TemplateParametersDefault
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

    Context "When CDN Endpoint is deployed with cdnProfileName, cdnEndPointName, originHostName and cacheExpirationOverride" {

        $TemplateParameters = $TemplateParametersDefault
        $TemplateParameters['cacheExpirationOverride'] = "7"
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