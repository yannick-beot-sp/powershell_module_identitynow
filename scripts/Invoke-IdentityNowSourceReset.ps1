function Invoke-IdentityNowSourceReset {
    <#
.SYNOPSIS
    Reset an IdentityNow Source.

.DESCRIPTION
    Reset an IdentityNow Source.

.PARAMETER Source
    Source object as returned by Get-IdentityNowSource

.PARAMETER SourceID
    (required) The ID of an IdentityNow Source. eg. 45678

.EXAMPLE
    Invoke-IdentityNowSourceReset -sourceID 12345

.EXAMPLE
    Reset a Source but leave the entitlements
    Invoke-IdentityNowSourceReset -sourceID 12345 -skip entitlements

.EXAMPLE
    Reset a Source but leave the entitlements
    Invoke-IdentityNowSourceReset -sourceID 12345 -skip accounts

.EXAMPLE
    Get-IdentityNowSource -name "Active Directory" | Invoke-IdentityNowSourceReset -Wait

.EXAMPLE
    Get-IdentityNowSource -name Linkedin | Invoke-IdentityNowSourceReset -Wait

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName="source")]
        $Source,
        [Parameter(Mandatory = $true, ParameterSetName="ID")]
        [int]$SourceID,

        [Parameter(Mandatory = $false)]
        [ValidateSet("accounts", "entitlements", IgnoreCase = $true)]
        [string]$Skip,

        [switch]$Wait
    )
    Begin {
        $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{"Authorization" = "Bearer $($v3Token.access_token)" }
    
    }
    Process {
        if ($Source) {
            $SourceID = $Source.connectorAttributes.cloudExternalId
        }
        Write-Verbose "SourceID=$SourceID"

        $url = "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/source/reset/$sourceID"
        if ($skip) {
            $url = $url | Set-HttpQueryString -Name "skip" -Value $skip
        }

        try {
            $reset = Invoke-RestMethod -Method POST -uri $url -Headers $headers
            Write-Verbose "Task=$($reset | Out-String)"
            if (-not $Wait.IsPresent) {
                return $reset
            }
            Wait-IdentityNowJob -sourceID $SourceId -JobType "SOURCE_RESET" -TaskId $reset.id
            
        }
        catch {
            Write-Error "Could not reset source $SourceId $($_)"
            throw $_
        }
    }
}
