# Network

Creates a virtual network with subnets and routing table for use with apps, ase or managed resources.

## Paramaters

virtualNetworkPrefix: (required) string

Prefix for the virtual network resources. Usually of the form dfc-env-proj

virtualNetworkAddressPrefix: (optional) string

First 2 octects of VNet Private IP address range (VNet prefix).
The VNet will always be created with a 16-bit network mask (ie the last two octets will always be 0.0)
Will default to 10.0 if not supplied.

Must but one of
* 10.x (class A)
* 172.16-31 (class B)
* 192.168 (class C)

virtualNetworkRoutedSubnets: (optional) array of strings

List of additional subnets with require the routing table to create in the VNet.
All subnets will have 8-bit network masks, created in the order specified starting with 0.0/24.

virtualNetworkNonRoutedSubnets: (optional) array of strings

List of additional subnets which should not be routed to create in the VNet.
These will be created in order after the virtualNetworkRoutedSubnets.
Subnet size and mask will be same as virtualNetworkRoutedSubnets.

### Notes

You must supply at least one subnet, either virtualNetworkRoutedSubnets or virtualNetworkNonRoutedSubnets, or the template will error.
Total number of routed and non-routed subnets must not exceed 255.
