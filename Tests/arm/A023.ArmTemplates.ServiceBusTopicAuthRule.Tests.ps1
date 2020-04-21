# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\ServiceBus\servicebus-topic-authrule.json"

Describe "Service Bus Topic Authorization Rule (shared access policy) Deployment Tests" -Tag "Acceptance" {
  
  Context "When deploying a shared access policy to a Service Bus Topic" {
    $TemplateParameters = @{
      servicebusName        = "dfc-foo-bar-ns"
      topicName             = "topic-name"
      authorizationRuleName = "myrule"
      rights                = @( "listen" )
    }
    $TestTemplateParams = @{
      ResourceGroupName       = $ResourceGroupName
      TemplateFile            = $TemplateFile
      TemplateParameterObject = $TemplateParameters
    }

    It "Should be deployed successfully with just a subscription" {
      $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams
      $output | Should -Be $null
    }

    if ($output) {
      Write-Error $output.Message
    }
  }
}