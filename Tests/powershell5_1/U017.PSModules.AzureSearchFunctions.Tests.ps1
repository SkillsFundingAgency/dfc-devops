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

    It "Check ApiRequest passes the Content-Type abd api-key headers" {

        ApiRequest @RequestParams

        Should -Invoke -CommandName -ModuleName AzureApiFunctions Invoke-WebRequest -ParameterFilter {
            $Headers['Content-Type'] -eq "application/json"
        }
        Should -Invoke -CommandName -ModuleName AzureApiFunctions Invoke-WebRequest -ParameterFilter {
            $Headers['api-key'] -eq "Mock123"
        }

    }

    It "Check ApiRequest converts from JSON" {

        $result = ApiRequest @RequestParams

        $result.result | Should -Be "Success"

    }

    It "Check ApiRequest does not pass the body in if not body specified" {

        ApiRequest @RequestParams

        Should -Invoke -CommandName -ModuleName AzureApiFunctions Invoke-WebRequest -Exactly 0 -ParameterFilter {
            $Body
        }
    }

    It "Check ApiRequest passes the body if added" {

        $bodypayload = '{ "foo": "bar" }'
        $RequestParams['Body'] = $bodypayload

        ApiRequest @RequestParams

        Should -Invoke -CommandName -ModuleName AzureApiFunctions Invoke-WebRequest -ParameterFilter {
            $Body
        }
    }

}