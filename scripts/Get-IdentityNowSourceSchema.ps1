function Get-IdentityNowSourceSchema {
    <#
.SYNOPSIS
    Get the Schema for an IdentityNow Source.

.DESCRIPTION
    Get the Schema for an IdentityNow Source.

.PARAMETER sourceID
    (required) The ID of an IdentityNow Source. eg. 45678

.EXAMPLE
    Get-IdentityNowSourceSchema -sourceID 12345
.EXAMPLE
    Get-IdentityNowSourceSchema -ID 2c9180877daac068017daf247d1a2445 -groupOnly
.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Id")]
        [string]$sourceID,
        [switch]$groupOnly
    )
    Begin {
        $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
    
    }
    Process {

        try {
            if ($sourceID -match '^\d+$') {
                if ($groupOnly.IsPresent) {
                    throw "Invalid arguments. 'groupOnly' switch only available for v3"
                }
                $sourceSchema = Invoke-RestMethod -method Get -uri "https://$($IdentityNowConfiguration.orgName).identitynow.com/cc/api/source/getAccountSchema/$($sourceID)" -Headers $headers
                return $sourceSchema | ? { $_ } | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.SchemaV1"); $_ }
            }
            else {
                $url = (Get-IdentityNowOrg).'v3 Base API URI' + "/sources/$sourceID/schemas"
                if ($groupOnly.IsPresent) {
                    $url = $url | Set-HttpQueryString -Name "include-types" -Value "group"
                }
                $sourceSchema = Invoke-RestMethod -method Get -uri $url -Headers $headers
                return $sourceSchema | ? {$_} | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.Schema"); $_ }
                
            }
        }
        catch {
            Write-Error "Source doesn't exist? Check SourceID. $($_)" 
        }
        
    }
}
    