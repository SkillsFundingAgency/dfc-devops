
Describe "Service Bus Topic Subscription Deployment Tests" -Tag "Acceptance" {
  BeforeAll {
    # common variables
    $ResourceGroupName = "dfc-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\ServiceBus\servicebus-topic-subscription.json"
    
  }
      
  Context "When deploying a Subscription to a Service Bus Topic" {

    BeforeAll {
      $TemplateParameters = @{
        serviceBusNamespaceName         = "dfc-foo-bar-ns"
        serviceBusTopicName             = "topic-name"
        serviceBusTopicSubscriptionName = "subname"
      }
      $TestTemplateParams = @{
        ResourceGroupName       = $ResourceGroupName
        TemplateFile            = $TemplateFile
        TemplateParameterObject = $TemplateParameters
      }
    }

    It "Should be deployed successfully with just a subscription" -Foreach @{TestTemplateParams = $TestTemplateParams } {
      $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams

      $output | Should -Be $null
      if ($output) {
        Write-Error $output.Message
      }
    }


    It "Should be deployed successfully when the SQL filter is specified" -Foreach @{TestTemplateParams = $TestTemplateParams } {
      $TestTemplateParams['subscriptionSqlFilter'] = "value = something"

      $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams

      $output | Should -Be $null
      if ($output) {
        Write-Error $output.Message
      }
  
    }


  }
}