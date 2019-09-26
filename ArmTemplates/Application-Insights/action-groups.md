# Action Groups

Creates an Azure Monitor action group.
At least one of the emailAddress and webHookUrl properties must be specified, otherwise the action group will not be created or updated.

## Parameters

actionGroupName (required)

A name for the action group.  This has to follow our naming conventions!
This reason for this is because internally, an actionGroup's name can only be 12 characters in length,  so we attempt to get the project's name and truncate it to 12 characters to give the best name for the action group as possible

emailAddress  (optional)

The email address to send alerts to

webHookUrl (optional)

The URL of a webhook to send alerts to

enabled (optional)

Sets the state of the action group. If true (the default), the action group is enabled.  If false, the alert is disabled.
