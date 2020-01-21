Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Import-Module ..\PSModules\CompositeRegistrationFunctions -Force

InModuleScope CompositeRegistrationFunctions {
    Describe "Invoke-CompositeApiRegistrationRequest" -Tag "Unit" {
    
        Context "When  performing a request that throws a 4xx or 5xx status code" {
            Mock Invoke-WebRequest -MockWith { throw "an error status code" }

            It "should throw an exception" {
                {
                    Invoke-CompositeApiRegistrationRequest -Url https://some/api -Method Get
                } | Should throw "an error status code"
            }        
        }

        Context "When performing a GET request and the API returns a 204" {

            Mock Invoke-WebRequest -MockWith { return @{ StatusCode = 204 } }

            $script:ApiKey = "SomeApiKey"
            $result = Invoke-CompositeApiRegistrationRequest -Url https://some/api -Method Get

            It "should return null" {
                $result | Should Be $null
            }

            it "should correctly call Invoke-WebRequest" {
                Assert-MockCalled  Invoke-WebRequest -Exactly 1 -ParameterFilter {
                    $Uri -eq "https://some/api" -and `
                    $Method -eq "Get" -and `
                    $UseBasicParsing -eq $true -and `
                    $Headers["Ocp-Apim-Subscription-Key"] -eq "SomeApiKey"
                }
            }
        }

        Context "When performing a GET request"  {
            Mock Invoke-WebRequest -MockWith { return @{
                    StatusCode = 200
                    Content = "{ ""message"": ""some message"" }" 
                }
            }

            $script:ApiKey = "SomeApiKey"
            $result = Invoke-CompositeApiRegistrationRequest -Url https://some/api -Method Get

            It "should deserialize the returned content" {
                $result.message | Should Be "some message"
            }

            it "should correctly call Invoke-WebRequest" {
                Assert-MockCalled  Invoke-WebRequest -Exactly 1 -ParameterFilter {
                    $Uri -eq "https://some/api" -and `
                    $Method -eq "Get" -and `
                    $UseBasicParsing -eq $true -and `
                    $Headers["Ocp-Apim-Subscription-Key"] -eq "SomeApiKey"
                }
            }
        }

        Context "When performing a POST request and the api does not return a 201 status code"  {
            Mock Invoke-WebRequest -MockWith { return @{
                    StatusCode = 204
                }
            }

            $script:ApiKey = "SomeApiKey"
            $result = Invoke-CompositeApiRegistrationRequest -Url https://some/api -Method Post

            It "should return null" {
                $result | Should Be $null
            }

            It "should correctly call Invoke-WebRequest" {
                Assert-MockCalled  Invoke-WebRequest -Exactly 1 -ParameterFilter {
                    $Uri -eq "https://some/api" -and `
                    $Method -eq "Post" -and `
                    $UseBasicParsing -eq $true -and `
                    $Headers["Ocp-Apim-Subscription-Key"] -eq "SomeApiKey" -and `
                    $Headers["Content-Type"] -eq "application/json"
                }
            }
        }

        Context "When performing a POST request and the api returns a 201 status code"  {
            Mock Invoke-WebRequest -MockWith { return @{
                    StatusCode = 201
                    Content = "{ ""message"": ""some message"" }" 
                }
            }

            $script:ApiKey = "SomeApiKey"
            $result = Invoke-CompositeApiRegistrationRequest -Url https://some/api -Method Post

            It "should return deserialise the returned content" {
                $result.message | Should Be "some message"
            }

            It "should correctly call Invoke-WebRequest" {
                Assert-MockCalled  Invoke-WebRequest -Exactly 1 -ParameterFilter {
                    $Uri -eq "https://some/api" -and `
                    $Method -eq "Post" -and `
                    $UseBasicParsing -eq $true -and `
                    $Headers["Ocp-Apim-Subscription-Key"] -eq "SomeApiKey" -and `
                    $Headers["Content-Type"] -eq "application/json"
                }
            }
        }

        Context "When performing a PATCH request and the api does not return a 200 status code"  {
            Mock Invoke-WebRequest -MockWith { return @{
                    StatusCode = 204
                }
            }

            $script:ApiKey = "SomeApiKey"
            $result = Invoke-CompositeApiRegistrationRequest -Url https://some/api -Method Patch

            It "should return null" {
                $result | Should Be $null
            }

            It "should correctly call Invoke-WebRequest" {
                Assert-MockCalled  Invoke-WebRequest -Exactly 1 -ParameterFilter {
                    $Uri -eq "https://some/api" -and `
                    $Method -eq "Patch" -and `
                    $UseBasicParsing -eq $true -and `
                    $Headers["Ocp-Apim-Subscription-Key"] -eq "SomeApiKey" -and `
                    $Headers["Content-Type"] -eq "application/json"
                }
            }
        }

        Context "When performing a PATCH request and the api returns a 200 status code"  {
            Mock Invoke-WebRequest -MockWith { return @{
                    StatusCode = 200
                    Content = "{ ""message"": ""some message"" }" 
                }
            }

            $script:ApiKey = "SomeApiKey"
            $result = Invoke-CompositeApiRegistrationRequest -Url https://some/api -Method Patch

            It "should return deserialise the returned content" {
                $result.message | Should Be "some message"
            }

            It "should correctly call Invoke-WebRequest" {
                Assert-MockCalled  Invoke-WebRequest -Exactly 1 -ParameterFilter {
                    $Uri -eq "https://some/api" -and `
                    $Method -eq "Patch" -and `
                    $UseBasicParsing -eq $true -and `
                    $Headers["Ocp-Apim-Subscription-Key"] -eq "SomeApiKey" -and `
                    $Headers["Content-Type"] -eq "application/json"
                }
            }
        }
    }

    Describe "Get-PathRegistration" -Tag "Unit" {        
        Context "When getting a path registration" {
            New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api -ApiKey SomeApiKey

            Mock Invoke-CompositeApiRegistrationRequest 
            
            Get-PathRegistration -Path SomePath

            It "should invoke a composite api registration request" {
                Assert-MockCalled Invoke-CompositeApiRegistrationRequest -ParameterFilter {
                    $Url -eq "https://path-api/api/paths/SomePath" -and
                    $Method -eq "Get"
                }
            }
        }
    }


    Describe "Get-RegionRegistration" -Tag "Unit" {        
        Context "When getting a region registration" {
            New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api -ApiKey SomeApiKey

            Mock Invoke-CompositeApiRegistrationRequest 
            
            Get-RegionRegistration -Path SomePath -PageRegion 1

            It "should invoke a composite api registration request" {
                Assert-MockCalled Invoke-CompositeApiRegistrationRequest -ParameterFilter {
                    $Url -eq "https://region-api/api/paths/SomePath/regions/1" -and
                    $Method -eq "Get"
                }
            }
        }
    } 

    Describe "New-PathRegistration" -Tag "Unit" {
        Context "When the path is not specified" {
            It "should throw an error" {
                {
                    New-PathRegistration -Path @{}
                } | Should throw "Path not specified"
            }
        }

        Context "When the layout is not specified" {
            It "should throw an error" {
                {
                    New-PathRegistration -Path @{ Path = "SomePath"}
                } | Should throw "Layout is mandatory when creating a page registration."
            }
        }

        Context "When creating a new path registration" {
            New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api -ApiKey SomeApiKey
            Mock Invoke-CompositeApiRegistrationRequest 
            Mock ConvertTo-Json 

            New-PathRegistration -Path @{ 
                Path = "SomePath" 
                Layout = 1
            }

            It "should serialize the object" { 
                Assert-MockCalled ConvertTo-Json -Exactly 1
            }

            It "should invoke a composite api registration request" {
                Assert-MockCalled Invoke-CompositeApiRegistrationRequest -Exactly 1 -ParameterFilter {
                    $Url -eq "https://path-api/api/paths" -and `
                    $Method -eq "Post"
                }
            }
        }

        Context "When creating a new path registration with optional fields" {
            New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api -ApiKey SomeApiKey
            Mock Invoke-CompositeApiRegistrationRequest
            Mock ConvertTo-Json

            It "should not include any optional by default" {
                New-PathRegistration -Path @{
                    Path = "SomePath"
                    Layout = 1
                }

                Assert-MockCalled ConvertTo-Json -Scope It -ParameterFilter {
                    $InputObject.Keys.Count | Should Be 2
                    $InputObject.Contains("Path")
                    $InputObject.Contains("Layout")
                }
            }

            It "should include the optional TopNavigationText field when specified" {
                New-PathRegistration -Path @{
                    Path = "SomePath"
                    Layout = 1
                    TopNavigationText = "Some Text"
                }

                Assert-MockCalled ConvertTo-Json -Scope It -ParameterFilter {
                    $InputObject.Keys.Count | Should Be 3
                    $InputObject.Contains("Path")
                    $InputObject.Contains("Layout")
                    $InputObject.Contains("TopNavigationText")
                }
            }

            It "should include the optional TopNavigationOrder field when specified" {
                New-PathRegistration -Path @{
                    Path = "SomePath"
                    Layout = 1
                    TopNavigationOrder = "Some Text"
                }

                Assert-MockCalled ConvertTo-Json -Scope It -ParameterFilter {
                    $InputObject.Keys.Count | Should Be 3
                    $InputObject.Contains("Path")
                    $InputObject.Contains("Layout")
                    $InputObject.Contains("TopNavigationOrder")
                }
            }

            It "should include the optional OfflineHtml field when specified" {
                New-PathRegistration -Path @{
                    Path = "SomePath"
                    Layout = 1
                    OfflineHtml = "Some HTML"
                }

                Assert-MockCalled ConvertTo-Json -Scope It -ParameterFilter {
                    $InputObject.Keys.Count | Should Be 3
                    $InputObject.Contains("Path")
                    $InputObject.Contains("Layout")
                    $InputObject.Contains("OfflineHtml")
                }
            }

            It "should include the optional PhaseBannerHtml field when specified" {
                New-PathRegistration -Path @{
                    Path = "SomePath"
                    Layout = 1
                    PhaseBannerHtml = "Some HTML"
                }

                Assert-MockCalled ConvertTo-Json -Scope It -ParameterFilter {
                    $InputObject.Keys.Count | Should Be 3
                    $InputObject.Contains("Path")
                    $InputObject.Contains("Layout")
                    $InputObject.Contains("PhaseBannerHtml")
                }
            }

            It "should include the optional ExternalUrl field when specified" {
                New-PathRegistration -Path @{
                    Path = "SomePath"
                    Layout = 1
                    ExternalUrl = "https://some/url"
                }

                Assert-MockCalled ConvertTo-Json -Scope It -ParameterFilter {
                    $InputObject.Keys.Count | Should Be 3
                    $InputObject.Contains("Path")
                    $InputObject.Contains("Layout")
                    $InputObject.Contains("ExternalUrl")
                }
            }

            It "should include the optional SitemapUrl field when specified" {
                New-PathRegistration -Path @{
                    Path = "SomePath"
                    Layout = 1
                    SitemapUrl = "https://some/url"
                }

                Assert-MockCalled ConvertTo-Json -Scope It -ParameterFilter {
                    $InputObject.Keys.Count | Should Be 3
                    $InputObject.Contains("Path")
                    $InputObject.Contains("Layout")
                    $InputObject.Contains("SitemapUrl")
                }
            }

            It "should include the optional RobotsUrl field when specified" {
                New-PathRegistration -Path @{
                    Path = "SomePath"
                    Layout = 1
                    RobotsUrl = "https://some/url"
                }

                Assert-MockCalled ConvertTo-Json -Scope It -ParameterFilter {
                    $InputObject.Keys.Count | Should Be 3
                    $InputObject.Contains("Path")
                    $InputObject.Contains("Layout")
                    $InputObject.Contains("RobotsUrl")
                }
            }
        }
    }

    Describe "New-RegionRegistration" -Tag "Unit" {
        Context "When the path is not specified" {
            It "should throw an error" {
                {
                    New-RegionRegistration -Path SomePath -Region @{}
                } | Should throw "PageRegion is not set for a region on path SomePath"
            }
        }

        Context "When creating a new region registration" {
            New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api -ApiKey SomeApiKey
            Mock Invoke-CompositeApiRegistrationRequest
            Mock ConvertTo-Json 

            New-RegionRegistration -Path SomePath -Region @{  PageRegion = 5 }

            It "should serialize the object" { 
                Assert-MockCalled ConvertTo-Json -Exactly 1
            }

            It "should invoke a composite api registration request" {
                Assert-MockCalled Invoke-CompositeApiRegistrationRequest -Exactly 1 -ParameterFilter {
                    $Url -eq "https://region-api/api/paths/SomePath/regions" -and `
                    $Method -eq "Post"
                }
            }
        }

        Context "When creating a new region registration with optional fields" {
            New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api -ApiKey SomeApiKey
            Mock Invoke-CompositeApiRegistrationRequest
            Mock ConvertTo-Json

            It "should not include any optional fields by default" {
                New-RegionRegistration -Path SomePath -Region @{  PageRegion = 5 }

                Assert-MockCalled ConvertTo-Json -Scope It -ParameterFilter {
                    $InputObject.Keys.Count | Should Be 2
                    $InputObject.Contains("Path")
                    $InputObject.Contains("PageRegion")
                }
            }

            It "should include the RegionEndpoint optional field when specified" {
                New-RegionRegistration -Path SomePath -Region @{  PageRegion = 5; RegionEndpoint = "SomeEndpoint" }

                Assert-MockCalled ConvertTo-Json -Scope It -ParameterFilter {
                    $InputObject.Keys.Count | Should Be 3
                    $InputObject.Contains("Path")
                    $InputObject.Contains("PageRegion")
                    $InputObject.Contains("RegionEndpoint")
                }
            }

            It "should include the HealthCheckRequired optional field when specified" {
                New-RegionRegistration -Path SomePath -Region @{  PageRegion = 5; HealthCheckRequired = $false }

                Assert-MockCalled ConvertTo-Json -Scope It -ParameterFilter {
                    $InputObject.Keys.Count | Should Be 3
                    $InputObject.Contains("Path")
                    $InputObject.Contains("PageRegion")
                    $InputObject.Contains("HealthCheckRequired")
                }
            }

            It "should include the OfflineHtml optional field when specified" {
                New-RegionRegistration -Path SomePath -Region @{  PageRegion = 5; OfflineHtml = "Some mark-up" }

                Assert-MockCalled ConvertTo-Json -Scope It -ParameterFilter {
                    $InputObject.Keys.Count | Should Be 3
                    $InputObject.Contains("Path")
                    $InputObject.Contains("PageRegion")
                    $InputObject.Contains("OfflineHtml")
                }
            }
        }
    }

    Describe "Update-PathRegistration" -Tag "Unit" {
        New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api -ApiKey SomeApiKey
        Mock Invoke-CompositeApiRegistrationRequest 
        Mock ConvertTo-Json 
    
        Update-PathRegistration -Path SomePath -ItemsToPatch @{ }

        It "should serialize the objects to update" { 
            Assert-MockCalled ConvertTo-Json -Exactly 1            
        }

        It "should invoke a composite api registration request" {
            Assert-MockCalled Invoke-CompositeApiRegistrationRequest -Exactly 1 -ParameterFilter {
                $Url -eq "https://path-api/api/paths/SomePath" -and `
                $Method -eq "Patch"
            }
        }
    }

    Describe "Update-RegionRegistration" -Tag "Unit" {
        New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api -ApiKey SomeApiKey
        Mock Invoke-CompositeApiRegistrationRequest 
        Mock ConvertTo-Json 
    
        Update-RegionRegistration -Path SomePath -PageRegion 5 -ItemsToPatch @{}

        It "should serialize the objects to update" { 
            Assert-MockCalled ConvertTo-Json -Exactly 1            
        }

        It "should invoke a composite api registration request" {
            Assert-MockCalled Invoke-CompositeApiRegistrationRequest -Exactly 1 -ParameterFilter {
                $Url -eq "https://region-api/api/paths/SomePath/regions/5" -and `
                $Method -eq "Patch"
            }
        }
    }

    Describe "Get-PatchDocuments" -Tag "Unit" {
        Context "When generating properties and the values are equal" {
            It "should not create any patch documents" {
                $original = @{ "Property1" = "AValue" }
                $replacement = @{ "Property1" = "AValue" }

                $result = Get-PatchDocuments -OriginalValues $original -ReplacementValues $replacement

                $result.Count | Should Be 0
            }
        }

        Context "When patching properties and the value does not exist in the original collection" {
            It "should create an add document for a property" {
                $result = Get-PatchDocuments -OriginalValues @{ } -ReplacementValues @{ "TestProp" = "AnotherValue"}

                $result.Count | Should Be 1

                $result[0].op | Should Be "add"
                $result[0].path | Should Be "/TestProp"
                $result[0].value | Should Be "AnotherValue"
            }
        }

        Context "When generating properties and the value exists in the original collection, but differs" {
            It "should create a replace document for a property" {
                $result = Get-PatchDocuments -OriginalValues @{ "TestProp" = "OriginalValue" } -ReplacementValues @{ "TestProp" = "UpdatedValue" }

                $result.Count | Should Be 1

                $result[0].op | Should Be "replace"
                $result[0].path | Should Be "/TestProp"
                $result[0].value | Should Be "UpdatedValue"
            }
        }

        Context "When patching multiple properties" {
            It "should create a patch document for each property" {
                $result = Get-PatchDocuments -OriginalValues @{ } -ReplacementValues @{
                    "TestPropOne" = "UpdatedValue"
                    "TestPropTwo" = "AnotherValue"
                    "TestPropThree" = "ThirdValue"
                }

                $result.Count | Should be 3
            }
        }
    }

    Describe "ConvertTo-Hashtable" -Tag "Unit" {
        Context "When converting an object to a hashtable" {

            $customObject = [PSCustomObject]@{
                StringProperty = "SomeValue"
                IntProperty = 5
                BoolProperty = $true
                NullProperty = $null
                ArrayProperty = @()
                ObjectProperty = [PSCustomObject]@{}
            }

            $result = ConvertTo-Hashtable -Object $customObject

            It "should return a hashtable" {
                $result.GetType() | Should be "hashtable"
            }

            It "should convert properties" {
                $result.Keys.Count| Should be 6

                $result.Contains("StringProperty") | Should be $true
                $result.Contains("IntProperty") | Should be $true
                $result.Contains("BoolProperty") | Should be $true
                $result.Contains("NullProperty") | Should be $true
                $result.Contains("ArrayProperty") | Should be $true
                $result.Contains("ObjectProperty") | Should be $true
            }
        }
    }
}

Pop-Location