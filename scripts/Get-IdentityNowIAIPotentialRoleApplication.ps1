function Get-IdentityNowIAIPotentialRoleApplication {
    <#
.SYNOPSIS
Retrieves Applications for a potential role in a role mining session

.PARAMETER SessionId
Session Id for this role mining session

.PARAMETER PotentialRoleId
A potential role id in a role mining session


.EXAMPLE 
Get-IdentityNowIAIPotentialRoleApplication -SessionId "a7b5c6f3-025b-4c99-a55b-42736b441499" -PotentialRoleId "a7e5c6f3-025b-4c99-a55b-42736b441479"
#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$SessionId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$PotentialRoleId
    )
    $uri = Get-IdentityNowOrgUrl Beta "/role-mining-sessions", $SessionId, "potential-roles", $PotentialRoleId, 'applications'  


    try {
        Write-Verbose "Get Potential Role Applications from $uri"
        Get-IdentityNowPaginatedCollection -uri $uri `
            -TypeName "IdentityNow.PotentialRoleApplication" 
    }
    catch {
        Write-Error "Could not get Potential Role Applications $uri. $($_)"
        throw $_ 
    }
}
