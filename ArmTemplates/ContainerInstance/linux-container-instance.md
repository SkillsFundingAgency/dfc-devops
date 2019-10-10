# Container Instance

Creates an Azure Container Group containing a single Azure Container Instance based on an Image from an Azure Container Registry.  If you require a Container Group with multiple Container Instances then a custom template should be constructed.  Note that the restart policy defaults to Never rather than the Azure default of Always.

## Parameters

containerName (required) string

Name of the Container Instance

appContainerRegistryImage (required) string

Name of the Image that will be used to create the Container.  Needs to be the full name of the Image, eg foosharedcr.azurecr.io/bar-app:latest

cpu (required) int

The number of vCPU cores assigned to the Container Instance.

memoryInGb (required) string

The amount of memory assigned to the Container Instance.  Value can be either an int or a decimal (a number in ARM terminology).  Parameter type is string so that both can be accomodated.

containerRegistryPassword (optional) securestring

Password to the Container Registry

containerRegistryServer (optional) string

Server name of the Container Registry.  The template requires a container registry even if a private registry is not being used, the default value is therefore "hub.docker.com" even though the image registry credentials will not be used if Docker Hub is the image source.

containerRegistryUsername (optional) string

Username of the Container Registry.  The template requires a username even if a private registry is not being used, the default value is therefore "username"

environmentVariables  (optional) secureObject

An object that has a single property (variables) whose value is an array of Name \ Value pairs.  The Value of each pair can either be a "value" or a "secureValue".  Documentation on environment variables can be found here: https://docs.microsoft.com/en-us/azure/templates/microsoft.containerinstance/2018-10-01/containergroups#EnvironmentVariable

If you pass in an incorrectly formated object then the error returned will include the message "The language expression property 'variables' doesn't exist"

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

ipAddressType (optional) string

Allowed values are "Private" and "Public", defaults to "Private".  If set to "Public" an array of tcpPorts must also be passed in as a parameter.

managedIdentity (optional) bool

The default value is false.  If set to true a Managed Identity will be created in the same Resource Group and assigned to the container.

mountedVolumeMountPath (optional) string

If a storageAccountFileShareName is specified this parameter is used to specify the path within the container that the file share will be mounted to.

restartPolicy (optional) string

The default value is Never which is overriden from the Azure default of Always.  Containers within this environment are intended to be used for adhoc or occassional jobs, where a permanently available resource is required Azure PaaS services should be the first choice.

storageAccountToMount (optional) string

The storage account containing the file share that will be available to mount to the container.

storageAccountFileShareName (optional) string

The file share that will be mounted to the container.  Requires storageAccountToMount & storageAccountKey.  mountedVolumeMountPath must also be set to mount the container.

storageAccountKey (optional) securestring

The key for storage account containing the file share that will be available to mount to the container.

tcpPorts (optional) array

An array of ints that will set the port(s) exposed by the container internally within the container group and also by the container group to the internet.  Defaults to [ 0 ] to workaround the copy function limitation that errors if the copy length is 0.  Default value can be removed when this limitation is fixed (currently fixed in PowerShell but not the Azure DevOps task).