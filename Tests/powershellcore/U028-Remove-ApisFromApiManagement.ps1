Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Remove-ApisFromApiManagement unit tests" -Tag "Unit" {
        
    # Re-define the three Az cmdlets under test, as we can't mock them directly.
    # They fire a ParameterBindingValidationException on both powershell core and powershell 5.
    # suspect it's due to https://github.com/pester/Pester/issues/619
    function New-AzApiManagementContext { 
        [CmdletBinding()]
        param($ResourceGroupName, $ServiceName)
    }

    function Get-AzApiManagementApi {
        [CmdletBinding()]
        param($Context, $Name)
    }

    function Remove-AzApiManagementApi {
        [CmdletBinding()]
        param($Context, $ApiId)
    }

    Mock New-AzApiManagementContext
    Mock Remove-AzApiManagementApi

    Context "When removing apis" {
    
        Mock Get-AzApiManagementApi -MockWith { 

            if($Name -eq "Api One") { 
                return @{ ApiId = "ApiOne" }
            }

            return @{ ApiId = "ApiTwo" }
        }

        ./Remove-ApisFromApiManagement -ApisToRemove @( "Api One", "Api Two") -ApimResourceGroup "aResourceGroup" -ApimServiceName "anApimInstance"

        It "Should create a new apim context"  {
            Assert-MockCalled New-AzApiManagementContext -Exactly 1  -ParameterFilter { 
                $ResourceGroupName -eq "aResourceGroup" -and `
                $ServiceName -eq "anApimInstance"
            }         
        }    
        
        It "Should get the apis" {
            Assert-MockCalled Get-AzApiManagementApi -Exactly 1 -ParameterFilter { $Name -eq "Api One" }
            Assert-MockCalled Get-AzApiManagementApi -Exactly 1 -ParameterFilter { $Name -eq "Api Two" }
        }

        It "Should remove the apis" {
            Assert-MockCalled Remove-AzApiManagementApi -Exactly 1 -ParameterFilter { $ApiId -eq "ApiOne" }
            Assert-MockCalled Remove-AzApiManagementApi -Exactly 1 -ParameterFilter { $ApiId -eq "ApiTwo" }
        }
    }

    Context "When the api does not exist" {
        Mock Get-AzApiManagementApi -MockWith { return $null }

        ./Remove-ApisFromApiManagement -ApisToRemove @( "ApiNotFound" ) -ApimResourceGroup "aResourceGroup" -ApimServiceName "anApimInstance"

        It "Should create a new apim context"  {
            Assert-MockCalled New-AzApiManagementContext -Exactly 1  -ParameterFilter {
                $ResourceGroupName -eq "aResourceGroup" -and `
                $ServiceName -eq "anApimInstance"
            }
        }

        It "Should get the apis" {
            Assert-MockCalled Get-AzApiManagementApi -Exactly 1 -ParameterFilter { $Name -eq "ApiNotFound" }
        }

        It "Should not remove any apis" {
            Assert-MockCalled Remove-AzApiManagementApi -Exactly 0
        }
    }
}