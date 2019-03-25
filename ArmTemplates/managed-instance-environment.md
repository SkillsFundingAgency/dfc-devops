# KeyVault

Creates a network environment for one of the managed instances.

## Paramaters

virtualNetworkPrefix: (required) string

Prefix for the virtual network resources. Usually of the form dfc-env-proj

virtualNetworkAddressPrefix: (optional) string

First 2 octects of VNet Private IP address range (VNet prefix).
The VNet will always be created with a 16-bit network mask (ie the last two octets will always be 0.0)

Must but one of
* 10.x (class A)
* 172.16-31 (class B)
* 192.168 (class C)

virtualNetworkSubnets: (optional) array of strings

List of additional subnets to create in the VNet up to a maximum of 255.
One called default with a 0.0/24 will always be created.
All subnets will have 8-bit network masks, created in the order specified starting with 1.0/24.
