<#
.SYNOPSIS
Starts an SSIS Integration Runtime, waiting for it to be created if necessary

.DESCRIPTION
When an instance of the SSIS runtime is created, it is created in a stopped state.
This script waits for the SSIS runtime to be created,  then starts the integration runtime

.PARAMETER ResourceGroupName
The name of the Resource Group containing the Azure Data Factory v2 instance

.PARAMETER DataFactoryName
The name of the v2 Azure DataFactory instance containing the SSIS integration runtime

.PARAMETER RuntimeName
The name of the SSIS runtime to start

.EXAMPLE
Start-SSISIntegrationRuntime.ps1 -ResourceGroupName dfc-foo-bar-rg -DataFactoryName dfc-foo-msql-df -RuntimeName ssisRuntimeName
#>

param(
    [Parameter(Mandatory=$true)]
    [string] $ResourceGroupName,
    [Parameter(Mandatory=$true)]
    [string] $DataFactoryName,
    [Parameter(Mandatory=$true)]
    [string] $RuntimeName
)

$breakStates = @("Initial", "Stopped", "Started")

Write-Host "Checking to see if integration runtime '$RuntimeName' has been created yet."
Write-Host "Will retry every 15 seconds for 10 minutes before failing..."

$attempts = 1
$runtimeInstance = $null

do {
    Write-Host "Attempting to fetching runtime instance, attempt $($attempts) of 40"
    $runtimeInstance = Get-AzureRmDataFactoryV2IntegrationRuntime -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $RuntimeName -ErrorAction SilentlyContinue

    if($attempts -eq 40)  {
        break;
    }

    if($null -eq $runtimeInstance) {
        Start-Sleep -Seconds 15
    }

    $attempts++
} while($runtimeInstance.State -inotin $breakStates)


if($null -eq $runtimeInstance) {
    Write-Error "Unable to get runtime instance after 10 minutes, giving up."
} else {
    if($runtimeInstance.State -ine "Started") {
        Write-Host "Starting up integration runtime"
        Start-AzureRmDataFactoryV2IntegrationRuntime -ResourceGroupName $ResourceGroupName -DataFactoryName $DataFactoryName -Name $RuntimeName -Force | Out-Null
        Write-Host "SSIS integration runtime started successfully!"
    } else {
        Write-Host "SSIS integration runtime is already running, no action required"
    }
}