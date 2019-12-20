[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [String]$PathToTransformationFile = "/zap/wrk/owasp-to-nunit3.xlst",
    [Parameter(Mandatory=$false)]
    [String]$PathToInputReport = "/zap/wrk/OWASP-ZAP-Report.xml",
    [Parameter(Mandatory=$false)]
    [String]$PathToOutputReport = "/zap/wrk/Converted-OWASP-ZAP-Report.xml"
)

$XslTransform = New-Object System.Xml.Xsl.XslCompiledTransform
$XslTransform.Load($PathToTransformationFile)
$XslTransform.Transform($PathToInputReport, $PathToOutputReport)