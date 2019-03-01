<#

.SYNOPSIS
Creates Cosmos DB Account collections

.DESCRIPTION
Creates Cosmos DB Account collections within a given CosmosDb Account

.PARAMETER ResourceGroupName
The name of the Resource Group for the CosmosDb Account

.PARAMETER CosmosDbAccountName
Cosmos Db Account to configure

.PARAMETER CosmosDbConfigurationString
CosmosDb JSON configuration in string format

.PARAMETER CosmosDbConfigurationFilePath
CosmosDb JSON configuration as a file

.EXAMPLE
New-CosmosDbAccountCollections -CosmosDbAccountName "dfc-foo-bar-cdb" -CosmosDbConfigurationFilePath C:\path\to\config.json

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName = $ENV:ResourceGroup,
    [Parameter(Mandatory = $true)]
    [string]$CosmosDbAccountName,
    [Parameter(Mandatory = $true, ParameterSetName = "AsString")]
    [string]$CosmosDbConfigurationString,
    [Parameter(Mandatory = $true, ParameterSetName = "AsFilePath")]
    [string]$CosmosDbConfigurationFilePath
)

$MinCosmosDBModuleVersion = "2.1.3.528"
$CosmosDBModuleVersion = Get-Module CosmosDB | Where-Object { $_.Version.ToString() -eq $MinCosmosDBModuleVersion }
if (!$CosmosDBModuleVersion) {
    Write-Verbose "Minimum module version is not imported."
    if (!(Get-InstalledModule CosmosDB -MinimumVersion $MinCosmosDBModuleVersion -ErrorAction SilentlyContinue)) {
        Write-Verbose "Minimum module version is not installed."
        Install-Module CosmosDB -MinimumVersion $MinCosmosDBModuleVersion -Scope CurrentUser -Force
    }
    Import-Module CosmosDB -MinimumVersion $MinCosmosDBModuleVersion
}

# Returns an array with the indexes for a path
function CreateIncludedPathIndex ($IndexPaths) {
        $IndexRanges = @()

        foreach ($Index in $IndexPaths) {
            if ($Index.kind -eq "Spatial") {
                Write-Verbose "Creating path with Kind $($Index.kind) and DataType $($Index.dataType)"
                $IndexRanges += New-CosmosDbCollectionIncludedPathIndex -Kind $Index.kind -DataType $Index.dataType
            }
            elseif ($Index.kind -eq "Range") {
                Write-Verbose "Creating path with Kind $($Index.kind) and DataType $($Index.dataType) and Precision $($Index.precision)"
                $IndexRanges += New-CosmosDbCollectionIncludedPathIndex -Kind $Index.kind -DataType $Index.dataType -Precision $Index.precision
            }
            elseif ($Index.kind -eq "Hash") {
                Write-Verbose "Creating path with Kind $($Index.kind) and DataType $($Index.dataType) and Precision $($Index.precision)"
                $IndexRanges += New-CosmosDbCollectionIncludedPathIndex -Kind $Index.kind -DataType $Index.dataType -Precision $Index.precision
            }
        }

    return $IndexRanges
}

# get existing Cosmos DB account (call changes from AzureRM v5 to v6)
$AzureRmVersion = Get-Module AzureRM -ListAvailable | Sort-Object { $_.Version.Major } -Descending | Select-Object -First 1
Write-Verbose "Azure RM Version $AzureRmVersion"
if ($AzureRmVersion.Version.Major -gt 5) {
    $GetCosmosDbAccountParameters = @{
        Name              = $CosmosDbAccountName
        ResourceGroupName = $ResourceGroupName
        ExpandProperties  = $true
        ResourceType      = "Microsoft.DocumentDB/databaseAccounts"
    }
}
else {
    $GetCosmosDbAccountParameters = @{
        ResourceType      = "Microsoft.DocumentDb/databaseAccounts"
        ResourceGroupName = $ResourceGroupName
        ResourceName      = $CosmosDbAccountName
    }
}

$ExistingAccount = Get-AzureRmResource @GetCosmosDbAccountParameters
if (!$ExistingAccount -or $ExistingAccount.Properties.provisioningState -ne "Succeeded") {
    Write-Error "CosmosDb Account could not be found, make sure it has been deployed."
    throw "$_"
}

