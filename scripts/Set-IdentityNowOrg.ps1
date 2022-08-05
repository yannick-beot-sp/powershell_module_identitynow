function Set-IdentityNowOrg {
    <#
.SYNOPSIS
    Sets the default Organisation name for an IdentityNow Tenant.

.DESCRIPTION
    Used to build the default Uri value for a particular Org. These values
    can be saved to a user's profile using Save-IdentityNowConfiguration.

.PARAMETER orgName
    The IdentityNow Organisation name. 

.EXAMPLE    
    Set-IdentityNowOrg -orgName 'MyCompany'
    Demonstrates how to set an Organisation Name value.

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow
#>

    # [CmdletBinding()]
    param (
        [parameter(Mandatory = $true,
            ValueFromPipelineByPropertyName = $true)]
        [string]$orgName
    )
    Begin {
        Write-Verbose "> $($PSCmdlet.MyInvocation.MyCommand.Name)"
    }

    process {
        $IdentityNowConfiguration.OrgName = $orgName
        if ($IdentityNowConfiguration.ContainsKey($orgName)) {
            # if tenant config already exists, use existing config
            $orgConfig = $IdentityNowConfiguration.($orgName)
        }
        else {
            # create empty config
            $orgConfig = @{
                v2                 = $null
                v3                 = $null
                AdminCredential    = $null
                PAT                = $null
                JWT                = $null
                apiUrl             = $null
                "Organisation URI" = $null
            }
        }
        # set config
        $IdentityNowConfiguration.AdminCredential = $orgConfig.AdminCredential 
        $IdentityNowConfiguration.v2 = $orgConfig.v2
        $IdentityNowConfiguration.v3 = $orgConfig.v3
        $IdentityNowConfiguration.PAT = $orgConfig.PAT
        $IdentityNowConfiguration.JWT = $orgConfig.JWT
        $IdentityNowConfiguration["apiUrl"] = $orgConfig.apiUrl
        $IdentityNowConfiguration["Organisation URI"] = $orgConfig."Organisation URI"
    }
    End {
        Write-Verbose "< $($PSCmdlet.MyInvocation.MyCommand.Name)"
    }
}