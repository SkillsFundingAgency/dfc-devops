# API Management Logger

Creates an APIM logger that can be shared across one or more APIs.  The APIM logger will be backed by an Application Insights instance, this will also be created by this template.

The name of the App Insights instance will be formed by concatenating the APIM service name and the optional product name.

## Parameters

apimServiceName (required) string

The name of the API Management instance this logger will be attached to.

productDisplayName (optional) string

If this parameter is included it will be concatenated with the apimServiceName.

workspaceResourceGroup: (optional) string

Only used in workspace-based application insights instances.
The name of the resource group containing the log anayltics account to be used for storage.

workspaceName: (optional) string
Only used in workspace-based application insights instances.
The name of the log anayltics account to be used for storage.