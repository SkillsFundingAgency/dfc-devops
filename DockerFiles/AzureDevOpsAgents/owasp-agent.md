# OWASP Azure DevOps Agent

An AzureDevOps agent that includes the OWASP ZAP Testing utility

## Instructions for use

From the root of this repo you can build the image locally
```
cd DockerFiles\AzureDevOpsAgents
docker build -t ncs.azuredevopsagents.owasp --file owasp-agent.Dockerfile .
```

Or you can pull the image from the dfcdevsharedcr repository
Install the az command line tools
```
az login
az acr login --name dfcdevsharedcr
docker pull dfcdevsharedcr.azurecr.io/ncs.azuredevopsagents.owasp:<tag>
```

In the Azure DevOps portal go to Organisation Settings > Agent Pools > Add Pool and add a pool called 'NCS - OWASP'.  Then go to your user profile > Personal Access Tokens > New Token and create a token with Read and Manage permissions on Agent Pools.

On a Windows host:

Open a PowerShell prompt
```
docker run -e AZP_URL=https://<yourorg>.visualstudio.com/ -e AZP_TOKEN=not-a-real-pat-token -e AZP_AGENT_NAME=OwaspAgent -e AZP_POOL=OwaspPool ncs.azuredevopsagents.owasp:<tag>
```