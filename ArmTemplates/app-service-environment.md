# App Service Environment

Creates an App Service Environment.  Depends on a subnet already existing, this will need to be created seperately due to restrictions within the tenant.

## Parameters

name (required) string

Name of the App Service Environment

domainName (required) string

Name of the DNS domain that this ASE and it's child apps will be part of.

location (optional) string

Defaults to West Europe.

networkSecurityGroupAssigned (required) bool

ASE deployments should depend on an Network Security Group (NSG) deployment that configures the correct security rules on the subnet.  Add an output to the NSG template similar to the one below and consume that in this parameter.

        "assignedToSubnet": {
            "type": "bool",
            "value": "[equals(parameters('nsgName'), split(reference(resourceId(parameters('aseVNetResourceGroupName'), 'Microsoft.Network/virtualNetworks/subnets', parameters('aseVnetName'), parameters('aseSubnetName')), '2018-07-01', 'Full').properties.networkSecurityGroup.id, '/')[8])]"
        }

This will prevent the ASE from deploying if the correct NSG is not assigned to the subnet.

subnetName (required) string

Name of the subnet that this ASE will be connected to.

virtualnetworkResourceGroupName (required) string

Name of the Resource Group that holds the vnet that holds the subnet.

virtualNetworkName (required) string

Name of the vnet that contains the subnet.