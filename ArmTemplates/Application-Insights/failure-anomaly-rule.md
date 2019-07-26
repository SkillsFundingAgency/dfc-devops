# Failure Anomaly Rule

Creates an Failure Anomaly v2 rule on an App Insights resource

## Parameters

name (required)

The name for the failure anomaly rule

enabled (optional)

Sets the state of the action group. If true (the default), the action group is enabled.  If false, the alert is disabled.

severity (optional)

The severity for the alert rule. If not supplied,  defaults to 2.

frequency (optional)

The frequency to perform the failure anomaly checks, in ISO 8601 duration format. Defaults to PT1M.
Note that some frequencies may not be supported by the resource (ie: PT5M currently is not).

resourceId (required)

The full resourceId to the application insights instance used as a source for failure anomalies.

actionGroupId (required)

The full resourceId to the action group to trigger when an alert is raised.
