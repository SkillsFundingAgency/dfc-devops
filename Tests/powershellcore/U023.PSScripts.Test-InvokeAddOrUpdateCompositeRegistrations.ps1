Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Import-Module ../PSModules/CompositeRegistrationFunctions

Describe "Invoke-AddOrUpdateCompositeRegistrations" -Tag "Unit" {
    Mock New-RegistrationContext
    Mock Get-PathRegistration -MockWith { return $null }
    Mock New-PathRegistration -MockWith { return $null }
    Mock Update-PathRegistration  -MockWith { return $null }
    Mock Get-RegionRegistration -MockWith { return $null }
    Mock New-RegionRegistration  -MockWith { return $null }
    Mock Update-RegionRegistration  -MockWith { return $null }
    Mock Get-Content
    Mock ConvertTo-HashTable -MockWith { return $Object }
    Mock Get-PatchDocuments
    # Pester/Powershell Core bug: We can no longer mock ConvertFrom-Json
    # https://github.com/pester/Pester/issues/1289
    # https://github.com/PowerShell/PowerShell/issues/9058
    Mock ConvertFrom-Json

    Context "When a path registration does not exist" {
        Mock ConvertFrom-Json -MockWith { return @(
            @{
                Path = "SomePath"
                Layout = 1
            }
        )}

        & $PSScriptRoot/../PSScripts/Invoke-AddOrUpdateCompositeRegistrations -PathApiUrl https://path/api -RegionApiUrl https://region/api -RegistrationFile ./some-file.json -ApiKey SomeApiKey

        It "should attempt to get a path registration" {
            Assert-MockCalled Get-PathRegistration -ParameterFilter { $Path -eq "SomePath" } -Exactly 1
        }

        It "should create a new registration"  {
            Assert-MockCalled New-PathRegistration -Exactly 1
        }

        It "should not convert any objects into hashtables" {
            Assert-MockCalled ConvertTo-HashTable -Exactly 0
        }

        It "should not generate any patch documents" {
            Assert-MockCalled Get-PatchDocuments -Exactly 0
        }

        It "should not update any path registrations" {
            Assert-MockCalled Update-PathRegistration -Exactly 0
        }

        It "should not get any region registrations" {
            Assert-MockCalled Get-RegionRegistration -Exactly 0
        }

        It "should not create any region registrations" {
            Assert-MockCalled New-RegionRegistration -Exactly 0
        }

        It "should not update any region registrations" {
            Assert-MockCalled Update-RegionRegistration -Exactly 0
        }
    }

    Context "When a path registration exists and does not require updating" {
        Mock ConvertFrom-Json -MockWith { return @(
            @{
                Path = "SomePath"
                Layout = 1
            }
        )}

        Mock Get-PathRegistration -MockWith { return @{
            Path = "SomePath"
        } }

        Mock Get-PatchDocuments -MockWith { return @() }

        & $PSScriptRoot/../PSScripts/Invoke-AddOrUpdateCompositeRegistrations -PathApiUrl https://path/api -RegionApiUrl https://region/api -RegistrationFile ./some-file.json -ApiKey SomeApiKey

        It "should attempt to get a path registration" {
            Assert-MockCalled Get-PathRegistration -ParameterFilter { $Path -eq "SomePath" } -Exactly 1
        }

        It "should not create a new registration"  {
            Assert-MockCalled New-PathRegistration -Exactly -0
        }

        It "should convert the path objects into hashtables" {
            Assert-MockCalled ConvertTo-HashTable -Exactly 2
        }

        It "should get the patch documents for the path" {
            Assert-MockCalled Get-PatchDocuments -Exactly 1
        }

        It "should not update any path registrations" {
            Assert-MockCalled Update-PathRegistration -Exactly 0
        }

        It "should not get any region registrations" {
            Assert-MockCalled Get-RegionRegistration -Exactly 0
        }

        It "should not create any region registrations" {
            Assert-MockCalled New-RegionRegistration -Exactly 0
        }

        It "should not update any region registrations" {
            Assert-MockCalled Update-RegionRegistration -Exactly 0
        }
    }

    Context "When a path registration exists and requires updating" {
        Mock ConvertFrom-Json -MockWith { return @(
            @{
                Path = "SomePath"
                Layout = 1
            }
        )}

        Mock Get-PathRegistration -MockWith { return @{
            Path = "SomePath"
        } }

        Mock Get-PatchDocuments -ParameterFilter { $ReplacementValues.Path -eq "SomePath" } -MockWith {
            $docs = @(@{
                "op" = "add"
                "path" = "/AProperty"
                "value" = "AValue"
            })

            return ,$docs
        }

        & $PSScriptRoot/../PSScripts/Invoke-AddOrUpdateCompositeRegistrations -PathApiUrl https://path/api -RegionApiUrl https://region/api -RegistrationFile ./some-file.json  -ApiKey SomeApiKey

        It "should attempt to get a path registration" {
            Assert-MockCalled Get-PathRegistration -ParameterFilter { $Path -eq "SomePath" } -Exactly 1
        }

        It "should not create a new registration"  {
            Assert-MockCalled New-PathRegistration -Exactly -0
        }

        It "should convert the path objects into hashtables" {
            Assert-MockCalled ConvertTo-HashTable -Exactly 2
        }

        It "should get the patch documents for the page" {
            Assert-MockCalled Get-PatchDocuments -ParameterFilter { $ReplacementValues.Path -eq "SomePath" } -Exactly 1
        }

        It "should update the path registration" {
            Assert-MockCalled Update-PathRegistration -ParameterFilter { $Path -eq "SomePath" } -Exactly 1
        }

        It "should not get any region registrations" {
            Assert-MockCalled Get-RegionRegistration -Exactly 0
        }

        It "should get the patch documents for the region" {
            Assert-MockCalled Get-PatchDocuments -ParameterFilter { $ReplacementValues.Path -ne "SomePath" } -Exactly 0
        }

        It "should not create any region registrations" {
            Assert-MockCalled New-RegionRegistration -Exactly 0
        }

        It "should not update any region registrations" {
            Assert-MockCalled Update-RegionRegistration -Exactly 0
        }
    }

    Context "When a region registration does not exist" {
        Mock ConvertFrom-Json -MockWith { return @(
            @{
                Path = "SomePath"
                Layout = 1
                Regions = @(
                    @{
                        PageRegion = 1
                    }
                )
            }
        )}

        Mock Get-PathRegistration -MockWith { return @{
            Path = "SomePath"
        } }

        Mock Get-PatchDocuments -ParameterFilter { $ReplacementValues.Path -eq "SomePath" } -MockWith { return @() }

        & $PSScriptRoot/../PSScripts/Invoke-AddOrUpdateCompositeRegistrations -PathApiUrl https://path/api -RegionApiUrl https://region/api -RegistrationFile ./some-file.json  -ApiKey SomeApiKey

        It "should attempt to get a path registration" {
            Assert-MockCalled Get-PathRegistration -ParameterFilter { $Path -eq "SomePath" } -Exactly 1
        }

        It "should not create a new registration"  {
            Assert-MockCalled New-PathRegistration -Exactly -0
        }

        It "should convert the objects into hashtables" {
            Assert-MockCalled ConvertTo-HashTable -Exactly 2
        }

        It "should get the patch documents for the page" {
            Assert-MockCalled Get-PatchDocuments -ParameterFilter { $ReplacementValues.Path -eq "SomePath" } -Exactly 1
        }

        It "should not update any path registrations" {
            Assert-MockCalled Update-PathRegistration -Exactly 0
        }

        It "should get the region registration" {
            Assert-MockCalled Get-RegionRegistration -Exactly 1 -ParameterFilter { $Path -eq "SomePath" -and $PageRegion -eq 1 }
        }

        It "should create a new region registrations" {
            Assert-MockCalled New-RegionRegistration -Exactly 1 -ParameterFilter { $Path -eq "SomePath" }
        }

        It "should not get the patch documents for the region" {
            Assert-MockCalled Get-PatchDocuments -ParameterFilter { $ReplacementValues.PageRegion -eq 1 } -Exactly 0
        }

        It "should not update any region registrations" {
            Assert-MockCalled Update-RegionRegistration -Exactly 0
        }
    }


    Context "When a region registation exists and does not require updating" {
        Mock ConvertFrom-Json -MockWith { return @(
            @{
                Path = "SomePath"
                Layout = 1
                Regions = @(
                    @{
                        PageRegion = 1
                    }
                )
            }
        )}

        Mock Get-PathRegistration -MockWith { return @{
            Path = "SomePath"
        } }

        Mock Get-PatchDocuments -MockWith { return @() }

        Mock Get-RegionRegistration -MockWith { return @{
            PageRegion = 1
        } }

        & $PSScriptRoot/../PSScripts/Invoke-AddOrUpdateCompositeRegistrations -PathApiUrl https://path/api -RegionApiUrl https://region/api -RegistrationFile ./some-file.json  -ApiKey SomeApiKey

        It "should attempt to get a path registration" {
            Assert-MockCalled Get-PathRegistration -ParameterFilter { $Path -eq "SomePath" } -Exactly 1
        }

        It "should not create a new registration"  {
            Assert-MockCalled New-PathRegistration -Exactly -0
        }

        It "should get the patch documents for the path" {
            Assert-MockCalled Get-PatchDocuments -ParameterFilter { $ReplacementValues.Path -eq "SomePath" } -Exactly 1
        }

        It "should not update any path registrations" {
            Assert-MockCalled Update-PathRegistration -Exactly 0
        }

        It "should get the region registration" {
            Assert-MockCalled Get-RegionRegistration -Exactly 1 -ParameterFilter { $Path -eq "SomePath"  }
        }

        It "should not create any region registrations" {
            Assert-MockCalled New-RegionRegistration -Exactly 0
        }

        It "should convert the objects into hashtables" {
            Assert-MockCalled ConvertTo-HashTable -Exactly 4
        }

        It "should get the patch documents for the region"  {
            Assert-MockCalled Get-PatchDocuments -ParameterFilter { $ReplacementValues.PageRegion -eq 1 } -Exactly 1
        }

        It "should not update any region registrations" {
            Assert-MockCalled Update-RegionRegistration -Exactly 0
        }
    }

    Context "When a region registation exists and requires updating" {
        Mock ConvertFrom-Json -MockWith { return @(
            @{
                Path = "SomePath"
                Layout = 1
                Regions = @(
                    @{
                        PageRegion = 1
                    }
                )
            }
        )}

        Mock Get-PathRegistration -MockWith { return @{
            Path = "SomePath"
        } }

        Mock Get-PatchDocuments -ParameterFilter { $ReplacementValues.PageRegion -eq 1 } -MockWith {
            $docs = @(@{
                "op" = "add"
                "path" = "/AProperty"
                "value" = "AValue"
            })

            return ,$docs
        }

        Mock Get-RegionRegistration -MockWith { return @{
            PageRegion = 1
        } }

        & $PSScriptRoot/../PSScripts/Invoke-AddOrUpdateCompositeRegistrations -PathApiUrl https://path/api -RegionApiUrl https://region/api -RegistrationFile ./some-file.json  -ApiKey SomeApiKey

        It "should attempt to get a path registration" {
            Assert-MockCalled Get-PathRegistration -ParameterFilter { $Path -eq "SomePath" } -Exactly 1
        }

        It "should not create a new registration"  {
            Assert-MockCalled New-PathRegistration -Exactly -0
        }

        It "should get the patch objects for the path" {
            Assert-MockCalled Get-PatchDocuments -ParameterFilter { $ReplacementValues.Path -eq "SomePath" } -Exactly 1
        }

        It "should not update any path registrations" {
            Assert-MockCalled Update-PathRegistration -Exactly 0
        }

        It "should get the region registration" {
            Assert-MockCalled Get-RegionRegistration -Exactly 1 -ParameterFilter { $Path -eq "SomePath" -and $PageRegion -eq 1 }
        }

        It "should not create any region registrations" {
            Assert-MockCalled New-RegionRegistration -Exactly 0
        }

        It "should convert the objects into hashtables" {
            Assert-MockCalled ConvertTo-HashTable -Exactly 4
        }

        It "should get the patch documents for the region"  {
            Assert-MockCalled Get-PatchDocuments -ParameterFilter { $ReplacementValues.PageRegion -eq 1 } -Exactly 1
        }

        It "should update the region registrations" {
            Assert-MockCalled Update-RegionRegistration -Exactly 1 -ParameterFilter { $Path -eq "SomePath" -and $PageRegion -eq 1 }
        }
    }
}

Pop-Location