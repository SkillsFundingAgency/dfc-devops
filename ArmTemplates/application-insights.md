# Application Insights

Creates an App Insights

## Paramaters

appInsightsName: (required) string

Name of App Insight. Will be created in the same resource group as the script is run and in the default location for resource group.

attachedService: (optional) string

The app service (web app) the App Insight is monitoring.
This is just used as a tag.
If no attachedService is supplied, the tag is not created.

workspaceResourceGroup: (optional) string

Only used in workspace-based application insights instances.
The name of the resource group containing the log anayltics account to be used for storage.

workspaceName: (optional) string
Only used in workspace-based application insights instances.
The name of the log anayltics account to be used for storage.
