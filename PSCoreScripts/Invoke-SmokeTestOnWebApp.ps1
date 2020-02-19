<#
.SYNOPSIS
Perform a smoke test on a given web app

.DESCRIPTION
This script performs a smoke test on the URL a web app/function app is hosted at, appending a specified path onto the url.
The site being smoke tested must return any 2xx status code for it to be counted as valid and redirects are not followed.

.PARAMETER AppName
The name of the web/function app to smoke test

.PARAMETER ResourceGroup
The resource group the web app is in

.PARAMETER Slot
The slot to test.
Optional, defaults to "production"

.PARAMETER Path
The path to smoke test

.PARAMETER TimeoutInSecs
A timeout for the smoke test requests.
Optional, defaults to 5 seconds

.PARAMETER BackOffPeriodInSecs
A backoff period in between smoke test requests.
Optional, defaults to 10 seconds

.PARAMETER AttemptsBeforeFailure
The number of attempts before the smoke test is marked as failing.
Optional, defaults to 5

.EXAMPLE
./Invoke-SmokeTestOnWebApp -AppName SomeWebApp -ResourceGroup SomeResourceGroup -Path /PathToTest

#>

param(
    [Parameter(Mandatory=$true)]
    [string] $AppName,
    [Parameter(Mandatory=$true)]
    [string] $ResourceGroup,
    [Parameter(Mandatory=$false)]
    [string] $Slot = "production",
    [Parameter(Mandatory=$true)]
    [string] $Path,
    [Parameter(Mandatory=$false)]
    [int] $TimeoutInSecs=5,
    [Parameter(Mandatory=$false)]
    [int] $BackOffPeriodInSecs=10,
    [Parameter(Mandatory=$false)]
    [int] $AttemptsBeforeFailure=5
)

function Invoke-SingleSmokeTest
{
    param(
        [Parameter(Mandatory=$true)]
        [string] $Url,
        [Parameter(Mandatory=$true)]
        [int] $TimeoutInSecs
    )

    try {
        Write-Verbose "Performing Invoke-WebRequest on Uri '$Url'.."
        $result = Invoke-WebRequest -Method Get -Uri $Url -MaximumRedirection 0 -TimeoutSec $TimeoutInSecs -UseBasicParsing
        return $result.StatusCode -ge 200 -and $result.StatusCode -le 299
    }
    catch {
        return $false
    }
}



function Get-SmokeTestUrl {
    param(
        [Parameter(Mandatory=$true)]
        [string] $AppName,
        [Parameter(Mandatory=$true)]
        [string] $ResourceGroup,
        [Parameter(Mandatory=$false)]
        [string] $Slot = "production",
        [Parameter(Mandatory=$true)]
        [string] $Path
    )

    $webApp = Get-AzWebAppSlot -ResourceGroupName $ResourceGroup -Name $AppName -Slot $Slot

    if(-not $Path.StartsWith("/")) {
        $Path = "/$Path"
    }

    return "https://$($webApp.DefaultHostName)$($Path)"
}


$attemptCount = 0

$siteUrl = Get-SmokeTestUrl -AppName $AppName `
    -ResourceGroup $ResourceGroup `
    -Slot $Slot `
    -Path $Path

do {
    $attemptCount++

    Write-Verbose "Running smoke test against $($siteUrl),  attempt $($attemptCount)/$($AttemptsBeforeFailure)"

    $wasSuccessful = Invoke-SingleSmokeTest -Url $siteUrl -TimeoutInSecs $TimeoutInSecs

    if(-not $wasSuccessful) {
        if($attemptCount -ge $AttemptsBeforeFailure) {
            throw "Smoke test exhausted all retry attempts and is still not responding"
        }

        Write-Verbose "Smoke test was not successful, sleeping before retrying."
        Start-Sleep -Seconds $BackOffPeriodInSecs
    }
}
while($wasSuccessful -eq $false)