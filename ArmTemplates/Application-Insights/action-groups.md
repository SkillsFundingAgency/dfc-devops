# Action Groups

## Introduction

This ARM template creates an action group in the current resource group.


## Parameters


| Parameter Name | Purpose     |
| -------------- | ----------- |
| actionGroupName | A name for the action group.  This has to follow our naming conventions! |
| emailAddress  | The email address to send alerts to |
| environment | The environment that we're deploying to |

## Gotchas

The actionGroupName parameter has to follow our naming conventions!

This is because internally, an actionGroup's name can only be 12 characters in length,  so internally we attempt to get the project's name and truncate it to 12 characters to give the best namne for the action group as possible
