# Container Instance

Creates an Azure Container Group containing a single Azure Container Instance based on an Image from an Azure Container Registry.  If you require a Container Group with multiple Container Instances then a custom template should be constructed.  Note that the restart policy defaults to Never rather than the Azure default of Always.

## Parameters

containerName (required) string

Name of the Container Instance

appContainerRegistryImage (required) string

Name of the Image that will be used to create the Container.  Needs to be the full name of the Image, eg foosharedcr.azurecr.io/bar-app:latest

containerRegistryPassword (required) securestring

Password to the Container Registry

containerRegistryServer (required) string

Server name of the Container Registry

containerRegistryUsername (required) string

Usename of the Container Registry

cpu (required) int

The number of vCPU cores assigned to the Container Instance.

memoryInGb (required) string

The amount of memory assigned to the Container Instance.  Value can be either an int or a decimal (a number in ARM terminology).  Parameter type is string so that both can be accomodated.

environmentVariables  (optional) secureObject

An object that has a single property (variables) whose value is an array of Name \ Value pairs.  The Value of each pair can either be a "value" or a "secureValue".  Documentation on environment variables can be found here: https://docs.microsoft.com/en-us/azure/templates/microsoft.containerinstance/2018-10-01/containergroups#EnvironmentVariable

Example environmentVariables parameter:

````
        "environmentVariables": {
            "value": {
                "variables": [
                    {
                        "name": "foo",
                        "value": "bar"
                    },
                    {
                        "name": "secretfoo",
                        "secureValue": "$3cr3tbar"
                    }
                ]
            }
        }
````

restartPolicy (optional) string

The default value is Never which is overriden from the Azure default of Always.  Containers within this environment are intended to be used for adhoc or occassional jobs, where a permanently available resource is required Azure PaaS services should be the first choice.