function Remove-IdentityNowAccessProfile {
    <#
.SYNOPSIS
Delete an IdentityNow Access Profile.

.DESCRIPTION
Delete an IdentityNow Access Profile.

.PARAMETER Id
(required) The access profile ID of the IdentityNow Access Profile to delete.

.EXAMPLE
Remove-IdentityNowAccessProfile -profileID 2c9180886cd58059016d18a52bd50951

.EXAMPLE
$ExistingAPs = Get-IdentityNowAccessProfile
$myAP = $ExistingAPs | Where-Object {$_.name -like "*My Access Profile*"}
Remove-IdentityNowAccessProfile -profileID $myAP.id

.EXAMPLE
Get-IdentityNowAccessProfile | ? {$_.source.id -eq "2c9140857e542d2f017e67137adb56f5"} | Remove-IdentityNowAccessProfile

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("profileID")]
        [string]$Id
    )
    Begin {
        $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"}
        
    }
    Process {
        try {   
            $uri = (Get-IdentityNowOrg).Beta + "/access-profiles/" + $Id
            Invoke-RestMethod -Method Delete -Uri $uri -Headers $headers
        }
        catch {
            Write-Error "Deletion of Access Profile $Id failed. Check Access Profile ID. $($_)"
            throw $_
        }
    }
}
