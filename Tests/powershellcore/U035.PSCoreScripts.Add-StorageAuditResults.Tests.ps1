Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Add-StorageAuditResults unit tests" -Tag "Unit" {

    Mock Get-AzStorageAccount -MockWith { return @(
        @{
            StorageAccountName = "dfcfoosharedstr"
            ResourceGroupName = "dfc-foo-shared-rg"
        },
        @{
            StorageAccountName = "dssfoosharedstr"
            ResourceGroupName = "dss-foo-shared-rg"
        },
        @{
            StorageAccountName = "dfcbarsharedstr"
            ResourceGroupName = "dfc-bar-shared-rg"
        }
    )}
    Mock New-AzStorageContext
    Mock Get-AzStorageContainer -MockWith { return @(
        @{
            Name = "foo-container"
            LastModified = [System.DateTimeOffset]::new("12/25/2019 11:00:00")
        },
        @{
            Name = "bar-container"
            LastModified = [System.DateTimeOffset]::new("12/25/2019 09:00:00")
        }
    )}
    Mock Get-AzStorageAccountKey -MockWith { return @(
        @{
            KeyName = "key1"
            Value = "not-a-real-key"
            Permissions = "full"
        },
        @{
            KeyName = "key2"
            Value = "not-a-real-key-either"
            Permissions = "full"
        }
    )}
    Mock New-AzStorageContext
    Mock Get-AzStorageShare -MockWith { return @(
        @{
            Name = "foo-share"
            Properties = @{
                LastModified = [System.DateTimeOffset]::new("12/26/2019 11:00:00")
            }
            
        },
        @{
            Name = "bar-share"
            Properties = @{
                LastModified = [System.DateTimeOffset]::new("12/26/2019 09:00:00")
            }
        }
    )}
    Mock Get-AzStorageQueue -MockWith { return @(
        @{
            Name = "foo-queue"
        },
        @{
            Name = "bar-queue"
        }
    )}
    Mock Get-AzStorageTable -MockWith { return @(
        @{
            Name = "foo-table"
        },
        @{
            Name = "bar-table"
        }
    )}

    $Params = @{
        EnvironmentNames = @("foo", "bar")
    }

    Context "When AppendToReport parameter used and object passed in is not of type CrossEnvironmentStorageAccountAudit" {

        $Params["AppendToReport"] = New-Object -TypeName Object

        It "should Throw an error" {
            { .\Add-StorageAuditResults.ps1 @Params } | Should throw "Error validating input from AppendToReport parameter, a member of array is not of type [CrossEnvironmentStorageAccountAudit]"
        }

    }

    Context "When AppendToReport parameter is not used and valid environment names are used" {

        $Params.Remove("AppendToReport")

        It "should parse the servicename and environment segments from the storage account name if NCS naming convention is used" {
            $VerboseOutput = .\Add-StorageAuditResults.ps1 @Params -Verbose 4>&1
            $VerboseOutput | Where-Object { $_.Message -eq "ServicePrefix is dfc, Environment is foo" } | Should -Not -Be $null
            $VerboseOutput | Where-Object { $_.Message -eq "ServicePrefix is dss, Environment is foo" } | Should -Not -Be $null
            $VerboseOutput | Where-Object { $_.Message -eq "ServicePrefix is dfc, Environment is bar" } | Should -Not -Be $null
        }
   
        It "should output the LastModified property of the most recently modified container" {
            $Output = .\Add-StorageAuditResults.ps1 @Params
            $Output[0].StorageAccounts[0].ContainersLastModifiedDate.ToString() | Should -Be "25/12/2019 11:00:00"
        }
    
        It "should output a count of the number of containers in each storage account" {
            $Output = .\Add-StorageAuditResults.ps1 @Params
            $Output[0].StorageAccounts[0].ContainersCount | Should -Be 2
        }
    
        It "should output the LastModified property of the most recently modified fileshare" {
            $Output = .\Add-StorageAuditResults.ps1 @Params
            $Output[0].StorageAccounts[0].FileSharesLastModifiedDate.ToString() | Should -Be "26/12/2019 11:00:00"
        }
    
        It "should output a count of the number of fileshares in each storage account" {
            $Output = .\Add-StorageAuditResults.ps1 @Params
            $Output[0].StorageAccounts[0].FileSharesCount | Should -Be 2
        }
    
        It "should output a count of the number of queues in each storage account" {
            $Output = .\Add-StorageAuditResults.ps1 @Params
            $Output[0].StorageAccounts[0].QueuesCount | Should -Be 2
        }
    
        It "should output a count of the number of tables in each storage account" {
            $Output = .\Add-StorageAuditResults.ps1 @Params
            $Output[0].StorageAccounts[0].TablesCount | Should -Be 2
        }

        It "should group the results of audits for storage accounts whose names are the same except for the environment name segment" {
            ##TO DO: test failure caused bug in script, fix it.  accounts with different service names are getting lumped together when they have the same suffixes
            $Output = .\Add-StorageAuditResults.ps1 @Params
            $Output[0].StorageAccounts.Count | Should -Be 2
            $Output[1].StorageAccounts.Count | Should -Be 1
        }

    }
    
    Context "When AppendToReport parameter used and object passed in is of type CrossEnvironmentStorageAccountAudit" {

        It "should append output to AppendToReport object" {
            $FirstTenant = .\Add-StorageAuditResults.ps1 @Params

            Mock Get-AzStorageAccount -MockWith { return @(
                @{
                    StorageAccountName = "dfcwoosharedstr"
                    ResourceGroupName = "dfc-woo-shared-rg"
                },
                @{
                    StorageAccountName = "dsswoosharedstr"
                    ResourceGroupName = "dss-woo-shared-rg"
                },
                @{
                    StorageAccountName = "dfcgarsharedstr"
                    ResourceGroupName = "dfc-gar-shared-rg"
                }
            )}

            $Params = @{
                EnvironmentNames = @("woo", "gar")
                AppendToReport = $FirstTenant
            }

            ##TO DO: test failure caused bug in script, fix it.  accounts with different service names are getting lumped together when they have the same suffixes
            $SecondTenant = .\Add-StorageAuditResults.ps1 @Params
            $SecondTenant[0].StorageAccounts.Count | Should -Be 2
            $SecondTenant[1].StorageAccounts.Count | Should -Be 1
        }
    
    }
}