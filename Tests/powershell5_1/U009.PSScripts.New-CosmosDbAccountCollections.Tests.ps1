Push-Location -Path $PSScriptRoot\..\..\PSScripts\

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
function Set-CosmosDbCollection ($DefaultTimeToLive) {}
function Get-CosmosDbOffer {}
function Set-CosmosDbOffer ($OfferThroughput) {}

Describe "New-CosmosDbAccountCollections unit tests" -Tag "Unit" {

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
            PartitionKey    = "/partkey"
            DefaultTtl      = 12345
        }
    } -ParameterFilter { $Id -eq "coll" }

    Mock Set-CosmosDbCollection {
        $cosmosCollection = New-Object -TypeName PSCustomObject @{
            DefaultTTL      = $DefaultTimeToLive
            indexingPolicy  = New-Object -TypeName PSCustomObject
        }
        return $cosmosCollection
    }

    Mock Get-CosmosDbOffer {
        return @{
            content = @{ OfferThroughput = 400 }
        }
    }

    Mock Set-CosmosDbOffer {
        return @{
            content = @{ OfferThroughput = $OfferThroughput }
        }
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

        $VerboseOutput = .\New-CosmosDbAccountCollections @DefaultParams -Verbose 4>&1

        Assert-MockCalled Set-CosmosDbCollection -ParameterFilter { $DefaultTimeToLive -eq 10000 } -Exactly 1 -Scope It
        Assert-MockCalled Set-CosmosDbOffer -Exactly 0 -Scope It
        ($VerboseOutput -like "Updating Time To Live (TTL) to 10000").Length | Should -Be 1
        ($VerboseOutput -like "OfferThroughput already set to 400.  Not updating.").Length | Should -Be 1

        $DefaultParams.Remove('CosmosDbConfigurationString') # clean up

    }

    It "Cosmos collection is updated when OfferThroughput is changed" {

        $DefaultParams['CosmosDbConfigurationString'] = $CollectionExists.Replace('400','444')

        $VerboseOutput = .\New-CosmosDbAccountCollections @DefaultParams -Verbose 4>&1

        Assert-MockCalled Set-CosmosDbCollection -Exactly 0 -Scope It
        Assert-MockCalled Set-CosmosDbOffer -Exactly 1 -Scope It
        ($VerboseOutput -like "Time To Live (TTL) already set to 12345.  Not updating.").Length | Should -Be 1
        ($VerboseOutput -like "OfferThroughput set to 444").Length | Should -Be 1

        $DefaultParams.Remove('CosmosDbConfigurationString') # clean up

    }

}

Push-Location -Path $PSScriptRoot