# get json configuration
try {
    if ($PSCmdlet.ParameterSetName -eq "AsFilePath") {
        if (!(Test-Path $CosmosDbConfigurationFilePath)) {
            Write-Error "Configuration File Path can not be found"
            throw "$_"
        }
        Write-Verbose "Reading config from $CosmosDbConfigurationFilePath"
        $CosmosDbConfigurationString = Get-Content $CosmosDbConfigurationFilePath
    }
    $CosmosDbConfiguration = $CosmosDbConfigurationString | ConvertFrom-Json
}
catch {
    Write-Error "Config deserialization failed, check JSON is valid"
    throw "$_"
}

# create database if one does not exist 
Write-Verbose "Checking for Database $($CosmosDbConfiguration.DatabaseName)"
$CosmosDbContext = New-CosmosDbContext -Account $CosmosDbAccountName -ResourceGroup $ResourceGroupName -MasterKeyType 'PrimaryMasterKey'
$ExistingDatabase = Get-CosmosDbDatabase -Context $CosmosDbContext -Id $CosmosDbConfiguration.DatabaseName -ErrorAction SilentlyContinue

if (!$ExistingDatabase) {
    Write-Output "Creating Database: $($CosmosDbConfiguration.DatabaseName)"
    $ExistingDatabase = New-CosmosDbDatabase -Context $CosmosDbContext -Id $CosmosDbConfiguration.DatabaseName
}

# loop through collections
foreach ($Collection in $CosmosDbConfiguration.Collections) {
    Write-Verbose "Checking for $($Collection.CollectionName)"
    $ExistingCollection = Get-CosmosDbCollection -Context $CosmosDbContext -Database $CosmosDbConfiguration.DatabaseName -Id $Collection.CollectionName -ErrorAction SilentlyContinue

    $NewCosmosDbCollectionParameters = @{
        Context         = $CosmosDbContext
        Database        = $CosmosDbConfiguration.DatabaseName
        Id              = $Collection.CollectionName
        OfferThroughput = $Collection.OfferThroughput
    }

    if (!$ExistingCollection) {
        Write-Output "Creating Collection: $($Collection.CollectionName) in $($CosmosDbConfiguration.DatabaseName)"

        if ($Collection.IndexingPolicy) {

            # create a list of included paths for indexing
            $IndexIncludedPaths = @()
            foreach ($IndexPath in $Collection.IndexingPolicy.includedPaths) {
                Write-Verbose "Creating indexed path $($IndexPath.path)"
                $IndexRanges = CreateIncludedPathIndex($IndexPath.indexes)
                if ($IndexRanges) {
                    $IncludePath = New-CosmosDbCollectionIncludedPath -Path $IndexPath.path -Index $IndexRanges
                }
                else {
                    $IncludePath = New-CosmosDbCollectionIncludedPath -Path $IndexPath.path
                }
                $IndexIncludedPaths += $IncludePath
            }

            # create a list of excluded paths not to index
            $IndexExcludedPaths = @()
            foreach ($ExcludedPath in $Collection.IndexingPolicy.excludedPaths) {
                Write-Verbose "Creating excluded path $($excludedPath.path)"
                $IndexExcludedPaths += New-CosmosDbCollectionExcludedPath -Path $excludedPath.path
            }

            Write-Verbose "Adding indexing policy: included paths - $($IndexIncludedPaths.count), excluded paths - $($IndexExcludedPaths.count)"
            $NewCosmosDbCollectionParameters['IndexingPolicy'] = New-CosmosDbCollectionIndexingPolicy -Automatic $Collection.IndexingPolicy.automatic -IndexingMode $Collection.IndexingPolicy.indexingMode -IncludedPath $IndexIncludedPaths -ExcludedPath $IndexExcludedPaths
            $test = $NewCosmosDbCollectionParameters.IndexingPolicy | ConvertTo-Json
            Write-Verbose $test
        }

        if ($Collection.PartitionKey) {
            $NewCosmosDbCollectionParameters['PartitionKey'] = $Collection.PartitionKey
            Write-Verbose "Partion key $($NewCosmosDbCollectionParameters.PartitionKey)"
        }
        else {
            Write-Verbose "Fixed collection size"
        }

        if ($Collection.DefaultTtl) {
            $NewCosmosDbCollectionParameters['DefaultTimeToLive'] = $Collection.DefaultTtl
            Write-Verbose "Added Time To Live (TTL) of $($NewCosmosDbCollectionParameters.DefaultTimeToLive)"
        }

        Write-Output "Creating collection in Account - $($CosmosDbContext.Account), Database: $($CosmosDbConfiguration.DatabaseName)"
        New-CosmosDbCollection @NewCosmosDbCollectionParameters
    }
    else {
        # TODO: Can we check and modify if something changes
        Write-Verbose "$($Collection.CollectionName) exists"
    }
}
