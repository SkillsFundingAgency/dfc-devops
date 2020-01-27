<#
.SYNOPSIS
Copies a Sitefinity database as part of blue-green deployment

.DESCRIPTION
Looks at the web app to get the current production version of the Sitefinity database and copies that with the latest release number

.PARAMETER AppServiceName
Name of the app service; this should have an app setting called DatabaseVersion

.PARAMETER ServerName
The name of the SQL server (accepts name or FQDN)

.PARAMETER ReleaseNumber
[Optional] release number; looks for an environment variable RELEASE_RELEASENAME if not specified

.EXAMPLE
Copy-SitefinityDatabase -AppServiceName someApp -ServerName someSQLserver
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [String] $AppServiceName,
    [Parameter(Mandatory = $true)]
    [String] $ServerName,
    [Parameter(Mandatory = $false)]
    [String] $ReleaseNumber
)

# if fqdn passed in, extract name part
if ($ServerName.Contains('.')) {
    $ServerName = $ServerName.Substring(0, $ServerName.IndexOf("."))
    Write-Verbose "Using SQL server name $($ServerName)"
}

# retrieve SQL server resource
Write-Verbose "Searching for server resource $($ServerName)"
$SqlServerResource = Get-AzResource -Name $ServerName -ResourceType "Microsoft.Sql/servers" -ErrorAction SilentlyContinue
if (!$SqlServerResource) {
    throw "Could not find SQL server $($ServerName)"
}

# extract the build number if it is not provided
if (!$PSBoundParameters.ContainsKey("ReleaseNumber")) {
    if ($ENV:RELEASE_RELEASENAME) {
    $ReleaseNumber = $ENV:RELEASE_RELEASENAME.Split("-")[0]
    Write-Verbose "Using release number $ReleaseNumber"
    } else {
        throw "Cannot find environment variable RELEASE_RELEASENAME and no ReleaseNumber passed in"
    }
}

# --- Get the database version that is currently being used in production from the app settings
Write-Verbose "Searching for app service $AppServiceName"
$AppServiceResource = Get-AzResource -Name $AppServiceName -ResourceType "Microsoft.Web/sites" -ErrorAction SilentlyContinue
if (!$AppServiceResource) {
    throw "Could not find app service $AppServiceName"
}

Write-Verbose "Getting app settings"
$AppService = Get-AzWebApp -ResourceGroupName $AppServiceResource.ResourceGroupName -Name $AppServiceName
$DatabaseVersionAppSetting = ($AppService.SiteConfig.AppSettings | Where-Object { $_.Name -eq "DatabaseVersion" }).Value
if (!$DatabaseVersionAppSetting) {
    throw "Could not determine current database version from DatabaseVersion app setting"
}

Write-Verbose "Checking current settings of database $DatabaseVersionAppSetting"
$currentDatabase = Get-AzSqlDatabase -ResourceGroupName $SqlServerResource.ResourceGroupName -ServerName $ServerName -DatabaseName $DatabaseVersionAppSetting -ErrorAction SilentlyContinue
if (!$currentDatabase) {
    throw "Could not find the current database $DatabaseVersionAppSetting"
}

# determine if the database name in the app settings has a version and remove if so, make new name with the given version
$versionedDatabaseName = [Regex]::Match($DatabaseVersionAppSetting, "(?i)R(?-i)[0-9]").Success
if ($versionedDatabaseName -eq "True") {
    $DatabaseName = $DatabaseVersionAppSetting.Substring(0, $DatabaseVersionAppSetting.LastIndexOf("-"))
}
else {
    $DatabaseName = $DatabaseVersionAppSetting
}
$CopyDatabaseName = "$($DatabaseName)-r$($ReleaseNumber)"

# check for existing db matching $CopyDatabaseName
$databaseCopyAlreadyExists = Get-AzSqlDatabase -ResourceGroupName $SqlServerResource.ResourceGroupName -ServerName $ServerName -DatabaseName $CopyDatabaseName -ErrorAction SilentlyContinue
if (!$databaseCopyAlreadyExists) {
    # --- Execute copy
    Write-Output "Copying $($DatabaseVersionAppSetting) to $($CopyDatabaseName)"
    $DatabaseCopyParameters = @{
        ResourceGroupName = $SqlServerResource.ResourceGroupName
        ServerName        = $ServerName
        DatabaseName      = $DatabaseVersionAppSetting
        CopyDatabaseName  = $CopyDatabaseName
    }
    if ($currentDatabase.SkuName -eq 'ElasticPool') {
        $DatabaseCopyParameters['ElasticPoolName'] = $currentDatabase.ElasticPoolName
    }
    $StopWatch = [System.Diagnostics.StopWatch]::StartNew()
    $null = New-AzSqlDatabaseCopy @DatabaseCopyParameters
    $ElapsedTime = $StopWatch.Elapsed.ToString('hh\:mm\:ss')
    Write-Output "Database copy completed in $ElapsedTime"
}
else {
    Write-Output "A database copy with name $CopyDatabaseName exists. Skipping"
}

# --- Always return environment variables to vsts
Write-Output "##vso[task.setvariable variable=CurrentDatabaseName;]$($DatabaseVersionAppSetting)"
Write-Output "##vso[task.setvariable variable=CopyDatabaseName;]$($CopyDatabaseName)"
