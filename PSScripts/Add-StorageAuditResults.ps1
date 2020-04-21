<#
.SYNOPSIS
Audits high level usage of storage accounts.

.DESCRIPTION
Audits high level usage of storage accounts.  Outputs number of containers, file shares, queues and tables from multiple storage accounts.
Can audit multiple environments within a subscription.  Can accept the output from a previous audit and append to this allowing audits to be ran across multiple subscriptions and tenants.

.PARAMETER EnvironmentNames
An array of environment names.  Assumes that the DFC naming convention for storage accounts is followed, ie <service><environment><project>str, eg dfcfooprojectbarstr

.PARAMETER AppendToReport
The output from a previous run of this cmdlet.  Must be of type CrossEnvironmentStorageAccountAudit[]

.EXAMPLE
Audits the dev and test environments, the output from that audit is then passed to the 2nd cmdlet which audits the lab environment and produces a consolidated report
$AuditDevTest = .\PSScripts\Add-StorageAuditResults.ps1 -EnvironmentNames "dev", "test" -Verbose
$AuditLab = .\PSScripts\Add-StorageAuditResults.ps1 -EnvironmentNames "lab" -AppendToReport $AuditDevTest  -Verbose
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string[]]$EnvironmentNames = @("dev","lab","test"),
    [Parameter(Mandatory=$false)]
    [Object[]]$AppendToReport
)

class StorageAccountAudit {
    [string]$EnvironmentName
    [string]$StorageAccountName
    [int]$ContainersCount
    [Nullable[DateTime]]$ContainersLastModifiedDate
    [int]$FileSharesCount
    [Nullable[DateTime]]$FileSharesLastModifiedDate
    [int]$QueuesCount
    [int]$TablesCount
}

class CrossEnvironmentStorageAccountAudit {
    [string]$ServicePrefix
    [string]$SharedAccountNameSuffix
    [StorageAccountAudit[]]$StorageAccounts
}

if ($PSBoundParameters.ContainsKey('AppendToReport')) {

    Write-Verbose "Appending results to existing audit"
    foreach ($CrossEnvironmentStorageAccountAudit in $AppendToReport) {
        if ($CrossEnvironmentStorageAccountAudit.GetType().ToString() -ne "CrossEnvironmentStorageAccountAudit") {

            throw "Error validating input from AppendToReport parameter, a member of array is not of type [CrossEnvironmentStorageAccountAudit]`n$_)"

        }
    }
    $StorageAccountsAuditResults = $AppendToReport

}
else {

    Write-Verbose "Creating new audit"
    $StorageAccountsAuditResults = @()

}

$AccountNameRegEx = "^(\w{3})($($EnvironmentNames -join "|"))(\w+)$"
Write-Verbose "Using AccountNameRegEx $AccountNameRegEx"

