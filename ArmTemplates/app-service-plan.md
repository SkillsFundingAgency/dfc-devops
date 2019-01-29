# App Service Plan

Creates an App Service Plan

## Paramaters

appServicePlanName: (required) string

Name of App Service Plan. Will be created in the same resource group as the script is run and in the default location for resource group.

nonASETier: (optional) string

Underlying server type for app service plan.
Can be either Basic, Standard, Premium or PremiumV2.
Will default to Standard if not supplied.
If aseHostingEnvironmentName is specified, the tier is Isolated and the value supplied for the parameter is ignored.

aspSize: (optional) string

Underlying server size per instance.
Can be either 1, 2 or 3 equating to small, medium or large.
Will default to 1 if not supplied.

aspInstances: (optional) integer

The number of instances.
For the Basic tier, value can be between 1 and 3.
For the Standard tier, value can be between 1 and 10.
For the other tiers, value can be between 1 and 20.
Will default to 1 if not supplied.

aseHostingEnvironmentName: (optional) string

Name of the App Service Environment (ASE) to assign the app service plan to.
If not specified, the app service plan will not be assigned to an ASE.

aseResourceGroup: (optional) string

Resource group the App Service Environment belongs to.
Only required if aseHostingEnvironmentName specified.
