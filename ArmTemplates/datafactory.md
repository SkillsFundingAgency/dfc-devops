# Data Factory

Creates an Azure Data Factory.  Optionally an Azure DevOps or GitHub repo can be added for source controlling the definitions of linked services, pipelines, etc.  Alternatively Azure DataFactory Mode (ADM) can be used, this is the default if no Azure DevOps (VSTS) or GitHub parameters are supplied.  There are drawbacks to both integrated source control options so the recommended approach is ADM.

## Parameters

DataFactoryName: (required) string

Name of the data factory. Must be globally unique.

DataFactoryLocation: (optional) string

Location of the data factory. Currently, only East US, East US 2, and West Europe are supported.  Template defaults to West Europe.

GitHubAccountName: (optional) string

The GitHub repo will first need to be configured from the Data Factory GUI so that Azure Data Factory can be added to the GitHub organisation as an authorized OAuth app.
The ARM configuration is required to ensure that subsequent deployments do not remove the repo from the Data Factory.  At present it doesn't appear possible to limit the Data Factory access to specific repos.

VstsAccountName: (optional) string

The Azure DevOps organsation name, can be obtained from Organization settings > Overview.  The Azure DevOps organization will need to be connected to an AAD tenant.  
WARNING: This will remove access for all existing accounts.

VstsProjectName: (optional) string

The name of the Azure DevOps project that will contain the git repo used for the Data Factory source control.

RepositoryName: (optional) string

The name of the GitHub or Azure DevOps git repo.  The repo will need to already exist and be initialized.