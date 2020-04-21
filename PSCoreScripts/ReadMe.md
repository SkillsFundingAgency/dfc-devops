# Tests

PowerShell scripts and ARM templates should be covered by [Pester tests](https://github.com/pester/Pester).
All the tests can be run by the `Invoke-AcceptanceTests.ps1` script.

## Unit tests

Unit tests for granularly testing functions.
They are often used when you know what output or operation should happen for a given input(s).
PowerShell scripts are often tested using unit tests.

Unit tests should follow this naming convention `Uxxx.dirname.filebeingtested.Tests.ps1`,
where xxx is a number (eg 001), dirname is the directory of the filebeingtested.

## Acceptance tests

Acceptance tests the whole works as expected. 
ARM templates are often tested using acceptance tests.

Acceptance tests should follow this naming convention `Axxx.dirname.filebeingtested.Tests.ps1`,
where xxx is a number (eg 001), dirname is the directory of the filebeingtested.

## Quality tests

Generalised tests that enforce a minimum level of quality around code.
They do not test funtionality but rather all files have an agreed structure,
are correctly formatted (in the case of XML or JSON files),
have a minimum amount of documentation or the code follows best practice.

Quality tests should follow this naming convention `Qxxx.dirname.typeoftest.Tests.ps1`,
where xxx is a number (eg 001), dirname is the directory where the file types being tested are stored.

We have the following quality tests

### PSScripts Help

Ensures all PowerShell scripts in the PSScripts directory have a documented help
(the section at the start enclosed by `<# ... #>`)
with a synopsis, description and at lease one example section.

### PSScripts Quality

Uses [PSScriptAnalyzer](https://github.com/PowerShell/PSScriptAnalyzer)
to ensure all PowerShell scripts in the PSScripts directory follow best practices.

### ApimPolices XML

Ensures all the XML files in the ApimPolicies directory are correctly formatted.
Does this by attempting to read the file in and fails any that cannot be parsed.
