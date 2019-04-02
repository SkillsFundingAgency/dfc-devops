# App Service Environment

Creates an App Service Environment.  Depends on a subnet already existing, this will need to be created seperately due to restrictions within the tenant.

## Parameters

name (required) string

Name of the App Service Environment

domainName (required) string

Name of the DNS domain that this ASE and it's child apps will be part of.  A wildcard certificate will be required for this domain.  SANs will need to be added to the certificate request for *.scm.<domainName> and scm.<domainName>.  Once the ASE has been deployed the A records will need to be created on the DNS server that hosts this domain.

location (optional) string

Defaults to West Europe.

networkSecurityGroupAssigned (required) bool

ASE deployments should depend on an Network Security Group (NSG) deployment that configures the correct security rules on the subnet.  The parameter should be set using a function similar to the one below.

    [if(variables('deployAse'), equals(parameters('aseNetworkSecurityGroup'), split(reference(resourceId(parameters('aseVNetResourceGroupName'), 'Microsoft.Network/virtualNetworks/subnets', parameters('aseVnetName'), parameters('aseSubnetName')), '2018-07-01', 'Full').properties.networkSecurityGroup.id, '/')[8]), bool('false'))]

This will prevent the ASE from deploying if the correct NSG is not assigned to the subnet.

subnetName (required) string

Name of the subnet that this ASE will be connected to.

virtualnetworkResourceGroupName (required) string

Name of the Resource Group that holds the vnet that holds the subnet.

virtualNetworkName (required) string

Name of the vnet that contains the subnet.