function Search-IdentityNowIdentities {
    <#
.SYNOPSIS
    Search IdentityNow Identitie(s) using Elasticsearch queries.

.DESCRIPTION
    Search IdentityNow Identitie(s) using Elasticsearch queries.

.PARAMETER filter
    (required - JSON) filter 
    Elasticsearch Query Filter 
    e.g '{"query":{"query":"@access(type:ENTITLEMENT AND name:*FILE SHARE*)"},"includeNested":true}'
    See https://community.sailpoint.com/t5/Admin-Help/How-do-I-use-Search-in-IdentityNow/ta-p/76960 

.PARAMETER searchLimit
    (optional - default 2500) number of results to return

.EXAMPLE
    $queryFilter = '{"query":{"query":"@access(type:ENTITLEMENT AND name:*FILE SHARE*)"},"includeNested":true}'
    Search-IdentityNowIdentities -filter $queryFilter 

.EXAMPLE
    Search-IdentityNowIdentities -filter $queryFilter -searchLimit 50
    Search-IdentityNowIdentities -filter $queryFilter -searchLimit 5001

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [Alias("filter")]
        [string]$Query,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$searchLimit = -1,
        
        [string[]]$Sorters = @("name"),

        [string[]]$Fields,

        [switch]$IncludeNested

    )

    try {
        $body = @{
            indices = @(
                "identities"
            )
            query   = @{
                query=$Query
            }
        }

        if ($Fields) {
            $body["query"].Add("fields", $Fields)
        }

        if($Sorters) {
            $body.Add("sort", $sorters)
        }

        $bodyStr =$body | ConvertTo-Json -Depth 100
        $uri = Get-IdentityNowOrgUrl v3 "/search"
        Write-Verbose "Get identities for $bodyStr from $uri"
        Get-IdentityNowPaginatedCollection -uri $uri -Body $bodyStr -method Post -limit $searchLimit
 
    }
    catch {
        Write-Error "Could not get Identities from $query. $($_)"
        throw $_ 
    }
}
