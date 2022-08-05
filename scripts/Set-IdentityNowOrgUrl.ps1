function Set-IdentityNowOrgUrl {
    <#
.SYNOPSIS
    Sets the default URLs for an IdentityNow Tenant.

.DESCRIPTION
    Sets the default URLs for an IdentityNow Tenant.
    Used for non-default URL. 
    These values can be saved to a user's profile using Save-IdentityNowConfiguration.

.PARAMETER orgName
    The IdentityNow Organisation name. 

.PARAMETER orgUrl
    Organisation URL (Web portal URL). 

.PARAMETER apiUrl
    Base URL for API

.EXAMPLE    
 Set-IdentityNowOrgUrl -apiUrl  "https://mycompany.identitynow-demo.com/"

#>

    [CmdletBinding()]
    param (
        [ValidateNotNull()]
        [uri]$apiUrl,

        [ValidateNotNull()]
        [uri]$orgUrl
    )

    process {
        if ($PSBoundParameters.ContainsKey('apiUrl')) {
            Write-Verbose "Setting apiUrl"
            $IdentityNowConfiguration["apiUrl"] = $apiUrl.ToString()
        }

        if ($PSBoundParameters.ContainsKey('orgUrl')) {
            Write-Verbose "Setting orgUrl"
            $IdentityNowConfiguration["Organisation URI"] = $orgUrl.ToString()
        }
        $IdentityNowConfiguration
    }
}
