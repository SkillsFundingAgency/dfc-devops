Push-Location -Path $PSScriptRoot\..\..\PSScripts\
Import-Module $PSScriptRoot\..\..\PSModules\AzureApiFunctions

# solves CommandNotFoundException
function Get-AzureRmResource {}
function Invoke-AzureRmResourceAction {}

Describe "Set-SearchIndexes unit tests" -Tag "Unit" {

    Mock Get-AzureRmResource {
        return @{
            ResourceId = "12345678-1234"
        }
    }

    Mock Invoke-AzureRmResourceAction {
        return @{
            PrimaryKey = "12345678=="
        }
    }

    Mock ApiRequest -ParameterFilter { $Method -eq 'POST' }
    Mock ApiRequest -ParameterFilter { $Method -eq 'PUT' }

    $SampleIndexDetails = @'
[ {
    "name" : "mock",
    "fields": [
      {"name": "id", "type": "Edm.String", "key": true, "sortable": false, "facetable": false, "searchable": false},
      {"name": "Value", "type": "Edm.String", "facetable": false}
    ]
} ]
'@

    $DefaultParams = @{ 
        SearchName        = 'mock'
        ResourceGroupName = "dfc-foo-bar-rg"
    }

    # This test will write to the error stream
    It "Ensure Set-SearchIndexes throws an error if the JSON is invalid" {

        $DefaultParams['IndexConfigurationString'] = '{ "invalid: "json" }' # missing quote after invalid

        { .\Set-SearchIndexes @DefaultParams } | Should Throw

        $DefaultParams.Remove('IndexConfigurationString') # clean up
    }

    # Pass in a valid JSON for the rest of the tests
    $DefaultParams['IndexConfigurationString'] = $SampleIndexDetails

    It "Ensure Set-SearchIndexes only calls ApiReqest once (GET only) if datasource exists and has not changed" {

        # GET will return the datasource if it exists
        Mock ApiRequest -ParameterFilter { $Method -eq 'GET' } -MockWith {
            return $SampleIndexDetails | ConvertFrom-Json
        }
        
        .\Set-SearchIndexes @DefaultParams

        Assert-MockCalled Get-AzureRmResource -Scope It -Exactly 1
        Assert-MockCalled Invoke-AzureRmResourceAction -Scope It -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'GET' } -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'POST' } -Exactly 0
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'PUT' } -Exactly 0

    }

    It "Ensure Set-SearchIndexes calls ApiReqest twice (1x GET, 1x POST) if datasource does not exist" {

        # GET will throw a 404 if not found
        Mock ApiRequest -ParameterFilter { $Method -eq 'GET' } -MockWith {
            throw
        }
        
        .\Set-SearchIndexes @DefaultParams

        Assert-MockCalled Get-AzureRmResource -Scope It -Exactly 1
        Assert-MockCalled Invoke-AzureRmResourceAction -Scope It -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'GET' } -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'POST' } -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'PUT' } -Exactly 0

    }

    It "Ensure Set-SearchIndexes posts the update if additional fields are added to the index" {

        # GET will return the sample index if it exists
        Mock ApiRequest -ParameterFilter { $Method -eq 'GET' } -MockWith {
            return $SampleIndexDetails | ConvertFrom-Json
        }
        
        $ModifiedIndexDetails = @'
[ {
    "name" : "mock",
    "fields": [
        {"name": "id", "type": "Edm.String", "key": true, "sortable": false, "facetable": false, "searchable": false},
        {"name": "Value", "type": "Edm.String", "facetable": false},
        {"name": "DateUpdated", "type": "Edm.DateTimeOffset", "sortable": false, "facetable": false}
    ]
} ]
'@

        $DefaultParams['IndexConfigurationString'] = $ModifiedIndexDetails
        .\Set-SearchIndexes @DefaultParams

        Assert-MockCalled Get-AzureRmResource -Scope It -Exactly 1
        Assert-MockCalled Invoke-AzureRmResourceAction -Scope It -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'GET' } -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'POST' } -Exactly 0
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'PUT' } -Exactly 1

        # clean up
        $DefaultParams['IndexConfigurationString'] = $SampleIndexDetails

    }
    
    # Change default params to read from file
    $DefaultParams.Remove('IndexConfigurationString') # clean up
    $DefaultParams['IndexFilePath'] = "$TestDrive\Mock.json"
    
    It "Ensure Set-SearchIndexes can read the JSON from a file" {

        Set-Content -Path $DefaultParams.IndexFilePath -Value $SampleIndexDetails

        # GET will throw a 404 if not found
        Mock ApiRequest -ParameterFilter { $Method -eq 'GET' } -MockWith {
            throw
        }
                
        .\Set-SearchIndexes @DefaultParams
        
        Assert-MockCalled Get-AzureRmResource -Scope It -Exactly 1
        Assert-MockCalled Invoke-AzureRmResourceAction -Scope It -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'GET' } -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'POST' } -Exactly 1
        
    }

}

Push-Location -Path $PSScriptRoot