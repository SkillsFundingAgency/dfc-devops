[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$EnvironmentName="dev"
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
    [string]$ResourceGroupServiceEnvironmentPrefix
    [string]$ServicePrefix
    [string]$SharedAccountNameSuffix
    [StorageAccountAudit[]]$StorageAccounts
}

$StorageAccountsAuditResults = @()

$StorageAccounts = Get-AzStorageAccount
foreach ($StorageAccount in $StorageAccounts) {

    $CrossEnvironmentStorageAccountAudit = New-Object -TypeName CrossEnvironmentStorageAccountAudit

    $AccountNameContainsEnv = $StorageAccount.StorageAccountName -match "^(\w*)$EnvironmentName(\w*)$"
    if ($AccountNameContainsEnv) {

        $CrossEnvironmentStorageAccountAudit.ResourceGroupServiceEnvironmentPrefix = "$($Matches[1])$EnvironmentName"
        $CrossEnvironmentStorageAccountAudit.ServicePrefix = $Matches[1]
        Write-Verbose "Shared account name suffix is $($Matches[2])"
        $CrossEnvironmentStorageAccountAudit.SharedAccountNameSuffix = $Matches[2]
        
    }
    else {

        ##TO DO: how \ whether to handle accounts with invalid names (ie missing environment)
        Write-Warning "Account $($StorageAccount.StorageAccountName) doesn't contain environment name $EnvironmentName"
        continue

    }

    $StorageAccountAuditResults = New-Object -TypeName StorageAccountAudit
    $null = $StorageAccount.StorageAccountName -match "^($($CrossEnvironmentStorageAccountAudit.ServicePrefix))(\w*)($($CrossEnvironmentStorageAccountAudit.SharedAccountNameSuffix))$"
    Write-Verbose "Environment name $($Matches[2]) extracted from StorageAccountName"
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
    
    $CrossEnvironmentStorageAccountAudit.StorageAccounts += $StorageAccountAuditResults

    $StorageAccountsAuditResults += $CrossEnvironmentStorageAccountAudit
}

$StorageAccountsAuditResults