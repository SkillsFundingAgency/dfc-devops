<#

.SYNOPSIS
Gets VSTS variables from App Service's app settings

.DESCRIPTION
Gets VSTS variables from App Service's app settings

.PARAMETER ResourceGroupName
The name of the Resource Group for the CosmosDb Account

.PARAMETER AppServiceName
Azure App Service Name

.PARAMETER AppSetting
App setting value to read

.PARAMETER VariableName
Optional variable name to store the app setting value in (defaults to App Setting name)

.EXAMPLE
Get-AppServiceAppSetting -AppServiceName dfc-foo-bar-as -AppSetting myAppSetting

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName = $ENV:ResourceGroup,
    [Parameter(Mandatory = $true)]
    [string] $AppServiceName,
    [Parameter(Mandatory = $true)]
    [string] $AppSetting,
    [Parameter(Mandatory = $false)]
    [string] $VariableName = $AppSetting
)

$AppService = Get-AzureRmWebApp -ResourceGroupName $ResourceGroupName -Name $AppServiceName

$AppSettingValue = ($AppService.SiteConfig.AppSettings | Where-Object {$_.Name -eq $AppSetting}).Value
if (!$AppSettingValue){
    Write-Error "Could not determine app setting $AppSetting"
}
else {
    Write-Output "##vso[task.setvariable variable=$VariableName]$($AppSettingValue)"
}
