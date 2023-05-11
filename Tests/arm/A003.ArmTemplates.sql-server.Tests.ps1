Describe "SQL Server Deployment Tests" -Tag "Acceptance" {

  BeforeAll {
    # common variables
    $ResourceGroupName = "dfc-test-template-rg"
    $TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\sql-server.json"
    $TemplateParametersDefault = @{
      sqlServerName                         = "dfc-foo-bar-sql"
      sqlServerAdminPassword                = "Not-a-real-password"
      storageAccountName                    = "dfctesttemplatestr"
      sqlServerActiveDirectoryAdminLogin    = "SQL_ADMIN_GRP"
      sqlServerActiveDirectoryAdminObjectId = "12345678-abcd-abcd-abcd-1234567890ab"
    }
    $TestTemplateParams = @{
      ResourceGroupName = $ResourceGroupName
      TemplateFile      = $TemplateFile
    }
  }

  Context "When SQL Server deployed with required params only" {

    It "Should be deployed successfully" {
      $TemplateParameters = $TemplateParametersDefault
      $TestTemplateParams['TemplateParameterObject'] = $TemplateParameters
  
      $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams
      $output | Should -Be $null
    }
  }

  Context "When SQL Server deployed with specifying SQL Server Admin Username" {
  
    It "Should be deployed successfully" {
      $TemplateParameters = $TemplateParametersDefault
      $TemplateParameters['sqlServerAdminUserName'] = "DummySA"
      $TestTemplateParams['TemplateParameterObject'] = $TemplateParameters
  
      $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams
      $output | Should -Be $null
    }
  }

  Context "When SQL Server deployed with a list of threat detection email addresses" {
  
    It "Should be deployed successfully" {

      $TemplateParameters = $TemplateParametersDefault
      $TemplateParameters['threatDetectionEmailAddress'] = @( "dummy@example.com" )
      $TestTemplateParams['TemplateParameterObject'] = $TemplateParameters
  
      $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams
      $output | Should -Be $null
    }
  }

  Context "When SQL Server deployed with an elastic pool (just name specified)" {

    It "Should be deployed successfully" {

      $TemplateParameters = $TemplateParametersDefault
      $TemplateParameters['elasticPoolName'] = "dfc-foo-bar-epl"
      $TestTemplateParams['TemplateParameterObject'] = $TemplateParameters
  
      $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams
      $output | Should -Be $null
    }
  }
}