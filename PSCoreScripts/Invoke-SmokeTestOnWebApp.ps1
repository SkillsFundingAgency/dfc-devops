﻿param(
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
        return $result.StatusCode -eq 200
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
        $Path = "/$($Path)"
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

    Write-Verbose "Running smoke test against $($site),  attempt $($attemptCount)/$($AttemptsBeforeFailure)"

    $wasSuccessful = Invoke-SingleSmokeTest -Url $siteUrl -TimeoutInSecs $TimeoutInSecs

    if($attemptCount -ge $AttemptsBeforeFailure) {
        throw "Smoke test exhausted all retry attempts and is still not responding"
    }

    if(-not $wasSuccessful) {
        Write-Verbose "Smoke test was not successful, sleeping before retrying."
        Start-Sleep -Seconds $BackOffPeriodInSecs
    }
}
while($wasSuccessful -eq $false) 