# ServiceBus Topic

Creates a Topic for an existing ServiceBus.

## Parameters

serviceBusNamespaceName: (required) string

Name of an existing ServiceBus to create the topic in.

serviceBusTopicName: (required) string

Name of the Topic to add to Service Bus

messageDefaultTTL: (optional) string

The default time to live (TTL) to apply to messages if not specified on the message itself.
Use the ISO 8601 duration format - P(n)Y(n)M(n)DT(n)H(n)M(n)S - to specify the period.
Defaults to 90 days - i.e. P90D - if not specified.

topicMaxSizeMb: (optional) int

The maximum size, in Mb, for the topic.
Defaults to 1024Mb (i.e. 1Gb) if not specified.
