# Azure Monitor alerts to Slack function app

Creates a series of resources for hosting an Azure function that acts as a gateway between Azure Monitor and Slack.
It creates:

* A consumption-based App Service Plan
* A function app
* An App Insights instance for the function app

## Paramaters

instanceBaseName:  (required)  string

The base name used for the connection and the logic app.

storageConnectionString:  (required) string

The connection string for a storage account for storing webjob logs etc.

slackWebHookToken: (required) string

The token (ie: everything after https://hooks.slack.com/services/) for the incoming webhook on Slack.

slackChannelName: (required) string

The name of the channel (without the leading #) that you want the function to post Azure Monitor alert messages to

## Outputs

WebhookUrl:  

The full url for the webhook.
Place this value into the Azure Monitor alert group's webhook receiver url.
