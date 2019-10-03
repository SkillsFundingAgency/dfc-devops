<#
.SYNOPSIS
Copys current database to new database release version

.DESCRIPTION
Copys the current database to a new database release version.
The copied database has -r999 tagged at the end, where 999 is the release number.

.PARAMETER ServerName
SQL server name (or FQDN).
If a period is found in the server name it will assume a FQDN.

.PARAMETER DatabaseName
The database name to use as the source.
Either this can be specified or an app service name can be specified.

.PARAMETER AppServiceName
Name of the App Service to get the database name from.
Gets the database name from the app settings
Either this can be specified or the database name passed in directly.

.PARAMETER DatabaseNameAppSetting
[Optional] Name of the app setting that contains the database name.
Defaults to reading the DatabaseVersion app setting if not specified.

.PARAMETER ReleaseNumber
[Optional] Release number for the new database.
Defaults to the first part (before the first dash) of environment variable RELEASE_RELEASENAME if not passed.
Eg. if environment variable RELEASE_RELEASENAME was set to 123-release this would default to 123

.PARAMETER RetentionDays
[Optional] The Point In Time Retention (PITR) period in days
Defaults to 35 if not set

.EXAMPLE
Copy-Database -ServerName dfc-foo-bar-sql -AppServiceName dfc-foo-bar-as

#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory = $true)]
    [String]$ServerName,
    [Parameter(Mandatory = $true, ParameterSetName = "FromParam")]
    [String] $DatabaseName,
    [Parameter(Mandatory = $true, ParameterSetName = "FromAppService")]
    [String] $AppServiceName,
    [Parameter(Mandatory = $false, ParameterSetName = "FromAppService")]
    [String] $DatabaseNameAppSetting = "DatabaseVersion",
    [Parameter(Mandatory = $false)]
    [ValidateRange(1, [int]::MaxValue)]
    [int] $ReleaseNumber,
    [Parameter(Mandatory = $false)]
    [ValidateRange(7, 35)]
    [int] $RetentionDays = 35
)

try {
    if ($ServerName.IndexOf(".") -gt 0) {
        # extract short name from fqdn
        $ServerName = $ServerName.Substring(0, $ServerName.IndexOf("."))
    }

    # retrieve server resource
    Write-Verbose "Searching for server resource $ServerName"
    $ServerResource = Get-AzResource -Name $ServerName -ResourceType "Microsoft.Sql/servers" -ErrorAction SilentlyContinue
    if (!$ServerResource) {
        throw "Could not find server resource $ServerName"
    }
    
    if ($PSBoundParameters.ContainsKey("AppServiceName")) {
        # get database name from App Service

        # first check App Service exists
        Write-Verbose "Searching for app service $AppServiceName"
        $AppServiceResource = Get-AzResource -Name $AppServiceName -ResourceType "Microsoft.Web/sites" -ErrorAction SilentlyContinue
        if (!$AppServiceResource) {
            throw "Could not find app service with name $AppServiceName"
        }

        # then read in app settings from App Service
        $AppService = Get-AzWebApp -ResourceGroupName $AppServiceResource.ResourceGroupName -Name $AppServiceName
        $DatabaseName = ($AppService.SiteConfig.AppSettings | Where-Object {$_.Name -eq $DatabaseNameAppSetting}).Value
        if (!$DatabaseName) {
            $AppSettingPairs = "App settings"
            foreach ($val in $AppService.SiteConfig.AppSettings) { $AppSettingPairs += "; $($val.name) = $($val.value)" }
            throw "Could not determine current database version from $DatabaseNameAppSetting setting. $AppSettingPairs"
        }
    }

    # check for source db
    $SourceDatabase = Get-AzSqlDatabase -ResourceGroupName $ServerResource.ResourceGroupName -ServerName $ServerName -DatabaseName $DatabaseName -ErrorAction SilentlyContinue
    Write-Verbose "Searching for current database $DatabaseName"
    if (!$SourceDatabase) {
        throw "Could not find current database $DatabaseName"
    }

    # set build number if it is not provided
    if (!$PSBoundParameters.ContainsKey("ReleaseNumber")) {
        $ReleaseNumber = $ENV:RELEASE_RELEASENAME.Split("-")[0]
    }

    # determine if the database name contains a release number (ends in -r999 where 999 is any number)
    $RegexMatch = [Regex]::Match($DatabaseName, "\-[rR]([0-9]+)$")
    if ($RegexMatch.Success -eq "True") {
        # remove the version number leaving just the database name
        $DatabaseNameGenesis = $DatabaseName.Substring(0, $DatabaseName.LastIndexOf("-"))
    } else {
        $DatabaseNameGenesis = $DatabaseName
    }

    $CopyDatabaseName = "$DatabaseNameGenesis-r$ReleaseNumber"

    # check for existing db with the same name $CopyDatabaseName
    $ExistingDatabaseCopy = Get-AzSqlDatabase -ResourceGroupName $ServerResource.ResourceGroupName -ServerName $ServerName -DatabaseName $CopyDatabaseName -ErrorAction SilentlyContinue
    if (!$ExistingDatabaseCopy) {
        # copy db
        Write-Output "Copying $DatabaseName to $CopyDatabaseName"

        $DatabaseCopyParameters = @{
            ResourceGroupName = $ServerResource.ResourceGroupName
            ServerName        = $ServerName
            DatabaseName      = $DatabaseName
            CopyDatabaseName  = $CopyDatabaseName
        }
        if ($SourceDatabase.SkuName -eq "ElasticPool") {
            $DatabaseCopyParameters.ElasticPoolName = $SourceDatabase.ElasticPoolName
        }

        $StopWatch = [System.Diagnostics.StopWatch]::StartNew()
        $CopiedDatabase = New-AzSqlDatabaseCopy @DatabaseCopyParameters
        Set-AzSqlDatabaseBackupShortTermRetentionPolicy -ResourceGroupName $CopiedDatabase.ResourceGroupName -ServerName $CopiedDatabase.ServerName -DatabaseName $CopyDatabaseName -RetentionDays $RetentionDays
        $ElapsedTime = $StopWatch.Elapsed.ToString('hh\:mm\:ss')

        Write-Output "Database copy completed in $ElapsedTime"   
    } else {
        Write-Output "A database copy with name $CopyDatabaseName exists. Skipping"
    }

    # return values as Azure DevOps variables
    Write-Output "##vso[task.setvariable variable=CurrentDatabaseName;]$($DatabaseName)"
    Write-Output "##vso[task.setvariable variable=CopyDatabaseName;]$($CopyDatabaseName)"
}
catch {
    throw $_
}