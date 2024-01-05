Push-Location -Path $PSScriptRoot\..\..\PSCoreScripts\

Describe "Add-StorageAuditResults unit tests" -Tag "Unit" {

    Context "AppendToReport parameter used and object passed in is not of type CrossEnvironmentStorageAccountAudit" {


        BeforeAll {
            $LatestDateTimeOffset = [System.DateTimeOffset]::new("12/26/2019 11:00:00")
            $OlderDateTimeOffset = [System.DateTimeOffset]::new("12/25/2019 09:00:00")

            Mock Get-AzStorageAccount -MockWith { return @(
                    @{
                        StorageAccountName = "dfcfoosharedstr"
                        ResourceGroupName  = "dfc-foo-shared-rg"
                    },
                    @{
                        StorageAccountName = "dssfoosharedstr"
                        ResourceGroupName  = "dss-foo-shared-rg"
                    },
                    @{
                        StorageAccountName = "dfcbarsharedstr"
                        ResourceGroupName  = "dfc-bar-shared-rg"
                    }
                ) }
            Mock New-AzStorageContext
            Mock Get-AzStorageContainer -MockWith { return @(
                    @{
                        Name         = "foo-container"
                        LastModified = $LatestDateTimeOffset
                    },
                    @{
                        Name         = "bar-container"
                        LastModified = $OlderDateTimeOffset
                    }
                ) }
            Mock Get-AzStorageAccountKey -MockWith { return @(
                    @{
                        KeyName     = "key1"
                        Value       = "not-a-real-key"
                        Permissions = "full"
                    },
                    @{
                        KeyName     = "key2"
                        Value       = "not-a-real-key-either"
                        Permissions = "full"
                    }
                ) }
            Mock New-AzStorageContext
            Mock Get-AzStorageShare -MockWith { return @(
                    @{
                        Name       = "foo-share"
                        Properties = @{
                            LastModified = $LatestDateTimeOffset
                        }
            
                    },
                    @{
                        Name       = "bar-share"
                        Properties = @{
                            LastModified = $OlderDateTimeOffset
                        }
                    }
                ) }
            Mock Get-AzStorageQueue -MockWith { return @(
                    @{
                        Name = "foo-queue"
                    },
                    @{
                        Name = "bar-queue"
                    }
                ) }
            Mock Get-AzStorageTable -MockWith { return @(
                    @{
                        Name = "foo-table"
                    },
                    @{
                        Name = "bar-table"
                    }
                ) }

            $Params = @{
                EnvironmentNames = @("foo", "bar")
            }
        }

        It "should Throw an error" {
            $Params["AppendToReport"] = New-Object -TypeName Object

            { .\Add-StorageAuditResults.ps1 @Params } | 
            Should -Throw -ExpectedMessage 'Error validating input from AppendToReport parameter, a member of array is not of type `[CrossEnvironmentStorageAccountAudit`]*'
        }

    }

    Context "AppendToReport parameter is not used and valid environment names are used" {


        BeforeAll {
            $LatestDateTimeOffset = [System.DateTimeOffset]::new("12/26/2019 11:00:00")
            $OlderDateTimeOffset = [System.DateTimeOffset]::new("12/25/2019 09:00:00")

            Mock Get-AzStorageAccount -MockWith { return @(
                    @{
                        StorageAccountName = "dfcfoosharedstr"
                        ResourceGroupName  = "dfc-foo-shared-rg"
                    },
                    @{
                        StorageAccountName = "dssfoosharedstr"
                        ResourceGroupName  = "dss-foo-shared-rg"
                    },
                    @{
                        StorageAccountName = "dfcbarsharedstr"
                        ResourceGroupName  = "dfc-bar-shared-rg"
                    }
                ) }
            Mock New-AzStorageContext
            Mock Get-AzStorageContainer -MockWith { return @(
                    @{
                        Name         = "foo-container"
                        LastModified = $LatestDateTimeOffset
                    },
                    @{
                        Name         = "bar-container"
                        LastModified = $OlderDateTimeOffset
                    }
                ) }
            Mock Get-AzStorageAccountKey -MockWith { return @(
                    @{
                        KeyName     = "key1"
                        Value       = "not-a-real-key"
                        Permissions = "full"
                    },
                    @{
                        KeyName     = "key2"
                        Value       = "not-a-real-key-either"
                        Permissions = "full"
                    }
                ) }
            Mock New-AzStorageContext
            Mock Get-AzStorageShare -MockWith { return @(
                    @{
                        Name       = "foo-share"
                        Properties = @{
                            LastModified = $LatestDateTimeOffset
                        }
            
                    },
                    @{
                        Name       = "bar-share"
                        Properties = @{
                            LastModified = $OlderDateTimeOffset
                        }
                    }
                ) }
            Mock Get-AzStorageQueue -MockWith { return @(
                    @{
                        Name = "foo-queue"
                    },
                    @{
                        Name = "bar-queue"
                    }
                ) }
            Mock Get-AzStorageTable -MockWith { return @(
                    @{
                        Name = "foo-table"
                    },
                    @{
                        Name = "bar-table"
                    }
                ) }

            $Params = @{
                EnvironmentNames = @("foo", "bar")
            }
        }

        BeforeEach {
            $Params.Remove("AppendToReport")

        }
        
        It "should parse the servicename and environment segments from the storage account name if NCS naming convention is used" {
            $VerboseOutput = .\Add-StorageAuditResults.ps1 @Params -Verbose 4>&1
            $VerboseOutput | Where-Object { $_.Message -eq "ServicePrefix is dfc, Environment is foo" } | Should -Not -Be $null
            $VerboseOutput | Where-Object { $_.Message -eq "ServicePrefix is dss, Environment is foo" } | Should -Not -Be $null
            $VerboseOutput | Where-Object { $_.Message -eq "ServicePrefix is dfc, Environment is bar" } | Should -Not -Be $null
        }

        It "should output the LastModified property of the most recently modified container" {
            $Output = .\Add-StorageAuditResults.ps1 @Params
            $Output[0].StorageAccounts[0].ContainersLastModifiedDate | Should -Be $LatestDateTimeOffset
        }

        It "should output a count of the number of containers in each storage account" {
            $Output = .\Add-StorageAuditResults.ps1 @Params
            $Output[0].StorageAccounts[0].ContainersCount | Should -Be 2
        }

        It "should output the LastModified property of the most recently modified fileshare" {
            $Output = .\Add-StorageAuditResults.ps1 @Params
            $Output[0].StorageAccounts[0].FileSharesLastModifiedDate | Should -Be $LatestDateTimeOffset
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
            $Output = .\Add-StorageAuditResults.ps1 @Params
            $Output[0].StorageAccounts.Count | Should -Be 2
            $Output[1].StorageAccounts.Count | Should -Be 1
        }

    }
    
    Context "AppendToReport parameter used and object passed in is of type CrossEnvironmentStorageAccountAudit" {


        BeforeAll {
            $LatestDateTimeOffset = [System.DateTimeOffset]::new("12/26/2019 11:00:00")
            $OlderDateTimeOffset = [System.DateTimeOffset]::new("12/25/2019 09:00:00")

            Mock Get-AzStorageAccount -MockWith { return @(
                    @{
                        StorageAccountName = "dfcfoosharedstr"
                        ResourceGroupName  = "dfc-foo-shared-rg"
                    },
                    @{
                        StorageAccountName = "dssfoosharedstr"
                        ResourceGroupName  = "dss-foo-shared-rg"
                    },
                    @{
                        StorageAccountName = "dfcbarsharedstr"
                        ResourceGroupName  = "dfc-bar-shared-rg"
                    }
                ) }
            Mock New-AzStorageContext
            Mock Get-AzStorageContainer -MockWith { return @(
                    @{
                        Name         = "foo-container"
                        LastModified = $LatestDateTimeOffset
                    },
                    @{
                        Name         = "bar-container"
                        LastModified = $OlderDateTimeOffset
                    }
                ) }
            Mock Get-AzStorageAccountKey -MockWith { return @(
                    @{
                        KeyName     = "key1"
                        Value       = "not-a-real-key"
                        Permissions = "full"
                    },
                    @{
                        KeyName     = "key2"
                        Value       = "not-a-real-key-either"
                        Permissions = "full"
                    }
                ) }
            Mock New-AzStorageContext
            Mock Get-AzStorageShare -MockWith { return @(
                    @{
                        Name       = "foo-share"
                        Properties = @{
                            LastModified = $LatestDateTimeOffset
                        }
            
                    },
                    @{
                        Name       = "bar-share"
                        Properties = @{
                            LastModified = $OlderDateTimeOffset
                        }
                    }
                ) }
            Mock Get-AzStorageQueue -MockWith { return @(
                    @{
                        Name = "foo-queue"
                    },
                    @{
                        Name = "bar-queue"
                    }
                ) }
            Mock Get-AzStorageTable -MockWith { return @(
                    @{
                        Name = "foo-table"
                    },
                    @{
                        Name = "bar-table"
                    }
                ) }

            $Params = @{
                EnvironmentNames = @("foo", "bar")
            }
        }
        It "should append output to AppendToReport object" {
            $Params.Remove("AppendToReport")
            $FirstTenant = .\Add-StorageAuditResults.ps1 @Params

            Mock Get-AzStorageAccount -MockWith { return @(
                    @{
                        StorageAccountName = "dfcwoosharedstr"
                        ResourceGroupName  = "dfc-woo-shared-rg"
                    },
                    @{
                        StorageAccountName = "dsswoosharedstr"
                        ResourceGroupName  = "dss-woo-shared-rg"
                    },
                    @{
                        StorageAccountName = "dfcgarsharedstr"
                        ResourceGroupName  = "dfc-gar-shared-rg"
                    }
                ) }

            $Params = @{
                EnvironmentNames = @("woo", "gar")
                AppendToReport   = $FirstTenant
            }

            $SecondTenant = .\Add-StorageAuditResults.ps1 @Params
            $SecondTenant.Count | Should -Be 2
            $SecondTenant[0].StorageAccounts.Count | Should -Be 4
            $SecondTenant[1].StorageAccounts.Count | Should -Be 2
        }
    
    }

    Context "Running in a subscription with multiple services using ServicePrefixes parameter" {


        BeforeAll {
            $LatestDateTimeOffset = [System.DateTimeOffset]::new("12/26/2019 11:00:00")
            $OlderDateTimeOffset = [System.DateTimeOffset]::new("12/25/2019 09:00:00")

            Mock Get-AzStorageAccount -MockWith { return @(
                    @{
                        StorageAccountName = "dfcfoosharedstr"
                        ResourceGroupName  = "dfc-foo-shared-rg"
                    },
                    @{
                        StorageAccountName = "dssfoosharedstr"
                        ResourceGroupName  = "dss-foo-shared-rg"
                    },
                    @{
                        StorageAccountName = "dfcbarsharedstr"
                        ResourceGroupName  = "dfc-bar-shared-rg"
                    }
                ) }
            Mock New-AzStorageContext
            Mock Get-AzStorageContainer -MockWith { return @(
                    @{
                        Name         = "foo-container"
                        LastModified = $LatestDateTimeOffset
                    },
                    @{
                        Name         = "bar-container"
                        LastModified = $OlderDateTimeOffset
                    }
                ) }
            Mock Get-AzStorageAccountKey -MockWith { return @(
                    @{
                        KeyName     = "key1"
                        Value       = "not-a-real-key"
                        Permissions = "full"
                    },
                    @{
                        KeyName     = "key2"
                        Value       = "not-a-real-key-either"
                        Permissions = "full"
                    }
                ) }
            Mock New-AzStorageContext
            Mock Get-AzStorageShare -MockWith { return @(
                    @{
                        Name       = "foo-share"
                        Properties = @{
                            LastModified = $LatestDateTimeOffset
                        }
            
                    },
                    @{
                        Name       = "bar-share"
                        Properties = @{
                            LastModified = $OlderDateTimeOffset
                        }
                    }
                ) }
            Mock Get-AzStorageQueue -MockWith { return @(
                    @{
                        Name = "foo-queue"
                    },
                    @{
                        Name = "bar-queue"
                    }
                ) }
            Mock Get-AzStorageTable -MockWith { return @(
                    @{
                        Name = "foo-table"
                    },
                    @{
                        Name = "bar-table"
                    }
                ) }

            $Params = @{
                EnvironmentNames = @("foo", "bar")
            }
        }

        BeforeEach {
            $Params.Remove("AppendToReport")
            $Params["ServicePrefixes"] = @("dfc", "dss")

            Mock Get-AzStorageAccount -MockWith { return @(
                    @{
                        StorageAccountName = "dfcfoosharedstr"
                        ResourceGroupName  = "dfc-foo-shared-rg"
                    },
                    @{
                        StorageAccountName = "dssfoosharedstr"
                        ResourceGroupName  = "dss-foo-shared-rg"
                    },
                    @{
                        StorageAccountName = "dfcbarsharedstr"
                        ResourceGroupName  = "dfc-bar-shared-rg"
                    },
                    @{
                        StorageAccountName = "dasbarsharedstr"
                        ResourceGroupName  = "das-bar-shared-rg"
                    }
                ) 
            }

        }

        It "should only return results where the Storage Account Name starts with the values passed in using ServicePrefixes" {
            $Output = .\Add-StorageAuditResults.ps1 @Params
            $Output.Count | Should -Be 2
            $Output[0].StorageAccounts.Count | Should -Be 2
            $Output[1].StorageAccounts.Count | Should -Be 1
        }

    }
}