function Get-IdentityNowApplicationAccessProfile {
    <#
.SYNOPSIS
Get IdentityNow Access Profile(s) of an application.

.DESCRIPTION
Get IdentityNow Access Profile(s) of an application.
If the count is equal to 0, it is not possible to know if the application has no associated access profile 
or if the application id does not correspond to an existing application.

.PARAMETER appID
The Application ID of an IdentityNow Application.

.EXAMPLE
Get-IdentityNowApplicationAccessProfile -appID 24184

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$appID
    )

    $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken

    try {
        $utime = [int][double]::Parse((Get-Date -UFormat %s))
        $accessProfiles = Invoke-RestMethod -Method Get `
            -Uri (Get-IdentityNowOrgUrl cc "/app/getAccessProfiles/$($appID)?_dc=$($utime)") `
            -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
        # As an array, you always have the "count" property
        return $accessProfiles.items
    }
    catch {
        Write-Error "Application doesn't exist. Check App ID. $($_)" 
    }
    
}
