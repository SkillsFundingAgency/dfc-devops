Import-Module $PSScriptRoot/../PSModules/CompositeRegistrationFunctions

Describe "Invoke-AddOrUpdateCompositeRegistrations" -Tag "Unit" {
    Mock New-RegistrationContext
    Mock Get-PathRegistration -MockWith { return $null }
    Mock New-PathRegistration -MockWith { return $null }
    Mock Get-DifferencesBetweenDefinitionAndCurrent
    Mock Update-PathRegistration  -MockWith { return $null }
    Mock Get-RegionRegistration -MockWith { return $null }
    Mock New-RegionRegistration  -MockWith { return $null }
    Mock Update-RegionRegistration  -MockWith { return $null }
    Mock Get-Content
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

        It "should not check for differences between path or region objects" {
            Assert-MockCalled Get-DifferencesBetweenDefinitionAndCurrent -Exactly 0
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

        Mock Get-DifferencesBetweenDefinitionAndCurrent -MockWith { return @() }

        & $PSScriptRoot/../PSScripts/Invoke-AddOrUpdateCompositeRegistrations -PathApiUrl https://path/api -RegionApiUrl https://region/api -RegistrationFile ./some-file.json -ApiKey SomeApiKey

        It "should attempt to get a path registration" {
            Assert-MockCalled Get-PathRegistration -ParameterFilter { $Path -eq "SomePath" } -Exactly 1
        }

        It "should not create a new registration"  {
            Assert-MockCalled New-PathRegistration -Exactly -0
        }

        It "should check for differences between path objects only" {
            Assert-MockCalled Get-DifferencesBetweenDefinitionAndCurrent -Exactly 1
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

    <# Fix
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

        Mock Get-DifferencesBetweenDefinitionAndCurrent -MockWith { return @(
            @{
                Op    = "Replace"
                Path  = "SomePath"
                Value = "Some value"
            }
        )}

        & $PSScriptRoot/../PSScripts/Invoke-AddOrUpdateCompositeRegistrations -PathApiUrl https://path/api -RegionApiUrl https://region/api -RegistrationFile ./some-file.json  -ApiKey SomeApiKey

        It "should attempt to get a path registration" {
            Assert-MockCalled Get-PathRegistration -ParameterFilter { $Path -eq "SomePath" } -Exactly 1
        }

        It "should not create a new registration"  {
            Assert-MockCalled New-PathRegistration -Exactly -0
        }

        It "should check for differences between path objects only" {
            Assert-MockCalled Get-DifferencesBetweenDefinitionAndCurrent -Exactly 1
        }

        It "should update any path registrations" {
            Assert-MockCalled Update-PathRegistration -ParameterFilter { $Path -eq "SomePath" } -Exactly 1
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
    #>

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

        Mock Get-DifferencesBetweenDefinitionAndCurrent -MockWith { return @() }

        & $PSScriptRoot/../PSScripts/Invoke-AddOrUpdateCompositeRegistrations -PathApiUrl https://path/api -RegionApiUrl https://region/api -RegistrationFile ./some-file.json  -ApiKey SomeApiKey

        It "should attempt to get a path registration" {
            Assert-MockCalled Get-PathRegistration -ParameterFilter { $Path -eq "SomePath" } -Exactly 1
        }

        It "should not create a new registration"  {
            Assert-MockCalled New-PathRegistration -Exactly -0
        }

        It "should check for differences between path objects only" {
            Assert-MockCalled Get-DifferencesBetweenDefinitionAndCurrent -Exactly 1
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

        Mock Get-DifferencesBetweenDefinitionAndCurrent -MockWith { return @() }

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

        It "should check for differences between path and region objects" {
            Assert-MockCalled Get-DifferencesBetweenDefinitionAndCurrent -Exactly 2
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

        It "should not update any region registrations" {
            Assert-MockCalled Update-RegionRegistration -Exactly 0
        }
    }

    <# Fix
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

        Mock Get-DifferencesBetweenDefinitionAndCurrent -MockWith { return @{} }

        Mock Get-RegionRegistration -MockWith { return @{
            PageRegion = 1
        } }

        Mock Get-DifferencesBetweenDefinitionAndCurrent -MockWith { return @{
            OfflineHtml = "updated text"
        }}

        & $PSScriptRoot/../PSScripts/Invoke-AddOrUpdateCompositeRegistrations -PathApiUrl https://path/api -RegionApiUrl https://region/api -RegistrationFile ./some-file.json  -ApiKey SomeApiKey

        It "should attempt to get a path registration" {
            Assert-MockCalled Get-PathRegistration -ParameterFilter { $Path -eq "SomePath" } -Exactly 1
        }

        It "should not create a new registration"  {
            Assert-MockCalled New-PathRegistration -Exactly -0
        }

        It "should check for differences between path objects" {
            Assert-MockCalled Get-DifferencesBetweenDefinitionAndCurrent -Exactly 1
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

        It "should get the differences between region objects"  {
            Assert-MockCalled Get-DifferencesBetweenDefinitionAndCurrent -Exactly 1
        }

        It "should update the region registrations" {
            Assert-MockCalled Update-RegionRegistration -Exactly 1 -ParameterFilter { $Path -eq "SomePath" -and $PageRegion -eq 1 }
        }
    }
    #>
}