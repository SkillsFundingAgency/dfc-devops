# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\eventgrid-topic.json"

Describe "Event Grid Topic Tests" -Tag "Acceptance" {
  
  Context "When an Event Grid Topic is deployed with a name and sku" {
    $TemplateParameters = @{
        eventgridTopicName = "dfc-foo-bar-egt"
        eventgridTopicSku = "basic"
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