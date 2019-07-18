Push-Location -Path $PSScriptRoot\..\PSScripts\

# solves CommandNotFoundException
function Get-InstalledModule {}
function Import-Module {}
function Install-Module {}
function Get-AzureRmResource {}
function New-CosmosDbContext {}
function Get-CosmosDbDatabase {}
function New-CosmosDbDatabase {}

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

    Mock Get-CosmosDbDatabase {
        return @{
            Name    = "foobar"
        }
    } -ParameterFilter { $Id -eq "foobar" }

    Mock Get-CosmosDbDatabase { return $null } -ParameterFilter { $Id -ne "foobar" }

    Mock Get-InstalledModule
    Mock Install-Module
    Mock Import-Module
    Mock New-CosmosDbContext
    Mock New-CosmosDbDatabase

    $SampleDatasource = @'
{
    "DatabaseName": "foobar",
    "Collections": [ {
        "CollectionName": "coll",
        "OfferThroughput": 400,
        "PartitionKey": "/partkey",
        "TTL": 12345
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

        Assert-MockCalled New-CosmosDbDatabase -Exactly 1

        $DefaultParams.Remove('CosmosDbConfigurationString') # clean up

    }

    $DefaultParams['CosmosDbConfigurationString'] = $SampleDatasource

    <#

    It "Ensure Cosmos module is loaded if version is below 2.1.9.88" {

        Mock Get-Module {
            return @{
                Name    = "CosmosDB"
                Version = "2.0.9.89"
            }
        }    

        .\New-CosmosDbAccountCollections @DefaultParams

        Assert-MockCalled Get-InstalledModule -Exactly 1
        Assert-MockCalled Import-Module -Exactly 1

    }

    It "Ensure Cosmos module is not loaded if version between 2.1.9.88 and 2.1.15.239" {

        Mock Get-Module {
            return @{
                Name    = "CosmosDB"
                Version = "2.1.12.0"
            }
        }

        .\New-CosmosDbAccountCollections @DefaultParams

        Assert-MockCalled Get-InstalledModule -Exactly 0
        Assert-MockCalled Import-Module -Exactly 0

    }

    It "Ensure Cosmos module is loaded if version is above 2.1.15.239" {

        Mock Get-Module { return $null }

        .\New-CosmosDbAccountCollections @DefaultParams

        Assert-MockCalled Get-InstalledModule -Exactly 1
        Assert-MockCalled Import-Module -Exactly 1

    }
    #>
}

Push-Location -Path $PSScriptRoot