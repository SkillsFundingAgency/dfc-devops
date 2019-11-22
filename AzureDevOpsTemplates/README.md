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

Build templates can be stage, job or step templates.  These are stored in seperate folders.  As a general rule step templates should be created to maximise reusability.

A build template should:
1. Build a single project in the repo
2. Run the unit tests for that project
3. Create an artefact that includes deployable code and any related files for that project.  It should not include artifacts related to other projects or parts of the repo.  ie, ARM templates should be in their own artifact

#### Deploy

Deploy templates can be stage, job or step templates.  These are stored in seperate folders.  As a general rule step templates should be created to maximise reusability.

A deploy template should:
1. TBC

### Examples
    dfc-dotnetframework-build
    dfc-findacourse-dotnetframework-build-version