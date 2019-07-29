# Azure Monitor alerts to Slack logic app

Creates a logic app that exposes a web hook that allows Azure Monitor to push alerts to a given slack channel.

## Paramaters

instanceBaseName:  (required)  string

The base name used for the connection and the logic app.

slackChannel:  (required) string

The slack channel to send alerts to, which must start with a # character.

## Outputs

WebHookURI:  

This contains the url of the generated webhook to send azure monitor alerts to.

## Notes

Please note that after deploying this resource, you will need to visit the portal to authorise the logic app to post to slack.  This is a limitation of the current implementation, and cannot be worked around.

To authorise the conncetion, in the portal, browse to the resource group that the logic app was deployed to.
In there, a resource called `instanceBaseName`-cn will have been created.
Open this and you should see a banner saying "This connection is not authenticated".
Click on this and you will be taken to a page that contains an "Authorize" button.
