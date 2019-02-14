# Azure DevOps Templates
This folder contains yaml templates for use in Azure DevOps pipelines.  The contents are organised into two folders - Builds and Releases.  Each folder contains templates that an be consumed as a step within the build or release template within other repos.

## Naming Convention
When naming templates the following naming convention should be adhered to:

    businessArea-(project)-technology-action-(additionalInfo)

### Definitions
    businessArea: the business area or program, eg DFC or DAS
    project (optional): The project team, eg dss, findacourse, etc.  Templates should be general use where possible rather than project specific
    technology: the platform or framework this template is used with, ef dotnetframework, dotnetcore, etc
    action: a short description of the action this template will take, eg build, deploy, test
    additionalInfo (optional): any additional info related to the action or technology

### Minimum Requirements for Actions

If minimum requirements are not met the additionalInfo part of the template name should specify what has been excluded.

#### Build
A build template should:
1. Build all projects in the repo
2. Run all unit tests in the repo
3. Create an artefact that includes deployable code and any additional template files, ef ARM templates

#### Deploy
tbc

### Examples
    dfc-dotnetframework-build
    dfc-findacourse-dotnetframework-build-version