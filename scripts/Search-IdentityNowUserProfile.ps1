function Search-IdentityNowUserProfile {
    <#
.SYNOPSIS
Get an IdentityNow Users Identity Profile.

.DESCRIPTION
Get an IdentityNow Users Identity Profile from a query

.PARAMETER query
(required) User Search Query

.PARAMETER limit
(optional) Search Limit e.g 10

.EXAMPLE
Search-IdentityNowUserProfile -query "12345"

.EXAMPLE
Search-IdentityNowUserProfile -query darrenjrobinson

.EXAMPLE
Search-IdentityNowUserProfile -query "darren.robinson"

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$query,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$limit = 250
    )


    try {    
        $utime = [int][double]::Parse((Get-Date -UFormat %s))                     
        # Get User Profiles Based on Query
        $userProfiles = Invoke-IdentityNowRequest -API CC -path "/user/list?_dc=$($utime)&listErrorFirst=true&useSds=true&start=0&limit=$($limit)&sorters=%5B%7B%22property%22%3A%22name%22%2C%22direction%22%3A%22ASC%22%7D%5D&filters=%5B%7B%22property%22%3A%22username%22%2C%22value%22%3A%22$($query)%22%7D%5D" -json
        return $userProfiles.items
    }
    catch {
        Write-Error "Bad Query. Check your query. $($_)" 
    }
}

