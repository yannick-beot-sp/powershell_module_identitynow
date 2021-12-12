function Get-IdentityNowApplication {
    <#
.SYNOPSIS
Get IdentityNow Application(s).

.DESCRIPTION
Get IdentityNow Application(s).

.PARAMETER appID
(optional) The Application ID of an IdentityNow Application.

.PARAMETER org
(optional - Boolean) Org Default Apps.
Get-IdentityNowApplication -org $true

.EXAMPLE
Get-IdentityNowApplication 

.EXAMPLE
Get-IdentityNowApplication -appID 24184

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding(DefaultParameterSetName = "AppID")]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "AppID")]
        [Alias("Id")]
        [string]$AppID,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Org")]
        [switch]$org 
    )

    $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
    $utime = [int][double]::Parse((Get-Date -UFormat %s))
    try {
        if ($appID) {
            $uri = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/app/get/$($appID)?_dc=$($utime)"
        }
        else {
            $uri = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/app/list?&_dc=$($utime)"
            if ($org.IsPresent) {
                $uri = $uri | Set-HttpQueryString -Name "filter" -Value "org"
            }
        }

        Invoke-RestMethod -Method Get -Uri $uri `
            -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" } | `
            % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.ApplicationCC"); $_ }
    }
    catch {
        Write-Error "Application doesn't exist. Check App ID. $($_)" 
    }

}

