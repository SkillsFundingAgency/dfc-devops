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

Creates a DNS "A record" that starts with the specified label and resolves to this public IP address with the Azure-provided DNS servers.
Does not create a DNS record in Azure if not provided.

As an example, if the publicDnsLabel mysite is passed in and the resource is created in West Europe then this will create a DNS entry
`mysite.westeurope.cloudapp.azure.com`.