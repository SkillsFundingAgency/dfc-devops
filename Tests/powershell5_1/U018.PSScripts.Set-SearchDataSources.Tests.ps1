Push-Location -Path $PSScriptRoot\..\..\PSScripts\
Import-Module $PSScriptRoot\..\..\PSModules\AzureApiFunctions

# solves CommandNotFoundException
function Get-AzureRmResource {}
function Invoke-AzureRmResourceAction {}

Describe "Set-SearchDatasources unit tests" -Tag "Unit" {

    BeforeEach {
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
    "type" : "documentdb",
    "description": "mock datasource",
    "credentials" : { "connectionString": "mock" }
} ]
'@

        $DefaultParams = @{ 
            SearchName        = 'mock'
            ResourceGroupName = "dfc-foo-bar-rg"
        }

    }
    # This test will write to the error stream
    It "Ensure Set-SearchDatasources throws an error if the JSON is invalid" {

        $DefaultParams['IndexConfigurationString'] = '{ "invalid: "json" }' # missing quote after invalid

        { .\Set-SearchDatasources @DefaultParams } | Should -Throw

        $DefaultParams.Remove('IndexConfigurationString') # clean up
    }


    It "Ensure Set-SearchDatasources only calls ApiReqest once (GET only) if datasource exists" {

        # Pass in a valid JSON for the rest of the tests
        $DefaultParams['IndexConfigurationString'] = $SampleDatasource

        # GET will return the datasource if it exists
        Mock ApiRequest -ParameterFilter { $Method -eq 'GET' } -MockWith {
            return $SampleDatasource | ConvertFrom-Json
        }
        
        .\Set-SearchDatasources @DefaultParams

        Should -Invoke -CommandName Get-AzureRmResource -Scope It -Exactly 1
        Should -Invoke -CommandName Invoke-AzureRmResourceAction -Scope It -Exactly 1
        Should -Invoke -CommandName ApiRequest -Scope It -ParameterFilter { $Method -eq 'GET' } -Exactly 1
        Should -Invoke -CommandName ApiRequest -Scope It -ParameterFilter { $Method -eq 'POST' } -Exactly 0

    }

    It "Ensure Set-SearchDatasources calls ApiReqest twice (1x GET, 1x POST) if datasource does not exist" {

        # Pass in a valid JSON for the rest of the tests
        $DefaultParams['IndexConfigurationString'] = $SampleDatasource

        # GET will throw a 404 if not found
        Mock ApiRequest -ParameterFilter { $Method -eq 'GET' } -MockWith {
            throw
        }
        
        .\Set-SearchDatasources @DefaultParams

        Should -Invoke -CommandName Get-AzureRmResource -Scope It -Exactly 1
        Should -Invoke -CommandName Invoke-AzureRmResourceAction -Scope It -Exactly 1
        Should -Invoke -CommandName ApiRequest -Scope It -ParameterFilter { $Method -eq 'GET' } -Exactly 1
        Should -Invoke -CommandName ApiRequest -Scope It -ParameterFilter { $Method -eq 'POST' } -Exactly 1

    }

    
    It "Ensure Set-SearchDatasources can read the JSON from a file" {

        # Change default params to read from file
        $DefaultParams['IndexFilePath'] = "$TestDrive\Mock.json"

        Set-Content -Path $DefaultParams.IndexFilePath -Value $SampleDatasource

        # GET will throw a 404 if not found
        Mock ApiRequest -ParameterFilter { $Method -eq 'GET' } -MockWith {
            throw
        }
                
        .\Set-SearchDatasources @DefaultParams
        
        Should -Invoke -CommandName Get-AzureRmResource -Scope It -Exactly 1
        Should -Invoke -CommandName Invoke-AzureRmResourceAction -Scope It -Exactly 1
        Should -Invoke -CommandName ApiRequest -Scope It -ParameterFilter { $Method -eq 'GET' } -Exactly 1
        Should -Invoke -CommandName ApiRequest -Scope It -ParameterFilter { $Method -eq 'POST' } -Exactly 1
        
    }

}

Push-Location -Path $PSScriptRoot