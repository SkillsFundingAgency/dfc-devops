# common variables
$ResourceGroupName = "dfc-test-template-rg"
$TemplateFile = "$PSScriptRoot\..\..\ArmTemplates\cosmos-db.json"

Describe "Key Vault Deployment Tests" -Tag "Acceptance" {
  
  Context "Deploying Cosmos DB with SQL API, Eventual consistency" {
    $TemplateParameters = @{
      cosmosDbName            = "dfc-foo-bar-cdb-01"
      cosmosApiType           = "SQL"
      defaultConsistencyLevel = "Eventual"
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

  Context "Deploying Cosmos DB with Gremlin API, Session consistency" {
    $TemplateParameters = @{
      cosmosDbName            = "dfc-foo-bar-cdb-02"
      cosmosApiType           = "Gremlin"
      defaultConsistencyLevel = "Session"
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

  Context "Deploying Cosmos DB with MongoDB API, BoundedStaleness consistency" {
    $TemplateParameters = @{
      cosmosDbName            = "dfc-foo-bar-cdb-03"
      cosmosApiType           = "MongoDB"
      defaultConsistencyLevel = "BoundedStaleness"
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

  Context "Deploying Cosmos DB with Cassandra API, Strong consistency" {
    $TemplateParameters = @{
      cosmosDbName            = "dfc-foo-bar-cdb-04"
      cosmosApiType           = "Cassandra"
      defaultConsistencyLevel = "Strong"
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

  Context "Deploying Cosmos DB with Table API, ConsistentPrefix consistency" {
    $TemplateParameters = @{
      cosmosDbName            = "dfc-foo-bar-cdb-05"
      cosmosApiType           = "Table"
      defaultConsistencyLevel = "ConsistentPrefix"
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