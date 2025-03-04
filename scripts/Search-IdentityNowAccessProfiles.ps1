function Search-IdentityNowAccessProfiles {
    <#
.SYNOPSIS
    Search Access Profiles.

.DESCRIPTION
     Search Access Profiles based on query

.PARAMETER query
    (required) Access Profiles Search Query.
    
.EXAMPLE
    Search-IdentityNowAccessProfiles -query 'source.name:"Active Directory"'

.EXAMPLE
    Search-IdentityNowAccessProfiles -query "source.id:2c918083670df373016835e063ff6b5b" 

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$query
    )
    try {                         

        $body = "{`"query`":{`"query`":$( ConvertTo-Json $query)},`"indices`":[`"accessprofiles`"],`"includeNested`":false,`"sort`":[`"source.name`"]}"
        Write-Verbose "body=$body"

        $uri = Get-IdentityNowOrgUrl v3 "/search"
        Write-Verbose "Get Access Profiles from $uri"
          
        Get-IdentityNowPaginatedCollection -uri $uri `
            -Method Post `
            -sorters $sortersStr `
            -TypeName "IdentityNow.AccessProfile"
        
    }
    catch {
        Write-Error "Bad Query ? Check your query. $($_)"
        throw $_
    }
}

