<#
.SYNOPSIS
Adds an APIM API to an APIM Product and configures the logger for that API.

.DESCRIPTION
Adds an APIM API to an APIM Product and configures the logger for that API.

.PARAMETER ApimResourceGroup
The name of the resource group that contains the APIM instnace

.PARAMETER InstanceName
The name of the APIM instance

.PARAMETER ApiId
The ApiId within APIM of the API to update, sometimes referred to as the Api Name in release settings

.PARAMETER ApiProductId
The ApiProductId within APIM of the Product to add the API to.  This is different to the display name (it cannot contain spaces, the display name can)

.PARAMETER ApimLoggerName
The name of the APIM logger that will be attached to the API.  This is different to the Application Insights instance, they can be created together with the apim-logger.json ARM template

.EXAMPLE
Set-ApimProductAndLogger -ApimResourceGroup dfc-foo-shared-rg -InstanceName dfc-foo-shared-apim -ApiId barapi -ApiProductId bar-product -ApimLoggerName bar-logger
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [String]$ApimResourceGroup,
    [Parameter(Mandatory=$true)]
    [String]$InstanceName,
    [Parameter(Mandatory=$true)]
    [String]$ApiId,
    [Parameter(Mandatory=$true)]
    [String]$ApiProductId,
    [Parameter(Mandatory=$false)]
    [String]$ApimLoggerName
)

$Context = New-AzApiManagementContext -ResourceGroupName $ApimResourceGroup -ServiceName $InstanceName

Write-Verbose "Adding api $ApiId to product $ApiProductId"
try {

    # this cmdlet returns no output, there is no cmdlet to Get products and their apis
    Add-AzApiManagementApiToProduct -Context $Context -ProductId $ApiProductId -ApiId $ApiId

}
catch {

    throw $_

}

if ($ApimLoggerName) {

    $ApiDiagnostics = Get-AzApiManagementDiagnostic -Context $Context -ApiId $ApiId
    if ($ApiDiagnostics.LoggerId -eq $ApimLoggerName) {

        Write-Output "Apim Logger $($ApiDiagnostics.LoggerId) is already attached to api $ApiId, no change"

    }
    elseif (!$ApiDiagnostics) {

        Write-Output "Diagnostics for $ApiId are currently not set, setting to $ApimLoggerName"
        New-AzApiManagementDiagnostic -Context $Context -LoggerId $ApimLoggerName -ApiId $ApiId -DiagnosticId applicationinsights

    }
    else {

        Write-Output "Logger for $ApiId is currently: $($ApiDiagnostics.LoggerId), setting to $ApimLoggerName"
        Set-AzApiManagementDiagnostic -Context $Context -LoggerId $ApimLoggerName -ApiId $ApiId -DiagnosticId applicationinsights

    }

}
else {

    Write-Verbose "No ApimLogger specified, not setting"

}
