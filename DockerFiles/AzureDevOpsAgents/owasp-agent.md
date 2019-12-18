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

### On a Windows host:

Open a PowerShell prompt
```
docker run -e AZP_URL=https://<yourorg>.visualstudio.com/ -e AZP_TOKEN=not-a-real-pat-token -e AZP_AGENT_NAME=OwaspAgent -e AZP_POOL=OwaspPool ncs.azuredevopsagents.owasp:<tag>
```

### From an Azure DevOps agent

This image is deployed into the DFC Azure Kubernetes Service as part of the build definition for this repo.  Using the dfc-owasp Task Group you can run a test on the agent and publish the results to the Tests tab of the Release.  The command to trigger the test you wish to run can be passed in using the OwaspTestCommand parameter.  Tests can use either the zap-cli or one of the build in test scripts such as zap-baseline.  See the following links for more info [zap-cli](https://github.com/Grunny/zap-cli), [zap-baseline](https://github.com/zaproxy/zaproxy/wiki/ZAP-Baseline-Scan).

