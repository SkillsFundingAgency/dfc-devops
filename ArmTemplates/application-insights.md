# Application Insights

Creates an App Insights

## Paramaters

appInsightsName: (required) string

Name of App Insight. Will be created in the same resource group as the script is run and in the default location for resource group.

attachedService: (optional) string

The app service (web app) the App Insight is monitoring.
This is just used as a tag.
If no attachedService is supplied, the tag is not created.
