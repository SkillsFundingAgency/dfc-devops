# dfc-devops

[![Build status](https://sfa-gov-uk.visualstudio.com/Digital%20First%20Careers/_apis/build/status/DFC%20Shared/dfc-devops?branchName=master)](https://sfa-gov-uk.visualstudio.com/Digital%20First%20Careers/_build/latest?definitionId=1301)  

ARM templates, PowerShell modules and scripts, policies, documentation and other resources used in the DFC Azure pipelines

## ARM Templates

The ArmTemplates directory contains deployments that can be used to stand up a specific resource and can be used in the same way as nested templated.
A master template should call each template as a separate resource passing in parameters as necessary.

A sample master template and links to individual deployment documentation can be [found here](ArmTemplates/README.md).

## PowerShell Modules

The PowerShell modules directory contains helper functions used across multiple scripts.
Modules can be imported into the scripts where needed.

Module documentation can be [found here](PSModules/README.md).

## PowerShell Scripts

The PowerShell scripts directory contains scripts that can be used either in build and release definitions or from the command line.

## Tests

All PowerShell scripts and ARM templates should be covered by Pester tests.
These tests can be found in the Tests directory. 
Tests can be either acceptance tests (filename should start with an A and tests tagged as "Acceptance")
or unit tests (filename starts with a U and tests tagged as "Unit").
Code coverage for the PowerShell scripts is also generated.

There are also some generalised quality tests (filename starts with Q and tests tagged as "Quality") in the same directory.
These tests run on all groups of files of the same type and ensure standards and quality are maintained across all files checked-in.

Additional document for creating tests and details of the quality tests can be [found here](ArmTemplates/README.md).
