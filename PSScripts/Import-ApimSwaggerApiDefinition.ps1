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

.PARAMETER ApiPath
(optional) The URL suffix that APIM will apply to the API URL.  If this has not been set via an ARM template then it must be passed in as a parameter

.PARAMETER ApiSpecificationFormat
(optional) Specify the format of the document to import, defaults to 'Swagger'.  The 'OpenApi' format is only supported when using the Az module so the UseAzModule switch must also be specified when using that format.  Setting the ApiSpecificationFormat will have no effect without this switch.

.PARAMETER SwaggerSpecificationFile
(optional)  Switch, specifies whether the swagger file should be saved to a local directory before importing in APIM.

.PARAMETER OutputFilePath
(optional)  The path to save the swagger file to if SwaggerSpecificationFile switch is used.

.PARAMETER UseAzModule
(optional)  Defaults to false.  Set this parameter to $true to use the Az cmdlets for zero downtime deployments.  This parameter can be removed at a later date when the AzureRm cmdlets are no longer required.

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
    [Parameter(Mandatory=$false)]
    [String]$ApiPath,
    [Parameter(Mandatory=$false)]
    [ValidateSet("OpenApi", "Swagger")]
    [String]$ApiSpecificationFormat = "Swagger",
    [Parameter(Mandatory=$false, ParameterSetName="File")]
    [Switch]$SwaggerSpecificationFile,
	[Parameter(Mandatory=$false, ParameterSetName="File")]
    [String]$OutputFilePath,
    [Parameter(Mandatory=$false)]
    [bool]$UseAzModule = $false
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

#if ($PSVersionTable.PSVersion -ge [System.Version]::new("6.0.0")) {
if ($UseAzModule) {

    Write-Verbose "PSVersion is $($PSVersionTable.PSVersion), executing with Az cmdlets"
    try {
        # --- Build context and retrieve apiid
        Write-Verbose "Building APIM context for $ApimResourceGroup\$InstanceName"
        $Context = New-AzApiManagementContext -ResourceGroupName $ApimResourceGroup -ServiceName $InstanceName
        Write-Verbose "Retrieving ApiId for API $ApiName"
        $Api = Get-AzApiManagementApi -Context $Context -ApiId $ApiName -ErrorAction SilentlyContinue

        if (!$Api.Path -and !$ApiPath) {

            throw "API Path is not set and has not been passed in as a parameter"

        }

        if (!$ApiPath) {

            $ApiPath = $Api.Path

        }

        # --- Import swagger definition

        if ($PSCmdlet.ParameterSetName -eq "File") {

            Write-Verbose "Updating API $InstanceName\$($Api.ApiId) from definition $($OutputFile.FullName)"
            Import-AzApiManagementApi -Context $Context -SpecificationFormat $ApiSpecificationFormat -SpecificationPath $($OutputFile.FullName) -ApiId $ApiName -Path $ApiPath -ErrorAction Stop -Verbose:$VerbosePreference

        }
        else {

            Write-Verbose "Updating API $InstanceName\$($Api.ApiId) from definition $SwaggerSpecificationUrl"
            Import-AzApiManagementApi -Context $Context -SpecificationFormat $ApiSpecificationFormat -SpecificationUrl $SwaggerSpecificationUrl -ApiId $ApiName -Path $ApiPath -ErrorAction Stop -Verbose:$VerbosePreference

        }

    }
    catch {

        throw $_

    }

}
else {

    Write-Verbose "PSVersion is $($PSVersionTable.PSVersion), executing with AzureRm cmdlets"
    try {
        # --- Build context and retrieve apiid
        Write-Verbose "Building APIM context for $ApimResourceGroup\$InstanceName"
        $Context = New-AzureRmApiManagementContext -ResourceGroupName $ApimResourceGroup -ServiceName $InstanceName
        Write-Verbose "Retrieving ApiId for API $ApiName"
        $Api = Get-AzureRmApiManagementApi -Context $Context -ApiId $ApiName

        # --- Throw if Api is null
        if (!$Api) {

            throw "Could not retrieve Api for API $ApiName"

        }

        # --- Import swagger definition

        if ($PSCmdlet.ParameterSetName -eq "File") {

            Write-Verbose "Updating API $InstanceName\$($Api.ApiId) from definition $($OutputFile.FullName)"
            Import-AzureRmApiManagementApi -Context $Context -SpecificationFormat "Swagger" -SpecificationPath $($OutputFile.FullName) -ApiId $($Api.ApiId) -Path $($Api.Path) -ErrorAction Stop -Verbose:$VerbosePreference

        }
        else {

            Write-Verbose "Updating API $InstanceName\$($Api.ApiId) from definition $SwaggerSpecificationUrl"
            Import-AzureRmApiManagementApi -Context $Context -SpecificationFormat "Swagger" -SpecificationUrl $SwaggerSpecificationUrl -ApiId $($Api.ApiId) -Path $($Api.Path) -ErrorAction Stop -Verbose:$VerbosePreference

        }

    }
    catch {
       throw $_
    }

}