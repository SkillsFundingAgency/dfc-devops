Push-Location -Path $PSScriptRoot\..\PSScripts\

Import-Module $PSScriptRoot\..\PSModules\CompositeRegistrationFunctions -Force

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
    }

    Describe "Update-PathRegistration" -Tag "Unit" {
        New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api -ApiKey SomeApiKey
        Mock Invoke-CompositeApiRegistrationRequest 
        Mock ConvertTo-Json 
    
        Update-PathRegistration -Path SomePath -ItemsToUpdate @{ }

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
    
        Update-RegionRegistration -Path SomePath -PageRegion 5 -ItemsToUpdate @{}

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
    
    Describe "Get-DifferencesBetweenDefinitionAndCurrent" -Tag "Unit" {

        $mockApiResult = New-Object PSObject -Property @{
            "Path" = "SomePath"
            "TopNavigationText" = "Navigation Text"
            "TopNagivationOrder" = 200
            "Layout" = 4
            "IsOnline" = $true
            "OfflineHtml" = "Some offline html"
            "PhaseBannerHtml" = "Banner html"
            "ExternalUrl" = "https://some-website/"
            "SitemapURL" = "https://some-website/sitemap.xml"
            "RobotsURL" = "https://some-website/robots.txt"
        }

        Context "When the objects are identical" {
            $mockFileResult = New-Object PSObject -Property @{
                "Path" = "SomePath"
                "TopNavigationText" = "Navigation Text"
                "TopNagivationOrder" = 200
                "Layout" = 4
                "IsOnline" = $true
                "OfflineHtml" = "Some offline html"
                "PhaseBannerHtml" = "Banner html"
                "ExternalUrl" = "https://some-website/"
                "SitemapURL" = "https://some-website/sitemap.xml"
                "RobotsURL" = "https://some-website/robots.txt"
            }

            $differences = Get-DifferencesBetweenDefinitionAndCurrent -Definition $mockFileResult -Current $mockApiResult

            It "should not return any item" {
                $differences.Count | Should Be 0
            }
        }

        Context "When the objects are different" {
            $mockFileResult = New-Object PSObject -Property @{
                "Path" = "SomePath"
                "TopNavigationText" = "Different Navigation Text"
                "TopNagivationOrder" = 400
                "Layout" = 3
                "IsOnline" = $false
                "OfflineHtml" = "Different offline html"
                "PhaseBannerHtml" = "Different Banner html"
                "ExternalUrl" = "https://another-website/"
                "SitemapURL" = "https://another-website/sitemap.xml"
                "RobotsURL" = "https://another-website/robots.txt"
            }

            $differences = Get-DifferencesBetweenDefinitionAndCurrent -Definition $mockFileResult -Current $mockApiResult

            It "should return an item per difference" {
                $differences.Count | Should Be 9
            }

            It "should mark the top navigation text field as being changed" {
                $differences.value -contains "Different Navigation Text" | Should Be $true
            }
            It "should mark the top navigation order field as being changed" {
                $differences.value -contains 400 | Should Be $true
            }

            It "should mark the layout field as being changed" {
                $differences.value -contains 3 | Should Be $true
            }

            It "should mark the IsOnline field as being changed" {
                $differences.value -contains $false | Should Be $true
            }

            It "should mark the OfflineHtml field as being changed" {
                $differences.value -contains "Different offline html" | Should Be $true
            }

            It "should mark the PhaseBannerHtml field as being changed" {
                $differences.value -contains "Different Banner html" | Should Be $true
            }
            
            It "should mark the ExternalUrl field as being changed" {
                $differences.value -contains "https://another-website/" | Should Be $true
            }
            It "should mark the SitemapURL field as being changed" {
                $differences.value -contains "https://another-website/sitemap.xml" | Should Be $true
            }
            It "should mark the RobotsURL field as being changed" {
                $differences.value -contains "https://another-website/robots.txt" | Should Be $true
            }
        }
    }
}

Pop-Location