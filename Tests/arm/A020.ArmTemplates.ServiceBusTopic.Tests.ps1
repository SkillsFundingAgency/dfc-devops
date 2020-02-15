# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\ServiceBus\servicebus-topic.json"

Describe "Service Bus Topic Deployment Tests" -Tag "Acceptance" {
  
  Context "When deploying the Service Bus Topic" {
    $TemplateParameters = @{
      serviceBusNamespaceName = "dfc-foo-bar-ns"
      serviceBusTopicName     = "topic-name"
    }
    $TestTemplateParams = @{
      ResourceGroupName       = $ResourceGroupName
      TemplateFile            = $TemplateFile
      TemplateParameterObject = $TemplateParameters
    }
  
    It "Should be deployed successfully" {
      $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams
      $output | Should -Be $null
    }

    if ($output) {
      Write-Error $output.Message
    }

  }
}