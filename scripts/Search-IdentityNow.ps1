function Search-IdentityNow {
    <#
.SYNOPSIS
    Search IdentityNow Access Profiles, Account Activities, Accounts, Aggregations, Entitlements, Events, Identities, Roles.

.DESCRIPTION
    Gets Access Profiles, Account Activities, Accounts, Aggregations, Entitlements, Events, Identities, Roles based on v3 search query

.PARAMETER query
    (required) Search Query. 

.PARAMETER limit
    (optional) Search Page Result Size

.PARAMETER indice
    (required) v3 Search Indice to search. 
    valid indices are "accessprofiles", "accountactivities", "accounts", "aggregations", "entitlements", "events", "identities", "roles"

.PARAMETER nested
    (optional) defaults to True 
    Indicates if nested objects from returned search results should be included

.EXAMPLE
    Search-IdentityNow -query "source.name:'Active Directory'" -indice "accessprofiles" -nested $false

.EXAMPLE
    Search-IdentityNow -query "source.id:2c918083670df373016835e063ff6b5b" -indice "entitlements" -nested $false

.EXAMPLE
    Search-IdentityNow -query "@accounts.entitlementAttributes.'App_Group_*'" -indice "accounts" -nested $false

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$query,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [int]$limit = 2500,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string][ValidateSet("accessprofiles", "accountactivities", "accounts", "aggregations", "entitlements", "events", "identities", "roles")]$indice,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [boolean]$nested = $true 
    )

    if ($limit -gt 10000) {
        Write-Error "Maximum search limit provided by the API is 10,000 results? Reduce your search limit parameter."
        break  
    }

    $v3Token = Get-IdentityNowAuth -return V3JWT

    if ($v3Token.access_token) {
        try {                         
            $results = $null 
            $sourceObjects = @() 
            
            switch ($indice) {
                "accessprofiles" { $body = "{`"query`":{`"query`":$( ConvertTo-Json $query )},`"indices`":[`"$($indice)`"],`"includeNested`":$($nested),`"sort`":[`"name`"]}"}
                "accountactivities" { $body = "{`"query`":{`"query`":$( ConvertTo-Json $query )},`"indices`":[`"$($indice)`"],`"includeNested`":$($nested),`"sort`":[`"id`"]}" }
                "accounts" {$body = "{`"query`":{`"query`":$( ConvertTo-Json $query )},`"indices`":[`"$($indice)`"],`"includeNested`":$($nested),`"sort`":[`"name`"]}"}
                "aggregations" {$body = "{`"query`":{`"query`":$( ConvertTo-Json $query )},`"indices`":[`"$($indice)`"],`"includeNested`":$($nested)}"}
                "entitlements" {$body = "{`"query`":{`"query`":$( ConvertTo-Json $query )},`"indices`":[`"$($indice)`"],`"includeNested`":$($nested),`"sort`":[`"source.name`"]}"}
                "events" {$body = "{`"query`":{`"query`":$( ConvertTo-Json $query )},`"indices`":[`"$($indice)`"],`"includeNested`":$($nested),`"sort`":[`"-created`"]}"}
                "identities" {$body = "{`"query`":{`"query`":$( ConvertTo-Json $query )},`"indices`":[`"$($indice)`"],`"includeNested`":$($nested),`"sort`":[`"displayName`"]}"}
                "roles" {$body = "{`"query`":{`"query`":$( ConvertTo-Json $query )},`"indices`":[`"$($indice)`"],`"includeNested`":$($nested),`"sort`":[`"name`"]}"}
                Default { $body = "{`"query`":{`"query`":$( ConvertTo-Json $query )},`"indices`":[`"$($indice)`"],`"includeNested`":$($nested),`"sort`":[`"name`"]}" }
            } 
            
            $results = Invoke-RestMethod -Method Post `
                -Uri (Get-IdentityNowOrgUrl v3 "/search?offset=0&limit=$($limit)&count=false") `
                -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; 'Content-Type' = 'application/json' } `
                -Body $body                       

            if ($results.count -gt 0) {
                $sourceObjects += $results
            } else {
                return $sourceObjects
                break
            }
            if ($results.count -gt 0 -and $results.count -lt $limit ) {
                # don't continue as we have all the results
                return $sourceObjects
                break 
            }
            else {
                $offset = 0
                do { 
                    if ($results.Count -lt $limit) {
                        # Get Next Page
                        [int]$offset = $offset + $limit 
                        $results = Invoke-RestMethod -Method Post `
                            -Uri (Get-IdentityNowOrgUrl v3 "/search?offset=$($offset)&limit=$($limit)&count=false") `
                            -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" ; 'Content-Type' = 'application/json' }  `
                            -Body $body

                        if ($results) {
                            $sourceObjects += $results
                        }
                    }
                } until ($results.Count -ge $limit)
                return $sourceObjects
            }
        }
        catch {
            Write-Error "Bad Query or more than 10,000 results? Check your query."
            Write-Error $($_) 
        }
    }
    else {
        Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret."
        Write-Error $($_)
        return $v3Token
    } 
}

