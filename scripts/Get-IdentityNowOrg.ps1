function Get-IdentityNowOrg {
    <#
.SYNOPSIS
    Displays the default Uri value for all or a particular Organisation based on configured OrgName.

.DESCRIPTION
    Displays the default Uri value for all or a particular Organisation based on configured OrgName.

.EXAMPLE
    Get-IdentityNowOrg 

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow
#>

    [CmdletBinding()]
    param ()
    if ($IdentityNowConfiguration.orgName) {
        if ($IdentityNowConfiguration.apiUrl) {
            $apiUrl = $IdentityNowConfiguration.apiUrl
        }
        else {
            $apiUrl = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/"
        }
        $apiUrl = $apiUrl.TrimEnd('/')

        if ($IdentityNowConfiguration."Organisation URI") {
            $orgUrl = $IdentityNowConfiguration."Organisation URI"
        }
        else {
            $orgUrl = "https://$($IdentityNowConfiguration.orgName).identitynow.com/"
        }
        $orgUrl = $orgUrl.TrimEnd('/')

        $identityNowOrg = [ordered]@{
            "Organisation Name"    = $IdentityNowConfiguration.orgName;
            "Organisation URI"     = $orgUrl;
            apiUrl                 = $apiUrl;
            "v1 Base API URI"      = "$orgUrl/api";
            "v2 Base API URI"      = "$apiUrl/v2";
            "v3 Base API URI"      = "$apiUrl/v3";
            "Private Base API URI" = "$apiUrl/cc/api";
            "Beta"                 = "$apiUrl/beta";
        }
        return $identityNowOrg
    }
    else {
        Write-Warning "No Organisation name held in configuration."
    }
}