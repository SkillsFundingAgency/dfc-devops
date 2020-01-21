Push-Location -Path $PSScriptRoot\..\..\PSScripts\
Import-Module $PSScriptRoot\..\..\PSModules\AzureApiFunctions

# solves CommandNotFoundException
function Get-AzureRmResource {}
function Invoke-AzureRmResourceAction {}

Describe "Set-SearchIndexers unit tests" -Tag "Unit" {

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

    $SampleDatasource = @'
[ {
    "name" : "mock",
    "description": "mock datasource",
    "dataSourceName": "mock-datasource",
    "targetIndexName": "mock"
} ]
'@

    $DefaultParams = @{ 
        SearchName        = 'mock'
        ResourceGroupName = "dfc-foo-bar-rg"
    }

    # This test will write to the error stream
    It "Ensure Set-SearchIndexers throws an error if the JSON is invalid" {

        $DefaultParams['IndexConfigurationString'] = '{ "invalid": json" }' # missing quote before json value

        { .\Set-SearchIndexers @DefaultParams } | Should Throw

        $DefaultParams.Remove('IndexConfigurationString') # clean up
    }

    # Pass in a valid JSON for the rest of the tests
    $DefaultParams['IndexConfigurationString'] = $SampleDatasource

    It "Ensure Set-SearchIndexers only calls ApiReqest once (GET only) if datasource exists" {

        # GET will return the datasource if it exists
        Mock ApiRequest -ParameterFilter { $Method -eq 'GET' } -MockWith {
            return $SampleDatasource | ConvertFrom-Json
        }
        
        .\Set-SearchIndexers @DefaultParams

        Assert-MockCalled Get-AzureRmResource -Scope It -Exactly 1
        Assert-MockCalled Invoke-AzureRmResourceAction -Scope It -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'GET' } -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'POST' } -Exactly 0

    }

    It "Ensure Set-SearchIndexers calls ApiReqest twice (1x GET, 1x POST) if datasource does not exist" {

        # GET will throw a 404 if not found
        Mock ApiRequest -ParameterFilter { $Method -eq 'GET' } -MockWith {
            throw
        }
        
        .\Set-SearchIndexers @DefaultParams

        Assert-MockCalled Get-AzureRmResource -Scope It -Exactly 1
        Assert-MockCalled Invoke-AzureRmResourceAction -Scope It -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'GET' } -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'POST' } -Exactly 1

    }

    # Change default params to read from file
    $DefaultParams.Remove('IndexConfigurationString') # clean up
    $DefaultParams['IndexFilePath'] = "$TestDrive\Mock.json"
    
    It "Ensure Set-SearchIndexers can read the JSON from a file" {

        Set-Content -Path $DefaultParams.IndexFilePath -Value $SampleDatasource

        # GET will throw a 404 if not found
        Mock ApiRequest -ParameterFilter { $Method -eq 'GET' } -MockWith {
            throw
        }
                
        .\Set-SearchIndexers @DefaultParams
        
        Assert-MockCalled Get-AzureRmResource -Scope It -Exactly 1
        Assert-MockCalled Invoke-AzureRmResourceAction -Scope It -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'GET' } -Exactly 1
        Assert-MockCalled ApiRequest -Scope It -ParameterFilter { $Method -eq 'POST' } -Exactly 1
        
    }

}

Push-Location -Path $PSScriptRoot