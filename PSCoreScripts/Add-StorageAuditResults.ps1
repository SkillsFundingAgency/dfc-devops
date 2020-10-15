<#
.SYNOPSIS
Audits high level usage of storage accounts.

.DESCRIPTION
Audits high level usage of storage accounts.  Outputs number of containers, file shares, queues and tables from multiple storage accounts.
Can audit multiple environments within a subscription.  Can accept the output from a previous audit and append to this allowing audits to be ran across multiple subscriptions and tenants.

.PARAMETER EnvironmentNames
An array of environment names.  Assumes that the DFC naming convention for storage accounts is followed, ie <service><environment><project>str, eg dfcfooprojectbarstr

.PARAMETER AppendToReport
(optional) The output from a previous run of this cmdlet.  Must be of type CrossEnvironmentStorageAccountAudit[]

.PARAMETER ServicePrefixes
(optional) A list of service prefixes, useful when running in subscriptions shared with other services

.EXAMPLE
Audits the dev and test environments, the output from that audit is then passed to the 2nd cmdlet which audits the lab environment and produces a consolidated report
$AuditDevTest = .\PSScripts\Add-StorageAuditResults.ps1 -EnvironmentNames "dev", "test" -Verbose
$AuditLab = .\PSScripts\Add-StorageAuditResults.ps1 -EnvironmentNames "lab" -AppendToReport $AuditDevTest  -Verbose
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string[]]$EnvironmentNames,
    [Parameter(Mandatory=$false)]
    [Object[]]$AppendToReport,
    [Parameter(Mandatory=$false)]
    [string[]]$ServicePrefixes
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

$StorageAccounts = Get-AzStorageAccount
if ($PSBoundParameters.ContainsKey('ServicePrefixes')) {

    $ServiceNameRegEx = "^($($ServicePrefixes -join "|"))(\w+)$"
    Write-Verbose "Using ServiceNameRegEx $ServiceNameRegEx"
    $StorageAccounts = $StorageAccounts | Where-Object { $_.StorageAccountName -match $ServiceNameRegEx }

}
Write-Verbose "Retrieved $($StorageAccounts.Count) to audit"

$AccountNameRegEx = "^(\w{3})($($EnvironmentNames -join "|"))(\w+)$"
Write-Verbose "Using AccountNameRegEx $AccountNameRegEx"

foreach ($StorageAccount in $StorageAccounts) {

    $AccountNameContainsEnv = $StorageAccount.StorageAccountName -match $AccountNameRegEx
    Write-Verbose "$($StorageAccount.StorageAccountName) matches regex pattern.  $($Matches.Count) matches found"

    if ($AccountNameContainsEnv) {

        Write-Verbose "ServicePrefix is $($Matches[1]), Environment is $($Matches[2])"
        Write-Verbose "Shared account name suffix is $($Matches[3])"
        $AppendToExistingResult = $false

        foreach ($ExistingAuditResult in $StorageAccountsAuditResults) {

            if ($ExistingAuditResult.ServicePrefix -eq $Matches[1] -and $ExistingAuditResult.SharedAccountNameSuffix -eq $Matches[3]) {

                Write-Verbose "Existing audit found with ServicePrefix $($Matches[1]) and SharedAccountNameSuffix $($Matches[3]), appending results"
                $CrossEnvironmentStorageAccountAudit = $ExistingAuditResult
                $AppendToExistingResult = $true
                break

            }

        }
        if (!$CrossEnvironmentStorageAccountAudit) {

            Write-Verbose "No existing audit found with ServicePrefix $($Matches[1]) and SharedAccountNameSuffix $($Matches[3]), creating new audit object"
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
    try {
        $Containers = Get-AzStorageContainer -Context $Context
    }
    catch {
        Write-Warning "Error retrieving StorageContainers for $($StorageAccount.StorageAccountName)`n$_"
    }

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
    try {
        $FileShares = Get-AzStorageShare -Context $KeyContext
    }
    catch {
        Write-Warning "Error retrieving FileShares for $($StorageAccount.StorageAccountName)`n$_"
    }

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
    try {
        $Queues = Get-AzStorageQueue -Context $Context
    }
    catch {
        Write-Warning "Error retrieving Queues for $($StorageAccount.StorageAccountName)`n$_"
    }

    $StorageAccountAuditResults.QueuesCount = $Queues.Count
    Write-Verbose "$($StorageAccount.StorageAccountName) contains $($Queues.Count) queues"

    # Get the Tables for this account
    try {
        $Tables = Get-AzStorageTable -Context $KeyContext
    }
    catch {
        Write-Warning "Error retrieving Tables for $($StorageAccount.StorageAccountName)`n$_"
    }

    $StorageAccountAuditResults.TablesCount = $Tables.Count
    Write-Verbose "$($StorageAccount.StorageAccountName) contains $($Tables.Count) tables"

    Write-Verbose "StorageAccountAuditResults: $($StorageAccountAuditResults.GetType().ToString())"
    $CrossEnvironmentStorageAccountAudit.StorageAccounts += $StorageAccountAuditResults

    if (!$AppendToExistingResult) {
        $StorageAccountsAuditResults += $CrossEnvironmentStorageAccountAudit
    }
    Remove-Variable -Name CrossEnvironmentStorageAccountAudit
}

$StorageAccountsAuditResults