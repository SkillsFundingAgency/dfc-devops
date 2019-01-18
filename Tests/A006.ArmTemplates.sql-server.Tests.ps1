# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\ArmTemplates\sql-server.json"
$TemplateParametersDefault = @{
  sqlServerName                         = "dfc-foo-bar-sql"
  sqlServerAdminPassword                = "Not-a-real-password"
  storageAccountName                    = "dfcfoobarstr"
  sqlServerActiveDirectoryAdminLogin    = "SQL_ADMIN_GRP"
  sqlServerActiveDirectoryAdminObjectId = "12345678-abcd-abcd-abcd-1234567890ab"
}
$TestTemplateParams = @{
  ResourceGroupName       = $ResourceGroupName
  TemplateFile            = $TemplateFile
}

Describe "SQL Server Deployment Tests" -Tag "Acceptance" {
  
  Context "When SQL Server deployed with required params only" {
    $TemplateParameters = $TemplateParametersDefault
    $TestTemplateParams['TemplateParameterObject'] = $TemplateParameters

    $output = Test-AzureRmResourceGroupDeployment @TestTemplateParams
  
    It "Should be deployed successfully" {
      $output | Should -Be $null
    }

  }
}