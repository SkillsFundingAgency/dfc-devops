<#
.SYNOPSIS
Creates EventGrid Subscription.

.DESCRIPTION
Creates EventGrid Subscription.  The topic and function app must already exist along with their resourcegroups

.PARAMETER EventGridSubscriptionName
The EventGrid Subscription Name

.PARAMETER TopicResourceGroup
The Topic ResourceGroup

.PARAMETER Topic
The name of the Topic

.PARAMETER SubscriptionEndPoint
The name of theSubscription EndPoint

.EXAMPLE
New-EventGridSubscription -EventGridSubscriptionName EventGridSubscriptionName -TopicResourceGroup TopicResourceGroup -Topic Topic -SubscriptionEndPoint SubscriptionEndPoint
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [String]$EventGridSubscriptionName,
    [Parameter(Mandatory=$true)]
    [String]$TopicResourceGroup,
    [Parameter(Mandatory=$true)]
    [String]$Topic,
    [Parameter(Mandatory=$true)]
    [String]$SubscriptionEndPoint
)

New-AzEventGridSubscription `
    -EventSubscriptionName  $EventGridSubscriptionName `
    -ResourceGroupName $TopicResourceGroup `
    -TopicName $Topic `
    -EndpointType 'webhook' `
    -Endpoint  $SubscriptionEndPoint `
    -Verbose