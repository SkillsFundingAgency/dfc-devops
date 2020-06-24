# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\eventgrid-subscription.json"

Describe "Event Grid Subscription Tests" -Tag "Acceptance" {
  
  Context "When an Event Grid Subscription is deployed" {
    $TemplateParameters = @{
        eventgridTopicName = "dfc-foo-bar-egt"
        eventgridSubscriptionName = "dfc-foo-bar-egs"
        eventGridSubscriptionUrl = "https://foo.bar"
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