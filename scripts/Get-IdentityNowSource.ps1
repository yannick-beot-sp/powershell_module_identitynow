function Get-IdentityNowSource {
    <#
.SYNOPSIS
    Get IdentityNow Source(s).

.DESCRIPTION
    Gets the configuration of an IdentityNow Source(s)

.PARAMETER sourceID
    (optional) The ID of an IdentityNow Source. eg. 45678

.PARAMETER accountProfiles
    (optional) get the account profiles such as create/update profile of an IdentityNow Source.

.EXAMPLE
    Get-IdentityNowSource 

.EXAMPLE
    Get-IdentityNowSource -sourceID 12345

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>
    # DefaultParameterSetName="name" to use by default v3 API
    [cmdletbinding(DefaultParameterSetName = "name")]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "ID")]
        [ValidateNotNullOrEmpty()]
        [Alias("id")]
        [string]$sourceID,
        
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = "Name")]
        [ValidateNotNullOrEmpty()]
        [string]$name,

        [Alias("provisioning-policy")]
        [Alias("accountProfile")]
        [switch]$accountProfiles
    )
    
    $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
    $headers = @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
    $v3BaseUrl = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/sources"
    try {
        if ($PSCmdlet.ParameterSetName -eq "ID") {
            if ($sourceID -match '^\d+$') {
                Write-Verbose "Use V1 endpoint"
                if ($sourceID) {
                    if ($accountProfiles) {
                        $IDNSources = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/accountProfile/list/$($sourceID)" -Headers $headers
                    }
                    else {
                        $IDNSources = Invoke-RestMethod -Method Get -Uri "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/source/get/$($sourceID)" -Headers $headers
                    }                
                    return $IDNSources
                }
            }
            else {
                Write-Verbose "Use V3 endpoint"
                #TODO manage create profile / provisioning rule for legacy

                $uri = "$v3BaseUrl/$sourceID"

                $IDNSources = Invoke-RestMethod -Method Get -Uri $uri -Headers $headers |`
                    % { if($_) {$_.PSObject.TypeNames.Insert(0, "IdentityNow.Source"); $_ }}
                return $IDNSources
            }
        }
        else {
            #ParameterSetName -eq "Name"
            $params = @{
                uri     = $v3BaseUrl
                sorters = "name"
            }

            if ($name) {
                $filter = "name eq `"$name`""
                $params.Add("filters", $filter)
            }
            $IDNSources = Get-IdentityNowPaginatedCollection @params |`
                % { if($_) {$_.PSObject.TypeNames.Insert(0, "IdentityNow.Source"); $_ }}
            return $IDNSources

        }
    }
    catch {
        Write-Error "Source doesn't exist. $($_)" 
        throw $_
    }
}