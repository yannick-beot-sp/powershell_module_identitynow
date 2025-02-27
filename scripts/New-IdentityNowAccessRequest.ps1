function New-IdentityNowAccessRequest {
    <#
.SYNOPSIS
Submit Access Request


.LINK
https://developer.sailpoint.com/docs/api/v3/create-access-request

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string[]]$requestedFor,
        
        [string][ValidateSet("GRANT_ACCESS", "REVOKE_ACCESS")]
        [Parameter(Mandatory = $false)]
        [string] $RequestType,
        
        [Parameter(Mandatory = $true)]
        [Array]
        $requestedItems,
        
        $ClientMetadata
    )

    Write-Verbose "> Invoke-IdentityNowRequest"
    try {
        Invoke-IdentityNowRequest -method POST -path "access-requests" -api V3 -body  @{
            requestedFor   = $requestedFor
            clientMetadata = $ClientMetadata
            requestType    = $RequestType
            requestedItems = $requestedItems
        }
    }
    catch {
        Write-Error "Could not get Outliers from $uri. $($_)"
        throw $_ 
    }


}
