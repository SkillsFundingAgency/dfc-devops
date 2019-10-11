# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\ArmTemplates\ServiceBus\servicebus-topic.json"

Describe "Service Bus Topic Deployment Tests" -Tag "Acceptance" {
  
  Context "When an app gateway is deployed with just a single pool" {
    $TemplateParameters = @{
      serviceBusNamespaceName = "dfc-foo-bar-ns"
      serviceBusTopicName     = "topic-name"
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

    if ($output) {
      Write-Error $output.Message
    }

  }
}