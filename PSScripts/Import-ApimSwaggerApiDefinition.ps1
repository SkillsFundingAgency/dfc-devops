<#
.SYNOPSIS
Update an APIM API with a swagger definition

.DESCRIPTION
Update an APIM API with a swagger definition

.PARAMETER ApimResourceGroup
The name of the resource group that contains the APIM instnace

.PARAMETER InstanceName
The name of the APIM instance

.PARAMETER ApiName
The name of the API to update

.PARAMETER SwaggerSpecificationUrl
The full path to the swagger defintion

.PARAMETER SwaggerSpecificationFile
(optional)  Switch, specifies whether the swagger file should be saved to a local directory before importing in APIM.

.PARAMETER OutputFilePath
(optional)  The path to save the swagger file to if SwaggerSpecificationFile switch is used.

.EXAMPLE
Import-ApimSwaggerApiDefinition -ApimResourceGroup dfc-foo-bar-rg -InstanceName dfc-foo-bar-apim -ApiName bar -SwaggerSpecificationUrl "https://dfc-foo-bar-fa.azurewebsites.net/api/bar/api-definition" -SwaggerSpecificationFile -OutputFilePath $(System.DefaultWorkingDirectory)/SwaggerFile -Verbose

#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [String]$ApimResourceGroup,
    [Parameter(Mandatory=$true)]
    [String]$InstanceName,
    [Parameter(Mandatory=$true)]
    [String]$ApiName,
    [Parameter(Mandatory=$true)]
    [String]$SwaggerSpecificationUrl,
    [Parameter(Mandatory=$false, ParameterSetName="File")]
    [Switch]$SwaggerSpecificationFile,
	[Parameter(Mandatory=$false, ParameterSetName="File")]
	[string]$OutputFilePath
)

if ($PSCmdlet.ParameterSetName -eq "File") {

    $Swagger = Invoke-RestMethod -Method GET -Uri $SwaggerSpecificationUrl -UseBasicParsing
    Write-Verbose -Message $($Swagger | ConvertTo-Json -Depth 20)

    $FunctionAppName = $SwaggerSpecificationUrl.split("/")[2].split(".")[0]
    $FileName = "$($FunctionAppName)_swagger-def_$([DateTime]::Now.ToString("yyyyMMdd-hhmmss")).json"
    Write-Verbose -Message "Filename: $FileName"

    $OutputFolder = New-Item -Path $OutputFilePath -ItemType Directory -Force
    $OutputFile = New-Item -Path "$($OutputFolder.FullName)\$FileName" -ItemType File
    Write-Verbose -Message "OutputFile: $($OutputFile.FullName)"
    Set-Content -Path $OutputFile.FullName -Value ($Swagger | ConvertTo-Json -Depth 20)

}

try {
    # --- Build context and retrieve apiid
    Write-Host "Building APIM context for $ApimResourceGroup\$InstanceName"
    $Context = New-AzApiManagementContext -ResourceGroupName $ApimResourceGroup -ServiceName $InstanceName
    Write-Host "Retrieving ApiId for API $ApiName"
    $Api = Get-AzApiManagementApi -Context $Context -ApiId $ApiName

    # --- Throw if Api is null
    if (!$Api) {

        throw "Could not retrieve Api for API $ApiName"

    }

    # --- Import swagger definition

    if ($PSCmdlet.ParameterSetName -eq "File") {

        Write-Host "Updating API $InstanceName\$($Api.ApiId) from definition $($OutputFile.FullName)"
        Import-AzApiManagementApi -Context $Context -SpecificationFormat "Swagger" -SpecificationPath $($OutputFile.FullName) -ApiId $($Api.ApiId) -Path $($Api.Path) -ErrorAction Stop -Verbose:$VerbosePreference

    }
    else {

        Write-Host "Updating API $InstanceName\$($Api.ApiId) from definition $SwaggerSpecificationUrl"
        Import-AzApiManagementApi -Context $Context -SpecificationFormat "Swagger" -SpecificationUrl $SwaggerSpecificationUrl -ApiId $($Api.ApiId) -Path $($Api.Path) -ErrorAction Stop -Verbose:$VerbosePreference

    }

}
catch {
   throw $_
}
