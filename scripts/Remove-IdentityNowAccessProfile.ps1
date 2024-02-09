function Remove-IdentityNowAccessProfile {
    <#
.SYNOPSIS
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
    [CmdletBinding(DefaultParameterSetName = "ID")]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ID")]
        [Alias("profileID")]
        [string]$Id,
        [Parameter(Mandatory = $true, ParameterSetName = "Bulk")]
        [Alias("AccessProfileIds")]
        [string[]]$IDs,
        [Parameter(ParameterSetName = "Bulk")]
        [switch]$BestEffortOnly
    )
    BEGIN {
        $BaseURL = Get-IdentityNowOrgUrl v3 "/access-profiles"
    }
    Process {

        if ($PSCmdlet.ParameterSetName -eq "Bulk") {
            $uri = "$BaseURL/bulk-delete"
            #https://stackoverflow.com/a/13891437
            $MAX_BULK = 50
            try {
                for ($i = 0; $i -lt $IDs.length; $i += $MAX_BULK) { 
                    $accessProfileIds = $IDs[$i .. ($i + $MAX_BULK - 1)]
                    Write-Verbose ($roleIds | Out-String)
                    Invoke-IdentityNowRequest -Uri $uri `
                        -Method POST `
                        -body @{ 
                        accessProfileIds = $accessProfileIds
                        bestEffortOnly   = $BestEffortOnly.IsPresent
                    }
                }
            }
            catch {
                Write-Error "Deletion of Roles failed. Check Role Configuration for $IDs. $($_)"
                throw $_
            }
        }
        else {
            $uri = "$BaseURL/$ID"
            Write-Verbose "uri=$uri"
            try {
                Invoke-IdentityNowRequest -Uri $uri -Method Delete
            }
            catch {
                Write-Error "Deletion of Access Profile $Id failed. Check Access Profile ID. $($_)"
                throw $_
            }
        }
    }
}
