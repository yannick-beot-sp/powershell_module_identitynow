function Get-IdentityNowEmailTemplate {
    <#
.SYNOPSIS
Get IdentityNow Email Template(s).

.DESCRIPTION
Get IdentityNow Email Template(s).

.PARAMETER ID
(optional) The ID of an IdentityNow Email Template.

.EXAMPLE
Get-IdentityNowEmailTemplate 

.EXAMPLE
Get-IdentityNowEmailTemplate -ID 2c91601362431b32016275b4241b08f0 

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$ID
    )

    Begin {

        $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
    }

    PROCESS {     
        try {
            if ($ID) {
                $IDNETemplate = Invoke-RestMethod -Method Get -Uri (Get-IdentityNowOrgUrl v1 "/emailTemplate/get/$($ID)") -Headers $headers                                                                                     
                return $IDNETemplate
            }
            else {
                $IDNETemplate = Invoke-RestMethod -Method Get -Uri (Get-IdentityNowOrgUrl v1 "/emailTemplate/list") -Headers $headers
                return $IDNETemplate.items
            }
        }
        catch {
            Write-Error "Email Template doesn't exist? $($_)" 
        }
    }
}
    