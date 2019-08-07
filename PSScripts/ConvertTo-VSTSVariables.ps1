<#
.SYNOPSIS
Takes ARM template output and turns them into VSTS variables

.DESCRIPTION
Takes the ARM template output (usually from the Azure Deployment task in VSTS) and creates VSTS variables of the same name with the values so they can be used in subsequent tasks.

.PARAMETER ARMOutput
The JSON output from the ARM template to convert into variables.
If using the Azure Deployment task in an Azure Pipeline, you can set the output to a variable by specifying `Outputs > Deployment outputs`.

.PARAMETER rename
[Optional] Allows you to create a VSTS variable with a different name to the output name.
Takes a dictionary where the key is the name of the ARM template output and the value is the desired name of the VSTS variable.

.EXAMPLE
ConvertTo-VSTSVariables.ps1 -ARMOutput '$(ARMOutputs)'
where ARMOutputs is the name from Outputs > Deployment outputs from the Azure Deployment task

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory=$true)][string]$ARMOutput,
    [hashtable] $Rename
)

# Output from ARM template is a JSON document
try {

    $JsonVars = $ARMOutput | ConvertFrom-Json

}
catch {

    Write-Debug "Unable to convert ARMOutput to JSON:`n$ARMOutput"
    throw "Unable to convert ARMOutput to JSON."
    
}


# the outputs with be of type noteproperty, get a list of all of them
foreach ($OutputName in ($JsonVars | Get-Member -MemberType NoteProperty).name) {
    # get the type and value for each output
    $OutputTypeValue = $JsonVars | Select-Object -ExpandProperty $OutputName
    $OutputType = $OutputTypeValue.type
    $OutputValue = $OutputTypeValue.value

    # Check if variable name needs renaming
    if ($OutputName -in $Rename.keys) {
        $OldName = $OutputName
        $OutputName = $Rename[$OutputName]
        Write-Output "Creating VSTS variable $OutputName from $OldName"
    }
    else {
        Write-Output "Creating VSTS variable $OutputName"
    }

    # Set VSTS variable
    if ($OutputType.toLower() -eq 'securestring') {
        Write-Output "##vso[task.setvariable variable=$OutputName;issecret=true]$OutputValue"
    }
    else {
        Write-Output "##vso[task.setvariable variable=$OutputName]$OutputValue"
    }
}
