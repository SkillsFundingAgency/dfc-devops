Push-Location -Path $PSScriptRoot\..\PSScripts\

# solves CommandNotFoundException
function Get-InstalledModule {}
function Import-Module {}
function Install-Module {}
function Get-AzureRmResource {}
function New-CosmosDbContext {}
function Get-CosmosDbDatabase ($Id) {}
function New-CosmosDbDatabase {}
function Get-CosmosDbCollection ($Id) {}
function New-CosmosDbCollection {}
function Set-CosmosDbCollection ($DefaultTimeToLive, $OfferThroughput) {}

Describe "New-CosmosDbAccountCollections unit tests" -Tag "Unit" {

<#
    Mock Get-Module {
        return @{
            Name    = "CosmosDB"
            Version = "2.1.9.88"
        }
    }
#>

    Mock Get-AzureRmResource {
        return @{
            Properties = @{ provisioningState = "Succeeded" }
        }
    }

    Mock New-CosmosDbContext {
        return @{
            Account = "ABC123"
        }
    }

    Mock Get-CosmosDbDatabase { return $null } # database name != foobar
    Mock Get-CosmosDbDatabase {
        return @{
            Name = "foobar"
        }
    } -ParameterFilter { $Id -eq "foobar" }

    Mock Get-CosmosDbCollection { return $null } # collection name !- coll
    Mock Get-CosmosDbCollection {
        return @{
            CollectionName  = "coll"
            OfferThroughput = 400
            PartitionKey    = "/partkey"
            DefaultTtl      = 12345
        }
    } -ParameterFilter { $Id -eq "coll" }

    Mock Set-CosmosDbCollection {
        $cosmosCollection = New-Object -TypeName PSCustomObject @{
            DefaultTTL      = $DefaultTimeToLive
            OfferThroughput = $OfferThroughput
            indexingPolicy  = New-Object -TypeName PSCustomObject
        }
        return $cosmosCollection
    }

    Mock Get-InstalledModule
    Mock Install-Module
    Mock Import-Module
    Mock New-CosmosDbDatabase
    Mock New-CosmosDbCollection

    $CollectionNotExists = @'
{
    "DatabaseName": "foobar",
    "Collections": [ {
        "CollectionName": "doesnotexist",
        "OfferThroughput": 500
    } ]
}
'@
    
    $CollectionExists = @'
{
    "DatabaseName": "foobar",
    "Collections": [ {
        "CollectionName": "coll",
        "OfferThroughput": 400,
        "PartitionKey": "/partkey",
        "DefaultTTL": 12345
    } ]
}
'@

    $DefaultParams = @{ 
        CosmosDbAccountName = 'dfc-foo-bar-cdb'
        ResourceGroupName   = "dfc-foo-bar-rg"
    }

    # This test will write to the error stream
    It "Ensure Set-SearchDatasources throws an error if the JSON is invalid" {

        $DefaultParams['CosmosDbConfigurationString'] = '{ "invalid: "json" }' # missing quote after invalid

        { .\New-CosmosDbAccountCollections @DefaultParams } | Should Throw

        $DefaultParams.Remove('CosmosDbConfigurationString') # clean up
    }

    It "Ensure Cosmos database is created if it doesnt exist" {

        $DefaultParams['CosmosDbConfigurationString'] = '{ "DatabaseName": "doesnotexist", "Collections": [] }'

        .\New-CosmosDbAccountCollections @DefaultParams

        Assert-MockCalled New-CosmosDbDatabase -Exactly 1 -Scope It

        $DefaultParams.Remove('CosmosDbConfigurationString') # clean up

    }

    It "Ensure Cosmos database is not created if it already exists" {

        $DefaultParams['CosmosDbConfigurationString'] = '{ "DatabaseName": "foobar", "Collections": [] }'

        .\New-CosmosDbAccountCollections @DefaultParams

        Assert-MockCalled New-CosmosDbDatabase -Exactly 0 -Scope It

        $DefaultParams.Remove('CosmosDbConfigurationString') # clean up

    }

    It "Ensure Cosmos collection is created if it does not already exist" {

        $DefaultParams['CosmosDbConfigurationString'] = $CollectionNotExists

        .\New-CosmosDbAccountCollections @DefaultParams

        Assert-MockCalled New-CosmosDbCollection -Exactly 1 -Scope It

        $DefaultParams.Remove('CosmosDbConfigurationString') # clean up

    }

    It "Cosmos collection should not be created if it already exists" {

        $DefaultParams['CosmosDbConfigurationString'] = $CollectionExists

        .\New-CosmosDbAccountCollections @DefaultParams

        Assert-MockCalled New-CosmosDbCollection -Exactly 0 -Scope It

        $DefaultParams.Remove('CosmosDbConfigurationString') # clean up

    }

    It "Cosmos collection that exists should not update when no changes are made" {

        $DefaultParams['CosmosDbConfigurationString'] = $CollectionExists

        .\New-CosmosDbAccountCollections @DefaultParams

        Assert-MockCalled Set-CosmosDbCollection -Exactly 0 -Scope It

        $DefaultParams.Remove('CosmosDbConfigurationString') # clean up

    }

    It "Cosmos collection is updated when DefaultTtl is changed" {

        $DefaultParams['CosmosDbConfigurationString'] = $CollectionExists.Replace('12345','10000')

        .\New-CosmosDbAccountCollections @DefaultParams

        Assert-MockCalled Set-CosmosDbCollection -ParameterFilter { $DefaultTimeToLive -eq 10000 } -Exactly 1 -Scope It

        $DefaultParams.Remove('CosmosDbConfigurationString') # clean up

    }

    It "Cosmos collection is updated when OfferThroughput is changed" {

        $DefaultParams['CosmosDbConfigurationString'] = $CollectionExists.Replace('400','444')

        .\New-CosmosDbAccountCollections @DefaultParams

        Assert-MockCalled Set-CosmosDbCollection -ParameterFilter { $OfferThroughput -eq 444 } -Exactly 1 -Scope It

        $DefaultParams.Remove('CosmosDbConfigurationString') # clean up

    }

}

Push-Location -Path $PSScriptRoot