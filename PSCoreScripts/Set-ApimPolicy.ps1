<#
.SYNOPSIS
Apply an APIM policy at either tenant, product, API or operation scope

.DESCRIPTION
Apply an APIM policy at either tenant, product, API or operation scope

.PARAMETER ApimResourceGroup
The name of the resource group that contains the APIM instnace

.PARAMETER ApimServiceName
The name of the APIM instance

.PARAMETER PolicyFilePath
The path to the policy file.

.PARAMETER PolicyScope
The APIM scope to apply policy file.

Use value "listavailable" to return a list of all valid product, api and operation IDs available on the given service.

.PARAMETER ProductId
The APIM product id. Only required if applying policy to product scope

.PARAMETER ApiId
The APIM api id. Only required if applying policy to api scope or operation scope

.PARAMETER OperationId
The APIM operation id. Only required if applying policy to operation scope

.EXAMPLE
Set-ApimPolicy -ApimResourceGroup dfc-foo-bar-rg -ApimServiceName dfc-foo-bar-apim -ApiId bar -PolicyFilePath some-file.yaml
#>
[CmdletBinding()]
Param(
    [Parameter(Mandatory=$true)]
    [String]$ApimResourceGroup,
    [Parameter(Mandatory=$true)]
    [String]$ApimServiceName,
    [Parameter(Mandatory=$true)]
    [String]$PolicyFilePath,
    [Parameter(Mandatory=$true)]
    [ValidateSet('tenant', 'product', 'api', 'operation', 'listavailable')]
    [Switch]$PolicyScope,
    [Parameter(Mandatory=$false)]
    [String]$ProductId,
    [Parameter(Mandatory=$false)]
    [String]$ApiId,
    [Parameter(Mandatory=$false)]
    [String]$OperationId
)

$context = New-AzApiManagementContext -ResourceGroupName $ApimResourceGroup -ServiceName $ApimServiceName

switch ($PolicyScope) {
    'tenant' {
        Write-Output "Applying policy at tenant scope"

        Set-AzApiManagementPolicy -Context $Context -Format application/vnd.ms-azure-apim.policy.raw+xml -PolicyFilePath $PolicyFilePath -Verbose
    }
    'product' {
        Write-Output "Applying policy at product scope. ProductId = $ProductId"
        
        Set-AzApiManagementPolicy -Context $Context -Format application/vnd.ms-azure-apim.policy.raw+xml -PolicyFilePath $PolicyFilePath -ProductId $ProductId -Verbose
    }
    'api' {
        Write-Output "Applying policy at api scope. ApiId = $ApiId"
        
        Set-AzApiManagementPolicy -Context $Context -Format application/vnd.ms-azure-apim.policy.raw+xml -PolicyFilePath $PolicyFilePath -ApiId $ApiId -Verbose
    }
    'operation' {
        Write-Output "Applying policy at operation scope. ApiId = $ApiId, OperationId = $OperationId"
        
        Set-AzApiManagementPolicy -Context $Context -Format application/vnd.ms-azure-apim.policy.raw+xml -PolicyFilePath $PolicyFilePath -ApiId $ApiId -OperationId $OperationId -Verbose
    }
    'listavailable' {
        write-output "Products, APIs and Operations available in supplied APIM service..."

        $results = @()

        $apis = Get-AzApiManagementApi -Context $context

        foreach ($api in $apis) {

            $productId = Get-AzApiManagementProduct -Context $context -ApiId $api.ApiId | select-object ProductId

            $operations = Get-AzApiManagementOperation -Context $Context -ApiId $api.ApiId

            foreach ($operation in $operations) {

                $operationId = $operation.OperationId

                $details = [ordered]@{
                        Product_Id = $productId.ProductId
                        #Api_Name = $api.Name
                        Api_Id = $api.ApiId
                        Operation_Id = $operationId
                }

                $results += New-Object PSObject -Property $details
            }
        }

        $results | Sort-Object Product_Id, Api_Id, Operation_Id
    }
}