Push-Location -Path $PSScriptRoot\..\..\PSScripts\

Import-Module ..\PSModules\AzureApiFunctions

Describe "ApiRequest unit tests" -Tag "Unit" {

    BeforeAll {
        Mock -ModuleName AzureApiFunctions Invoke-WebRequest { 
            return @{
                StatusCode = 200
                Content    = '{ "result": "Success" }'
            }
        }

        $RequestParams = @{ 
            Method = 'GET'
            Url    = "https://api.mydomain.com/endpoint"
            ApiKey = "Mock123"
        }
    }

    It "Check ApiRequest passes the Content-Type" {

        ApiRequest @RequestParams

        Should -Invoke -CommandName Invoke-WebRequest -ModuleName AzureApiFunctions -ParameterFilter {
            $Headers['Content-Type'] -eq "application/json"
        }

    }
    It "Check ApiRequest passes the api-key headers" {

        ApiRequest @RequestParams

        Should -Invoke -CommandName  Invoke-WebRequest -ModuleName AzureApiFunctions -ParameterFilter {
            $Headers['api-key'] -eq "Mock123"
        }

    }

    It "Check ApiRequest converts from JSON" {

        $result = ApiRequest @RequestParams

        $result.result | Should -Be "Success"

    }

    It "Check ApiRequest does not pass the body in if not body specified" {

        $bodypayload = '{ "foo": "bar" }'
        $JsonBody = $bodypayload | ConvertTo-Json -Depth 10

        ApiRequest @RequestParams

        Should -Invoke -CommandName Invoke-WebRequest -ModuleName AzureApiFunctions -Exactly 0 -ParameterFilter {
            $Body -eq $JsonBody
        }
    }

    It "Check ApiRequest passes the body if added" {

        $bodypayload = '{ "foo": "bar" }'
        $RequestParams['Body'] = $bodypayload
        $JsonBody = $bodypayload | ConvertTo-Json -Depth 10

        ApiRequest @RequestParams

        Should -Invoke -CommandName Invoke-WebRequest -ModuleName AzureApiFunctions -Exactly 1 -ParameterFilter {
            $Body -eq $JsonBody
        }
    }

}

