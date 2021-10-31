function Get-IdentityNowLifecycleState {
    <#
.SYNOPSIS
List or Get IdentityNow LifecyleState(s) of an Identity Profile.

.DESCRIPTION
List or Get IdentityNow LifecyleState(s) of an Identity Profile.

.PARAMETER identityProfileID
The Identity Profile ID.

.PARAMETER lifecycleStateID
The lifecycle state ID of an Identity Profile.

.EXAMPLE
Get-IdentityNowLifecycleState -identityProfileID 2c9180857c99cf2c017ca7c81176090d

.EXAMPLE
Get-IdentityNowLifecycleState -identityProfileID 2c9180857c99cf2c017ca7c81176090d -lifecycleStateID 2c9180837c99cf2c017ca7c811a1090a

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$identityProfileID,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$lifecycleStateID
    )

    $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
    $headers = @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
    if ($lifecycleStateID) {
        $uri = "$((Get-IdentityNowOrg).'v3 Base API URI')/identity-profiles/$identityProfileID/lifecycle-states/$lifecycleStateID"
    } else {
        $uri = "$((Get-IdentityNowOrg).'v3 Base API URI')/identity-profiles/$identityProfileID/lifecycle-states/"
    }
    try {

        $lifecycleStates = Invoke-RestMethod -Method Get `
            -Uri $uri `
            -Headers $headers
        # As an array, you always have the "count" property
        return $lifecycleStates | Add-Member -TypeName 'IdentityNowLifecyleState' -PassThru
    }
    catch {
        Write-Error "Identity Profile or lifecyle state  does not exist. Check Identity Profile ID or Lifecycle State ID. $($_)" 
    }
    
}