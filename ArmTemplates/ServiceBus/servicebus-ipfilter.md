# Service Bus IP Filter

Creates a Service Bus IP filter

## Parameters

action (required) string

Values can be Accept or Deny

ipAddress (required) string

A single IP address from which traffic will either be accepted or denied

servicebusName (required) string

The name of the ServiceBus to apply the rule to

## Example

##TO DO

## Notes

This ARM resource is in preview (though configuring the resource via the Azure Portal is GA).  There is limited documentation, the documentation used to create this template can be found [here](https://azure.microsoft.com/en-gb/blog/ip-filtering-for-event-hubs-and-service-bus/) and more documentation can be found [here](https://docs.microsoft.com/en-us/azure/service-bus-messaging/service-bus-ip-filtering)