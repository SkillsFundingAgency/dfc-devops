# Public IP Address

Creates a public IP address

## Paramaters

ipAddressName: (required) string

Name for the public IP address resource

ipAddressSku: (required) string

The SKU for the public IP address.
Must be either Basic or Standard.

allocationMethod: (required) string

The way Azure allocates the IP address.
If the SKU is Basic this can be either Static or Dynamic.
If the SKU is Standard this must be Static

publicDnsLabel: (optional) string

