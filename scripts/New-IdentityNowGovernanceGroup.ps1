function New-IdentityNowGovernanceGroup {
    <#
.SYNOPSIS
    Create a new IdentityNow Governance Group.

.DESCRIPTION
    Create a new IdentityNow Governance Group.

.PARAMETER group
    The Governance Group details.

.EXAMPLE
    New-IdentityNowGovernanceGroup 

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$group
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {          
            $IDNNewGroup = Invoke-RestMethod -Method Post -Uri (Get-IdentityNowOrgUrl v2 "/workgroups?&org=$($IdentityNowConfiguration.orgName)") -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" } -Body $group
            return $IDNNewGroup              
        }
        catch {
            Write-Error "Failed to create group. Check group details. $($_)" 
        }
    }
}
