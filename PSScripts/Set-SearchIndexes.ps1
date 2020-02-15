<#
.SYNOPSIS
Creates or modifies Azure Search index

.DESCRIPTION
Ensures an Azure Search index matches the supplied json document.

.PARAMETER SearchName
Azure Search name

.PARAMETER ResourceGroupName
Resource group the Azure Search belongs to

.PARAMETER IndexFilePath
Full path to the json file including file name (use either this or IndexConfigurationString)

.PARAMETER IndexConfigurationString
JSON configuration (use either this or IndexFilePath)

.EXAMPLE
Set-SearchIndexes -SearchName dfc-foo-sch -ResourceGroupName dfc-foo-rg -IndexFilePath C:\path\to\index.json

#>

param(
    [Parameter(Mandatory=$true)]
    [string] $SearchName,
    [Parameter(Mandatory=$true)]
    [string] $ResourceGroupName,
    [Parameter(Mandatory = $true, ParameterSetName = "AsString")]
    [string]$IndexConfigurationString,
    [Parameter(Mandatory = $true, ParameterSetName = "AsFilePath")]
    [string] $IndexFilePath
)

Import-Module $PSScriptRoot\..\PSModules\AzureApiFunctions

try {
    if ($PSCmdlet.ParameterSetName -eq "AsFilePath") {
        if (!(Test-Path $IndexFilePath)) {
            Write-Error "Configuration File Path can not be found"
            throw "$_"
        }
        $IndexConfiguration = Get-Content $IndexFilePath | ConvertFrom-Json
    }
    elseif ($PSCmdlet.ParameterSetName -eq "AsString") {
        $IndexConfiguration = $IndexConfigurationString | ConvertFrom-Json
    }
}
catch {
    Write-Error "Config deserialization failed, check JSON is valid"
    throw "$_"
}

$SearchParams = @{
    ResourceType      = "Microsoft.Search/searchServices"
    ResourceGroupName = $ResourceGroupName
    ResourceName      = $SearchName
    ApiVersion        = '2015-08-19'
}
$SearchResource = Get-AzureRmResource @SearchParams

$Url = "https://$($SearchResource.name).search.windows.net/indexes"

$SearchParams = @{
    Action     = 'listAdminKeys'
    ResourceId = $SearchResource.ResourceId
    ApiVersion = '2015-08-19'
    Force      = $true
}
$SearchResourceKeys = Invoke-AzureRmResourceAction @SearchParams

foreach ($Index in $IndexConfiguration) {
    try {
        $ExistingIndex = ApiRequest -Method GET -Url "$Url/$($Index.name)" -ApiKey $SearchResourceKeys.PrimaryKey
    }
    catch {
        # index does not exist
        Write-Host "Creating index $($Index.name)"
        ApiRequest -Method POST -Url $Url -ApiKey $SearchResourceKeys.PrimaryKey -Body $Index
        continue
    }

    # index exists
    Write-Verbose "Checking index $($Index.name)"
    $ExistingFieldNames = $ExistingIndex.fields.name
    $UpdateIndex = $false
    $UpdatedFields = @()

    foreach ($i in $ExistingIndex.fields) {
        $UpdatedFields += @{
            name = $i.name
            type = $i.type
            key = $i.key
            searchable = $i.searchable
            filterable = $i.filterable
            retrievable = $i.retrievable
            sortable = $i.sortable
            facetable = $i.facetable
            indexAnalyzer = $i.indexAnalyzer
            searchAnalyzer = $i.searchAnalyzer
            analyzer = $i.analyzer
        }
    }

    foreach ($i in $Index.fields) {
        if ($i.name -notin $ExistingFieldNames) {
            Write-Verbose "Adding $i"
            $UpdateIndex = $true
            $UpdatedFields += $i
        }
    }

    if ($UpdateIndex) {
        Write-Host "Updating index $($Index.name)"
        $UpdatedIndex = @{
            fields = $UpdatedFields
        }
        ApiRequest -Method PUT -Url "$Url/$($Index.name)" -ApiKey $SearchResourceKeys.PrimaryKey -Body $UpdatedIndex
    }

}