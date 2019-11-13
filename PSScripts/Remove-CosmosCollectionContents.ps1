<#
.SYNOPSIS
Deletes the contents of a Cosmos Collection

.DESCRIPTION
Deletes the contents of a Cosmos Collection.  Warning all documents will be deleted.  They cannot be recovered unless you have a backup.

Ensure that you have allowed access through the Cosmos firewall for the device running the script.  A 403 response will be returned if you do not do this.

.PARAMETER CollectionId
Name of the Collection that holds the documents that will be deleted.  All documents will be deleted

.PARAMETER CosmosDbAccountName
Name of the CosmosDb Account that holds the database

.PARAMETER CosmosDbReadWriteKey
The read write key for the Cosmos Collection.  Must be passed as a Secure String (either stored as a secret in Azure DevOps or converted from plain text from PS console with ConvertTo-SecureString)

.PARAMETER Database
Name of the database that holds the container

.PARAMETER ResourceGroupName
Name of the Resource Group that the Cosmos Account is in

.EXAMPLE
Remove-CosmosCollectionContents.ps1 -ResourceGroupName "dss-foo-shared-rg" -CosmosDbAccountName "dss-foo-shared-cdb" -Database "bardetails" -CollectionId "bardetails" -Verbose

#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string]$CollectionId,
    [Parameter(Mandatory = $true)]
    [string]$CosmosDbAccountName,
    [Parameter(Mandatory = $true, ParameterSetName="CosmosDbKey")]
    [System.Security.SecureString]$CosmosDbReadWriteKey,
    [Parameter(Mandatory = $true)]
    [string]$Database,
    [Parameter(Mandatory = $true, ParameterSetName="LoggedInIdentity")]
    [string]$ResourceGroupName
)

if ($CosmosDbAccountName -match "-prd-") {

    Write-Warning -Message "Warning you are about to delete the contents of a Production Cosmos Container.  Do you want to continue?" -WarningAction Inquire

}

if ($CosmosDbReadWriteKey) {

    $CosmosDbContext = New-CosmosDbContext -Account $CosmosDbAccountName -Key $CosmosDbReadWriteKey -Database $Database

}
else {

    $CosmosDbContext = New-CosmosDbContext -Account $CosmosDbAccountName -ResourceGroup $ResourceGroupName -MasterKeyType 'PrimaryMasterKey' -Database $Database

}

$ResponseHeader = $null
Write-Verbose "$([DateTime]::Now.ToString("dd-MM-yyyy HH:mm:ss")) Retrieving documents ..."
$Documents = Get-CosmosDbDocument -Context $CosmosDbContext -CollectionId $CollectionId -MaxItemCount 100 -ResponseHeader ([ref] $ResponseHeader)
Write-Debug "Documents retrieved, count: $($Documents.Count)"

$ContinuationToken = [String] $ResponseHeader.'x-ms-continuation'
Write-Debug "ContinuationToken: $ContinuationToken"

while ($ContinuationToken) {

    $Documents += Get-CosmosDbDocument -Context $cosmosDbContext -CollectionId $CollectionId -MaxItemCount 100 -ContinuationToken $ContinuationToken  -ResponseHeader ([ref] $ResponseHeader)
    Write-Debug "Additional documents retrieved, count: $($Documents.Count)"

    $ContinuationToken = [String] $ResponseHeader.'x-ms-continuation'
    Write-Debug "ContinuationToken: $ContinuationToken"

}

Write-Verbose "$([DateTime]::Now.ToString("dd-MM-yyyy HH:mm:ss")) Documents retrieved, count: $($Documents.Count)"
Write-Verbose "$([DateTime]::Now.ToString("dd-MM-yyyy HH:mm:ss")) Deleting documents ..."

foreach ($Document in $Documents) {

    Write-Debug "Deleting document: $($Document.id)"
    Remove-CosmosDbDocument -Context $CosmosDbContext -CollectionId $CollectionId -Id $Document.id
    $DeleteCount++

}

Write-Verbose "$([DateTime]::Now.ToString("dd-MM-yyyy HH:mm:ss")) Documents deleted: $DeleteCount"
