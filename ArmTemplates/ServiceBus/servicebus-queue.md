# ServiceBus Qeueue

Creates a Queue for an existing ServiceBus.

## Parameters

serviceBusNamespaceName: (required) string

Name of an existing ServiceBus to create the topic in.

serviceBusQueueName: (required) string

Name of the Queue to add to Service Bus

MessageLockDuration: (optional) string

The time period that a message is locked from being received by other clients.
Use the ISO 8601 duration format - P(n)Y(n)M(n)DT(n)H(n)M(n)S - to specify the period.
Defaults to 1 minute - i.e. PT1M - if not specified.

MaxSizeInMegabytes: (optional) int

The maximum size, in Mb, for the queue.
Defaults to 1024Mb (i.e. 1Gb) if not specified.

EnableDuplicateDetection: (optional) bool

If true, enables duplicate message detection on the queue.
Defaults to false.

EnableSessions: (optional) bool

If true, enables session support on the queue.
Defaults to false.

EnableDeadLettering: (optional) bool

If true, enables the dead lettering of messages that have exceeded their delivery count.
Defeaults to true.

MaxDeliveryCount:

The maximum number of delivery attempts before a message is considered expired.
Defaults to 10
