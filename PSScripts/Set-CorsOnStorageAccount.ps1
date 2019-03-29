<#

.SYNOPSIS
Sets CORS rules on storage account

.DESCRIPTION
Sets (replaces existing) CORS rules on a storage account if the origins being set doesn't already exist

.PARAMETER StorageAccountName
Name of storage account

.PARAMETER StorageAccountKey
Access key for storage account

.PARAMETER AllowedOrigins
Array of allowed origins

.PARAMETER MaxAge
Optionally set the max age to cache requests in seconds (defaults to 1 hours)

.EXAMPLE
Set-CorsOnStorageAccount -StorageAccountName dfcfoobarstr -StorageAccountKey not-a-real-key= -AllowedOrigins foo.example.org

#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)]
    [string] $StorageAccountName,
    [Parameter(Mandatory = $true)]
    [string] $StorageAccountKey,
    [Parameter(Mandatory = $true)]
    [string[]] $AllowedOrigins,
    [Parameter(Mandatory = $false)]
    [string] $MaxAge = 3600
)

Write-Verbose "Setting Storage Context on $StorageAccountName"
$StorageContext = New-AzureStorageContext -StorageAccountName $StorageAccountName.ToLower() -StorageAccountKey $StorageAccountKey
$ExistingCorsRules = Get-AzureStorageCORSRule -ServiceType Blob -Context $StorageContext

$CORSRules = @()
$CORSChanged = $false

# Create CORS object
foreach ($AllowedOrigin in $AllowedOrigins) {
    Write-Verbose "Checking origin $AllowedOrigin"

    $CORSRules += @{
        AllowedHeaders  = @( "*" )
        AllowedOrigins  = @( "$($AllowedOrigin.ToLower())" )
        MaxAgeInSeconds = $MaxAge
        AllowedMethods  = @( "GET", "HEAD", "OPTIONS" )
    }

    # Set CORSChanged to true if origin not already set
    $CORSChanged = $CORSChanged -or ($AllowedOrigin.ToLower() -notin $ExistingCorsRules.AllowedOrigins)
}

if ($CORSChanged) {
    # Rule has been added, set CORS Rules
    try {
        Write-Output "Setting CORS rule on $($StorageContext.BlobEndPoint)"
        Set-AzureStorageCORSRule -ServiceType Blob -CorsRules $CORSRules -Context $StorageContext
    }
    catch {
        throw "Failed to get Storage Context and set CORS settings: $_"
    }
}
