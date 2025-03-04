function Get-IdentityNowPaginatedCollection {
    <#
.SYNOPSIS
    Returns results from collection endpoints that supports pagination.

.DESCRIPTION
    Many collection endpoints in the IdentityNow APIs support a generic syntax for paginating, filtering and sorting the results.

.PARAMETER uri
    Endpoint of the collection

.PARAMETER filters
    Any collection with a filters parameter supports filtering. 
    This means that an item will only be included in the returned array if the filters expression evaluates to true for that item. 
    Check the available request parameters for the collection endpoint you are using to see if it supports filtering.

.PARAMETER sorters
    Sorting of results is supported with the standard sorters parameter. 
    Its syntax is a set of comma-separated field names. 
    Each field name may be optionally prefixed with a "-" character, which indicates the sort is descending based on the value of that field. Otherwise, the sort is ascending.

    For example, to sort primarily by "type" in ascending order, and secondarily by "modified date" in descending order, use "type,-modified"
    
.PARAMETER pageSize
    Number of element per page. Should not exceed 250

.PARAMETER Method
    Method to use for endpoint

.PARAMETER Body
    Body if any 

.EXAMPLE
    Get-IdentityNowPaginatedCollection -uri $uri

TODO
- Manage searchAfter
- Manage aggregations
- Doc

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$uri,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$filters,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [string]$sorters,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [Microsoft.PowerShell.Commands.WebRequestMethod] $Method = 'Get',

        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        $Body,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [int]$pageSize = 250,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true)]
        [hashtable]$CustomHeaders = @{},

        [string]$TypeName,

        [int]$limit = -1
    )

    $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
    $offset = 0

    if ($filters) {
        $uri = $uri | Set-HttpQueryString -Name "filters" -Value $filters
    }
    if ($sorters) {
        $uri = $uri | Set-HttpQueryString -Name "sorters" -Value $sorters
    }

    if ($limit -gt 0 -and ($pageSize -gt $limit)) {
        $pageSize = $limit
    }
    $newUri = $uri | Set-HttpQueryString -QueryParameters @{
        limit  = $pageSize
        offset = $offset
        count  = $true
    }
    $total = -1
    $CustomHeaders.Add(
        "Authorization", "$($v3Token.token_type) $($v3Token.access_token)")

    $requestArgs = @{
        Method      = $Method 
        Uri         = $newUri
        ContentType = "application/json" 
        Headers     = $CustomHeaders
    }

    if ($body) {
        $requestArgs.Add("Body", $body)
    }
    do {
        Write-Verbose "offset=$offset"
        Write-Verbose "pageSize=$pageSize"
        $requestArgs.Uri = $newUri 

        $response = Invoke-WebRequest @requestArgs
        Write-output ($response.Content | ConvertFrom-Json | ? { $_ } | % { if ($TypeName) { $_.PSObject.TypeNames.Insert(0, $TypeName) }; $_ })
        
        if ($total -eq -1) {
            # First iteration
            $total = [int] ($response.Headers["X-Total-Count"][0])
            Write-Verbose "Total items=$total"
        }
        
        $offset += $pageSize

        if ($limit -gt 0 -and ($offset -gt $limit)) {
            $pageSize = $limit - $offset
        }


        $newUri = $uri | Set-HttpQueryString -QueryParameters @{
            limit  = $pageSize
            offset = $offset
            count  = $false
        }
    }  while ($total -gt $offset -and ($limit -eq -1 -or ($offset + $pageSize) -lt $limit))
}