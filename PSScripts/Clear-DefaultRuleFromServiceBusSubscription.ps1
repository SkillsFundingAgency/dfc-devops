<#

.SYNOPSIS
Removes the default rule from a service bus topic if it exists and there are other rules

.DESCRIPTION
Removes the default rule from a service bus topic if it exists and there are other rules

.PARAMETER ResourceGroupName
Resource Group containing the Service Bus namespace

.PARAMETER Namespace
The name of the Service Bus namespace

.PARAMETER Topic
The topic on the service bus namespace

.PARAMETER Subscription
The name of the subscription on the topic to remove the default rule from

.EXAMPLE
Clear-DefaultRuleFromServiceBusSubscription -ResourceGroupName someResourceGroup -Namespace SomeNamespace -Topic SomeTopic -Subscription SomeSubscription

#>

[CmdletBinding()]
param (
    [Parameter(Mandatory = $false)]
    [ValidateNotNullOrEmpty()]
    [string]$ResourceGroupName = $ENV:ResourceGroup,
    [Parameter(Mandatory = $true)]
    [string] $Namespace,
    [Parameter(Mandatory = $true)]
    [string] $Topic,
    [Parameter(Mandatory = $true)]
    [string] $Subscription
)

Write-Output "Getting rules for subscription"

$rules = Get-AzServiceBusRule -ResourceGroupName $ResourceGroupName `
    -Namespace $Namespace `
    -Topic $Topic `
    -Subscription $Subscription `
    -ErrorAction SilentlyContinue

$hasExtraRules = $rules.Count -gt 1
$hasDefaultRule = ($rules | Where-Object { $_.Name -eq '$Default' }).Count -gt 0

if($hasExtraRules -and $hasDefaultRule) {
    Write-Output "Subscription has default rule in combination with one set elsewhere, clearing."

    Remove-AzServiceBusRule  -ResourceGroupName $ResourceGroupName `
    -Namespace $Namespace `
    -Topic $Topic `
    -Subscription $Subscription `
    -Name '$Default'

    Write-Output "Default rule cleared."
} else {
    Write-Output "Nothing to do!"
}