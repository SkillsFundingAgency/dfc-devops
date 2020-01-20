# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\azure-search.json"

Describe "Azure Search Deployment Tests" -Tag "Acceptance" {
  
  Context "When Azure Search is deployed with just search name" {
    $TemplateParameters = @{
      azureSearchName = "dfc-foo-bar-sch-01"
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

  Context "When Azure Search is deployed with tier (sku) set to standard" {
    $TemplateParameters = @{
      azureSearchName = "dfc-foo-bar-sch-02"
      azureSearchSku  = "standard"
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

  Context "When Azure Search is deployed with all parameters supplied" {
    $TemplateParameters = @{
      azureSearchName           = "dfc-foo-bar-sch-03"
      azureSearchSku            = "standard2"
      azureSearchReplicaCount   = 2
      azureSearchPartitionCount = 2

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