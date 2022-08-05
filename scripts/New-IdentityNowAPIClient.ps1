function New-IdentityNowAPIClient {
    <#
.SYNOPSIS
Create an IdentityNow v2 API Client for use with a Virtual Appliance.

.DESCRIPTION
Create an IdentityNow v2 API Client for use with a Virtual Applicance.

.PARAMETER clusterId
(required) The VA Cluster ID that the v2 Creds will be used for.

.EXAMPLE
New-IdentityNowAPIClient -clusterId 111

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$clusterId
    )

    $v3Token = Get-IdentityNowAuth

    if ($v3Token.access_token) {
        try {             
                $IDNAPIClient = Invoke-RestMethod -Method Post -Uri  (Get-IdentityNowOrgUrl cc "/client/create?clusterId=$($clusterId)&type=VA") -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Content-Type" = "application/json" }
                return $IDNAPIClient            
        }
        catch {
            Write-Error "Create API Client failed. $($_)" 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
        return $v3Token
    } 
}

