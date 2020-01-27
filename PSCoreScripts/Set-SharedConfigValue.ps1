<#
.SYNOPSIS
Set a value within Shared Configuration

.DESCRIPTION
Set a value within Shared Configuration

.PARAMETER StorageAccountName
Name of the storage account where the table is

.PARAMETER ResourceGroupName
Name of the resource group the storage account is

.PARAMETER TableName
[Optional] Name of the table storage, defaults to Configuration

.PARAMETER PartitionKey
Storage table partition key

.PARAMETER RowKey
Storage table row key

.PARAMETER JsonString
JSON value in string format

.PARAMETER JsonFilePath
JSON configuration as a file

.EXAMPLE
Set-SharedConfigValue -StorageAccountName aStorageAccount -ResourceGroupName aResourceGroup -TableName aTable -PartitionKey testApplication -RowKey SecretKey -Value "SomeData"
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string] $ResourceGroupName,
    [Parameter(Mandatory = $false)]
    [string] $TableName = "Configuration",
    [Parameter(Mandatory = $true)]
    [string] $PartitionKey,
    [Parameter(Mandatory = $true)]
    [string] $RowKey,
    [Parameter(Mandatory = $true, ParameterSetName = "AsString")]
    [string] $JsonString,
    [Parameter(Mandatory = $true, ParameterSetName = "AsFilePath")]
    [String] $JsonFilePath
)

function Invoke-UpsertTableRow {
    param(
        [object] $Table,
        [string] $PartitionKey,
        [string] $RowKey,
        [string] $Value
    )

    $existingEntry = Get-AzTableRow -Table $Table -PartitionKey $PartitionKey -RowKey $RowKey

    if($existingEntry) {
        Write-Verbose "Updating row for partition key $($PartitionKey) and row key $($RowKey)."
        $existingEntry.Data = $jsonDataToProcess
        Update-AzTableRow -Table $storageTable -entity $existingEntry  | Out-Null
    } else {
        Write-Verbose "Adding new row with partition key $($PartitionKey) and row key $($RowKey)."
        Add-AzTableRow -Table $storageTable -PartitionKey $PartitionKey -RowKey $RowKey -property @{ Data = $jsonDataToProcess }  | Out-Null
    }
}

Write-Verbose "Creating new storage account context"
$storageAccountContext = (Get-AzStorageAccount -Name $StorageAccountName -ResourceGroupName $ResourceGroupName).Context

Write-Verbose "Getting storage table.."
$storageTable = (Get-AzStorageTable –Name $TableName –Context $storageAccountContext).CloudTable

if ($PSCmdlet.ParameterSetName -eq "AsFilePath") {
    Write-Verbose "Getting file contents and upserting data"
    $jsonDataToProcess = Get-Content -Path $JsonFilePath -Raw
    Invoke-UpsertTableRow -Table $storageTable -PartitionKey $PartitionKey -RowKey $RowKey -Value $jsonDataToProcess
}

if ($PSCmdlet.ParameterSetName -eq "AsString") {
    Write-Verbose "Upserting data from raw string"
    $jsonDataToProcess = $JsonString
    Invoke-UpsertTableRow -Table $storageTable -PartitionKey $PartitionKey -RowKey $RowKey -Value $JsonString
}

Write-Verbose "Row added/updated succesfully"