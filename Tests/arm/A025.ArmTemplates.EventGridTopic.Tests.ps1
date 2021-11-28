
Describe "Event Grid Topic Tests" -Tag "Acceptance" {

  BeforeAll {
    # common variables
    $ResourceGroupName = "dfc-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\eventgrid-topic.json"
  }

  Context "When an Event Grid Topic is deployed with a name and sku" {

    BeforeAll {
      $TemplateParameters = @{
        eventgridTopicName = "dfc-foo-bar-egt"
        eventgridTopicSku  = "basic"
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