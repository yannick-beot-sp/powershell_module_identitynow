function Set-IdentityNowIAIIdentityOutlier {
    <#
.SYNOPSIS
Ignore or unignore the outlier

.EXAMPLE
Set-IdentityNowIAIIdentityOutlier 2c9180968260b0860182646fa3ed1ed6 -status ignore
#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [string[]]$ids,

        [Parameter(Mandatory, Position = 1)]
        [ValidateSet("ignore", "unignore")]
        [string]$status
    )

    $uri = Get-IdentityNowOrgUrl Beta "/outliers", $status
    
    try {
        Write-Verbose "Update outliers from $uri"
        Invoke-IdentityNowRequest -method POST -uri $uri -headers Headersv3_JSON -body $ids
    }
    catch {
        Write-Error "Could not get Outliers from $uri. $($_)"
        throw $_ 
    }
}
