Push-Location -Path $PSScriptRoot\..\PSScripts\

Import-Module $PSScriptRoot\..\PSModules\CompositeRegistrationFunctions -Force

InModuleScope CompositeRegistrationFunctions {
    Describe "Invoke-CompositeApiRegistrationRequest" -Tag "Unit" {
    
        Context "When  performing  a request that throws a 4xx or 5xx status code" {
            Mock Invoke-WebRequest -MockWith { throw "an error status code" }

            It "should throw an exception" {
                {
                    Invoke-CompositeApiRegistrationRequest -Url https://some/api -Method Get
                } | Should throw "an error status code"
            }        
        }

        Context "When performing a GET request and the API returns a 204" {

            Mock Invoke-WebRequest -MockWith { return @{ StatusCode = 204 } }

            $result = Invoke-CompositeApiRegistrationRequest -Url https://some/api -Method Get

            It "should return null" {
                $result | Should Be $null
            }

            it "should correctly call Invoke-WebRequest" {
                Assert-MockCalled  Invoke-WebRequest -Exactly 1 -ParameterFilter {
                    $Uri -eq "https://some/api" -and `
                    $Method -eq "Get" -and `
                    $UseBasicParsing -eq $true
                }
            }
        }

        Context "When performing a GET request"  {
            Mock Invoke-WebRequest -MockWith { return @{
                    StatusCode = 200
                    Content = "{ ""message"": ""some message"" }" 
                }
            }

            $result = Invoke-CompositeApiRegistrationRequest -Url https://some/api -Method Get

            It "should deserialize the returned content" {
                $result.message | Should Be "some message"
            }

            it "should correctly call Invoke-WebRequest" {
                Assert-MockCalled  Invoke-WebRequest -Exactly 1 -ParameterFilter {
                    $Uri -eq "https://some/api" -and `
                    $Method -eq "Get" -and `
                    $UseBasicParsing -eq $true
                }
            }            
        }

        Context "When performing a POST request and the api does not return a 201 status code"  {
            Mock Invoke-WebRequest -MockWith { return @{
                    StatusCode = 204
                }
            }

            $result = Invoke-CompositeApiRegistrationRequest -Url https://some/api -Method Post

            It "should return null" {
                $result | Should Be $null
            }

            It "should correctly call Invoke-WebRequest" {
                Assert-MockCalled  Invoke-WebRequest -Exactly 1 -ParameterFilter {
                    $Uri -eq "https://some/api" -and `
                    $Method -eq "Post" -and `
                    $UseBasicParsing -eq $true
                }
            }
        }

        Context "When performing a POST request and the api returns a 201 status code"  {
            Mock Invoke-WebRequest -MockWith { return @{
                    StatusCode = 201
                    Content = "{ ""message"": ""some message"" }" 
                }
            }

            $result = Invoke-CompositeApiRegistrationRequest -Url https://some/api -Method Post

            It "should return deserialise the returned content" {
                $result.message | Should Be "some message"
            }

            It "should correctly call Invoke-WebRequest" {
                Assert-MockCalled  Invoke-WebRequest -Exactly 1 -ParameterFilter {
                    $Uri -eq "https://some/api" -and `
                    $Method -eq "Post" -and `
                    $UseBasicParsing -eq $true
                }
            }
        }

        Context "When performing a PATCH request and the api does not return a 200 status code"  {
            Mock Invoke-WebRequest -MockWith { return @{
                    StatusCode = 204
                }
            }

            $result = Invoke-CompositeApiRegistrationRequest -Url https://some/api -Method Patch

            It "should return null" {
                $result | Should Be $null
            }

            It "should correctly call Invoke-WebRequest" {
                Assert-MockCalled  Invoke-WebRequest -Exactly 1 -ParameterFilter {
                    $Uri -eq "https://some/api" -and `
                    $Method -eq "Patch" -and `
                    $UseBasicParsing -eq $true
                }
            }
        }

        Context "When performing a PATCH request and the api returns a 200 status code"  {
            Mock Invoke-WebRequest -MockWith { return @{
                    StatusCode = 200
                    Content = "{ ""message"": ""some message"" }" 
                }
            }

            $result = Invoke-CompositeApiRegistrationRequest -Url https://some/api -Method Patch

            It "should return deserialise the returned content" {
                $result.message | Should Be "some message"
            }

            It "should correctly call Invoke-WebRequest" {
                Assert-MockCalled  Invoke-WebRequest -Exactly 1 -ParameterFilter {
                    $Uri -eq "https://some/api" -and `
                    $Method -eq "Patch" -and `
                    $UseBasicParsing -eq $true
                }
            }
        }
    }

    Describe "Get-PathRegistration" -Tag "Unit" {        
        Context "When getting a path registration" {
            New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api

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
            New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api

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
            New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api
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
            New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api
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
        New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api
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
        New-RegistrationContext -PathApiUrl https://path-api/api -RegionApiUrl https://region-api/api
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
    
    Describe "Get-DifferencesBetweenPathObjects" -Tag "Unit" {

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

        Context "When the file object does not contain a Path" {
            {
                Get-DifferencesBetweenPathObjects -ObjectFromApi $mockApiResult -ObjectFromFile @{}
            } | Should Throw "Path not specified"
        }

        Context "When the file object does not contain a Layout" {
            {
                Get-DifferencesBetweenPathObjects -ObjectFromApi $mockApiResult -ObjectFromFile @{ Path = "SomePath"}
            } | Should Throw "Layout is mandatory when creating a path registration for path 'SomePath'."
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

            $differences = Get-DifferencesBetweenPathObjects -ObjectFromApi $mockApiResult -ObjectFromFile $mockFileResult

            It "should only return 1 item" {
                $differences.Count | Should Be 1
            }

            It "should return the Page name" { 
                $differences.Path | Should Be "SomePath"
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

            $differences = Get-DifferencesBetweenPathObjects -ObjectFromApi $mockApiResult -ObjectFromFile $mockFileResult

            It "should return an item per difference" {
                $differences.Count | Should Be 10
            }

            It "should return the Page name" { 
                $differences.Path | Should Be "SomePath"
            }

            It "should mark the top navigation text field as being changed" {
                $differences.TopNavigationText | Should be "Different Navigation Text"                
            }
            It "should mark the top navigation order field as being changed" {
                $differences.TopNavigationOrder | Should be 400
            }

            It "should mark the layout field as being changed" {
                $differences.Layout | Should be 3
            }

            It "should mark the IsOnline field as being changed" {
                $differences.IsOnline | Should be $false
            }

            It "should mark the OfflineHtml field as being changed" {
                $differences.OfflineHtml | Should be "Different offline html"
            }

            It "should mark the PhaseBannerHtml field as being changed" {
                $differences.PhaseBannerHtml | Should be "Different Banner html"
            }
            
            It "should mark the ExternalUrl field as being changed" {
                $differences.ExternalUrl | Should be "https://another-website/"
            }
            It "should mark the SitemapURL field as being changed" {
                $differences.SitemapURL | Should be "https://another-website/sitemap.xml"
            }
            It "should mark the RobotsURL field as being changed" {
                $differences.RobotsURL | Should be "https://another-website/robots.txt"
            }
        }
    }


    Describe "Get-DifferencesBetweenRegionObjects" -Tag "Unit" {

        $mockApiResult = New-Object PSObject -Property @{
            "Path" = "SomePath"
            "PageRegion" = 1
            "IsHealthy" = $false
            "RegionEndpoint" = "https://some-region-endpoint/pathOne"
            "HealthCheckRequired" = $false
            "OfflineHTML" = "SomeOfflineHtml"            
        }

        Context "When the file object does not contain a page region" {
            {
                Get-DifferencesBetweenRegionObjects -ObjectFromApi $mockApiResult -ObjectFromFile @{}
            } | Should Throw "PageRegion is not set and is required"
        }

        Context "When the objects are identical" {
            $mockFileResult = New-Object PSObject -Property @{
                "PageRegion" = 1
                "IsHealthy" = $false
                "RegionEndpoint" = "https://some-region-endpoint/pathOne"
                "HealthCheckRequired" = $false
                "OfflineHTML" = "SomeOfflineHtml"
            }

            $differences = Get-DifferencesBetweenRegionObjects -ObjectFromApi $mockApiResult -ObjectFromFile $mockFileResult

            It "should only return two items" {
                $differences.Count | Should Be 2
            }

            It "should return the Path" {
                $differences.Path | Should Be "SomePath"
            }

            It "should return the Page Region" { 
                $differences.PageRegion | Should Be 1
            }
        }

        Context "When the objects are different" {
            $mockFileResult = New-Object PSObject -Property @{
                "PageRegion" = 1
                "IsHealthy" = $true
                "RegionEndpoint" = "https://some-region-endpoint/pathTwo"
                "HealthCheckRequired" = $true
                "OfflineHTML" = "Different Offline Html"
            }

            $differences = Get-DifferencesBetweenRegionObjects -ObjectFromApi $mockApiResult -ObjectFromFile $mockFileResult

            It "should return an item per difference" {
                $differences.Count | Should Be 6
            }

            It "should return the Page Region" { 
                $differences.PageRegion | Should Be 1
            }

            It "should mark the IsHealthy field as being changed" {
                $differences.IsHealthy | Should be $true 
            }
            It "should mark the RegionEndpoint field as being changed" {
                $differences.RegionEndpoint | Should be "https://some-region-endpoint/pathTwo"
            }

            It "should mark the HealthCheckRequired field as being changed" {
                $differences.HealthCheckRequired | Should be $true
            }

            It "should mark the OfflineHTML field as being changed" {
                $differences.OfflineHTML | Should be "Different Offline Html"
            }
        }
    }    
}

Pop-Location