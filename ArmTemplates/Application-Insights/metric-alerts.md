# Metric Alerts

Create an azure monitor metric alert on a resource

There are two types of criterion for a metric alert: static threshold and dynamic threshold, with the difference being that a dynamic threshold "learns" the usual behaviour for the application and alerts on deviation from that baseline, and allows you to have a single alert for multiple metrics at once.

This template hard codes the criterion to be a "static" threshold.

## Parameters

enabled (optional)

Sets the state of the metric alert. If true (the default), the alert is enabled.   If false, the alert is disabled.

alertName (required)

A name for the alert

alertSeverity (optional)

The severity of alert to raise.
This defaults to 3 if not defined.

metricName (required)

The name of the azure monitor metric for the alert to query. 
A list of these are available [here](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported).

operator (optional)

An operator for the comparison with the `threshold`.
This defaults to `GreaterThan` if not otherwise defined

dimensions (optional)

A list of dimensions to pass to the metrics query.

An example of this would be to only alert for a given type of status code: 

```json
"dimensions": [
  {
     "name": "StatusCode",
     "operator": "Include",
     "values": [  "429"  ]
   }
]
```

More information can be found in the [documentation](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/2018-03-01/metricalerts)

Defaults to an empty array

threshold (optional)

The value used (with operatior) to compute whether an alert is activated.
This defaults to `0` if not otherwise specified.

aggregation (optional)

The aggregation used by the metric.
This defaults to `Average` if not otherwise defined.
The correct aggregation to use will be documented on the "supported metrics" page above.

windowSize (optional)

The period of time to check monitor metrics over, in ISO8601 format.
Defaults to `PT5M` (check over the last 5 minutes)

evaluationFrequency (optional)

The frequencyt of the evaluation of the alert expression, in ISO8601 format.
Defaults to `PT1M` (ie: check every 1 minute)

actionGroupName (required)

The name of the action group to use to trigger the alert.

resourceId (required)

A full resource identifier of the resource to monitor.
