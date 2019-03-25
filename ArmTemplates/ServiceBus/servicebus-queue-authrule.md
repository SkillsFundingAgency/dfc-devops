# ServiceBus Queue Authorizarion Rule

Creates and authorization rule for a ServiceBus Queue.

## Parameters

authorizationRuleName: (required) string

Name of the rule.

queueName: (required) string

Name of the queue the rule will be added to.

rights: (required) string

Array of rights to be assigned to the rule.  Rights are limited to Manage, Send, Listen.

servicebusName: (required) string

Name of the ServiceBus the queue is in.