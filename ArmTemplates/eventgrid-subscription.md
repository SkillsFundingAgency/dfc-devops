# Event Grid Subscription

Creates an Event Grid Subscription.

## Parameters

eventgridTopicName: (required) string

Name of Event Grid Topic to subscribe to.

eventgridSubscriptionName: (required) string

Name of Event Grid Subscription. Will be created in the same resource group as the script is run and in the default location for resource group.

eventGridSubscriptionUrl: (required) string

Specifies the Event Grid URL for web hook.