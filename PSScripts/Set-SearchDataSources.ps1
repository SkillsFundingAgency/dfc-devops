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
Set-SearchDataSources -SearchName dfc-foo-sch -ResourceGroupName dfc-foo-rg -IndexFilePath C:\path\to\index.json

#>

[CmdletBinding()]
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
        $DataSourceConfiguration = Get-Content $IndexFilePath | ConvertFrom-Json
    }
    elseif ($PSCmdlet.ParameterSetName -eq "AsString") {
        $DataSourceConfiguration = $IndexConfigurationString | ConvertFrom-Json
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

$Url = "https://$($SearchResource.name).search.windows.net/datasources"

$SearchParams = @{
    Action     = 'listAdminKeys'
    ResourceId = $SearchResource.ResourceId
    ApiVersion = '2015-08-19'
    Force      = $true
}
$SearchResourceKeys = Invoke-AzureRmResourceAction @SearchParams

foreach ($DataSource in $DataSourceConfiguration) {
    try {
        Write-Verbose "Checking if datasource $($DataSource.name) exists"
        ApiRequest -Method GET -Url "$Url/$($DataSource.name)" -ApiKey $SearchResourceKeys.PrimaryKey
    }
    catch {
        # index does not exist
        Write-Host "Creating datasource $($DataSource.name)"
        ApiRequest -Method POST -Url $Url -ApiKey $SearchResourceKeys.PrimaryKey -Body $DataSource
        continue
    }
}