$StorageAccounts = Get-AzStorageAccount
Write-Verbose "Retrieved $($StorageAccounts.Count) to audit"
foreach ($StorageAccount in $StorageAccounts) {

    $AccountNameContainsEnv = $StorageAccount.StorageAccountName -match $AccountNameRegEx
    Write-Verbose "$($StorageAccount.StorageAccountName) matches regex pattern.  $($Matches.Count) matches found"

    if ($AccountNameContainsEnv) {

        Write-Verbose "ServicePrefix is $($Matches[1]), Environment is $($Matches[2])"
        Write-Verbose "Shared account name suffix is $($Matches[3])"
    
        foreach ($ExistingAuditResult in $StorageAccountsAuditResults) {
    
            if ($ExistingAuditResult.SharedAccountNameSuffix -eq $Matches[3]) {
    
                Write-Verbose "Existing audit found with SharedAccountNameSuffix $($Matches[3]), appending results"
                $CrossEnvironmentStorageAccountAudit = $ExistingAuditResult
                break
    
            }
    
        }
        if (!$CrossEnvironmentStorageAccountAudit) {
            
            Write-Verbose "No existing audit found with SharedAccountNameSuffix $($Matches[3]), creating new audit object"
            $CrossEnvironmentStorageAccountAudit = New-Object -TypeName CrossEnvironmentStorageAccountAudit
            $CrossEnvironmentStorageAccountAudit.ServicePrefix = $Matches[1]
            $CrossEnvironmentStorageAccountAudit.SharedAccountNameSuffix = $Matches[3]

        }

    }
    else {

        ##TO DO: how \ whether to handle accounts with invalid names (ie missing environment)
        Write-Warning "Account $($StorageAccount.StorageAccountName) doesn't contain environment name $EnvironmentName"
        continue

    }

    $StorageAccountAuditResults = New-Object -TypeName StorageAccountAudit
    $StorageAccountAuditResults.EnvironmentName = $Matches[2]
    $StorageAccountAuditResults.StorageAccountName = $StorageAccount.StorageAccountName

    $Context = New-AzStorageContext -StorageAccountName $StorageAccount.StorageAccountName -UseConnectedAccount
    
    # Get the Blob Containers for this account
    $Containers = Get-AzStorageContainer -Context $Context
    if ($Containers.Count -gt 0) {

        $AccountBlobLastModifiedDate = ($Containers | Sort-Object -Property LastModified -Descending | Select-Object -Property LastModified -First 1).LastModified.UtcDateTime

    }
    else {

        Remove-Variable -Name AccountBlobLastModifiedDate -ErrorAction SilentlyContinue

    }
    $StorageAccountAuditResults.ContainersCount = $Containers.Count
    $StorageAccountAuditResults.ContainersLastModifiedDate = $AccountBlobLastModifiedDate
    Write-Verbose "$($StorageAccount.StorageAccountName) contains $($Containers.Count) containers"

    # Get the File Shares for this account
    $Key =  (Get-AzStorageAccountKey -ResourceGroupName $StorageAccount.ResourceGroupName -Name $StorageAccount.StorageAccountName)[0].Value
    $KeyContext = New-AzStorageContext -StorageAccountName $StorageAccount.StorageAccountName -StorageAccountKey $Key
    $FileShares = Get-AzStorageShare -Context $KeyContext
    if ($FileShares.Count -gt 0) {

        $AccountShareLastModifiedDate = ($FileShares | Select-Object -ExpandProperty Properties | Sort-Object -Property LastModified -Descending | Select-Object -Property LastModified -First 1).LastModified.ToString("yyyy-MM-dd HH:mm") 

    }
    else {

        Remove-Variable -Name AccountShareLastModifiedDate -ErrorAction SilentlyContinue

    }
    $StorageAccountAuditResults.FileSharesCount = $FileShares.Count
    $StorageAccountAuditResults.FileSharesLastModifiedDate = $AccountShareLastModifiedDate
    Write-Verbose "$($StorageAccount.StorageAccountName) contains $($FileShares.Count) file shares"

    # Get the Queues for this account
    $Queues = Get-AzStorageQueue -Context $Context
    $StorageAccountAuditResults.QueuesCount = $Queues.Count
    Write-Verbose "$($StorageAccount.StorageAccountName) contains $($Queues.Count) queues"

    # Get the Tables for this account
    $Tables = Get-AzStorageTable -Context $KeyContext
    $StorageAccountAuditResults.TablesCount = $Tables.Count
    Write-Verbose "$($StorageAccount.StorageAccountName) contains $($Tables.Count) tables"
    
    #Write-Verbose "CrossEnvironmentStorageAccountAudit.StorageAccounts: $($CrossEnvironmentStorageAccountAudit.StorageAccounts.GetType().ToString())"
    Write-Verbose "StorageAccountAuditResults: $($StorageAccountAuditResults.GetType().ToString())"
    $CrossEnvironmentStorageAccountAudit.StorageAccounts += $StorageAccountAuditResults

    $StorageAccountsAuditResults += $CrossEnvironmentStorageAccountAudit
    Remove-Variable -Name CrossEnvironmentStorageAccountAudit
}

$StorageAccountsAuditResults