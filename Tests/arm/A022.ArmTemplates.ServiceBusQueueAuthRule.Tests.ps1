# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\ServiceBus\servicebus-queue-authrule.json"

Describe "Service Bus Queue Authorization Rule (shared access policy) Deployment Tests" -Tag "Acceptance" {
  
  Context "When deploying a shared access policy to a Service Bus Queue" {
    $TemplateParameters = @{
      servicebusName        = "dfc-foo-bar-ns"
      queueName             = "queue-name"
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