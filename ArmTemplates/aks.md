# Azure Kubernetes Service

Creates Azure Kubernetes Service

## Parameters

clusterName (required) string

The name of the Managed Cluster resource.

dnsServiceIp (required) string

kubernetesVersion (required) string

The version of Kubernetes.

nodeResourceGroup (required) string

The name of the resource group used for nodes

rbacClientAppId (required) string

rbacServerAppId (required) string

rbacServerAppSecret (required) securestring

rbacTenantId (required) string

serviceCidr (required) string

servicePrincipalClientId (required) string

servicePrincipalSecret (required) securestring

subnetName (required) string

Subnet name that will contain the aks CLUSTER

virtualNetworkName (required) string

Name of an existing VNET that will contain this AKS deployment.

virtualNetworkResourceGroup (required) string

Name of the existing VNET resource group

agentNodeCount (optional) int

The number of nodes for the cluster.  Defaults to 3, minimum of 1, maximum of 50.

agentPoolName (optional) string

The name of the default agent pool.  Defaults to 'agentpool'.

agentVMSize (optional) string

The sku of the machines that will be used for the default agentpool.  Defaults to 'Standard_DS2_v2'.

dockerBridgeCidr (optional) string

Defaults to 172.17.0.1/16

logAnalyticsResourceGroupName (optional) string

The name of the resource group for log analytics.  Defaults to "", by default a Log Analytics Workspace is not required.

logAnalyticsWorkspaceName (optional) string

The name of the log analytics workspace that will be used for monitoring.  Defaults to "", by default a Log Analytics Workspace is not required.

podCidr (optional) string

Defaults to 10.244.0.0/16

