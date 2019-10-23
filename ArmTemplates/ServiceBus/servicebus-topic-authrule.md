# ServiceBus Topic Authorizarion Rule

Creates and authorization rule for a ServiceBus topic.

## Parameters

authorizationRuleName: (required) string

Name of the authorization rule (shared access policy)

topicName: (required) string

Name of the topic the rule will be added to

rights: (required) string

Array of rights to be assigned to the rule.  Rights are limited to Manage, Send, Listen.

servicebusName: (required) string

Name of the ServiceBus the topic is in.