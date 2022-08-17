function Invoke-IdentityNowRequest {
    <#
.SYNOPSIS
Submit an IdentityNow API Request.


.PARAMETER uri
API URI

.PARAMETER path
specify the rest of the api query after the base api url as determined when picking the API variable 

.PARAMETER API
Will determine the base url
CC will use the base url https://{your org}.api.identitynow.com/cc/api/
V1 will use the base url https://{your org}.identitynow.com/api/
V2 will use the base url https://{your org}.api.identitynow.com/v2/
V3 will use the base url https://{your org}.api.identitynow.com/v3/
Beta will use the base url https://{your org}.api.identitynow.com/beta/

.PARAMETER method
HTTP Method
e.g Post, Get, Patch, Delete

.PARAMETER headers
(required) Headers for the request
Headersv2 Digest Auth with no Content-Type set 
Headersv2_JSON is Digest Auth with Content-Type set for application/json
Headersv3 is JWT oAuth with no Content-Type set 
Headersv3_JSON is JWT oAuth with Content-Type set for application/json
Headersv3_JSON-Patch is JWT oAuth with Content-Type set for application/json-patch+json

.PARAMETER body
Payload for a webrequest. If an oject is passed, it is serialized in a String

.PARAMETER json
Parse response as JSON.

.PARAMETER TypeName
For JSON output, add typename

.EXAMPLE
Invoke-IdentityNowRequest -method Get -headers Headersv2 -uri "https://YOURORG.api.identitynow.com/v2/accounts?sourceId=12345&limit=20&org=YOURORG"

.EXAMPLE
Invoke-IdentityNowRequest -method Get -headers Headersv3 -uri "https://YOURORG.api.identitynow.com/cc/api/integration/listSimIntegrations"

.EXAMPLE
Invoke-IdentityNowRequest -API Beta -path 'sources' -method get -headers Headersv3
Invoke-IdentityNowRequest -API Private -path 'source/list' -method get -headers Headersv3

.EXAMPLE
Invoke-IdentityNowRequest -API Beta -path 'sources/2c9140847578a74611727de965d91c5c' -method patch -headers Headersv3_JSON-Patch -body '[{"op":"remove","path":"/connectorAttributes/timeoutinseconds"}]'

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ParameterSetName = 'Full URL')]
        [string]$uri,
        
        [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
        [string[]]$path,
        [Parameter(Mandatory = $true, ParameterSetName = 'Path')]
        
        [string][ValidateSet("V1", "V2", "V3", "Private", "Beta", "CC")]$API,
        
        [Parameter(Mandatory = $false)]
        [Microsoft.PowerShell.Commands.WebRequestMethod] $Method = 'Get',

        [ValidateSet("HeadersV2", "HeadersV3", "Headersv2_JSON", "Headersv3_JSON", "Headersv3_JSON-Patch")]
        [string]
        $headers,
        
        $body,
        
        [switch]$json,

        [string]$TypeName
    )

    Write-Verbose "> Invoke-IdentityNowRequest"
    Write-Verbose "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"

    if ((-not $json.IsPresent) -and $TypeName) {
        throw "TypeName cannot be defined for non-Json output"
    }

    if ($PSCmdlet.ParameterSetName -eq "Path") {
        # For compatibility
        if ("Private" -eq $API) { $API = "cc" }
        $uri = Get-IdentityNowOrgUrl -endpoint $API -parts $path
    }

    if (-not $headers) {
        if ("Get" -eq $method) {
            if ("v2" -eq $API) {
                $headers = "HeadersV2"
            }
            else {
                $headers = "HeadersV3"
            }
        }
        else {
            if ("v2" -eq $API) {
                $headers = "Headersv2_JSON"
            }
            else {
                $headers = "Headersv3_JSON"
            }
        }
    }
    switch ($headers) {
        HeadersV2 { 
            $requestHeaders = Get-IdentityNowAuth -return V2Header
        }
        HeadersV3 { 
            $v3Token = Get-IdentityNowAuth -return V3JWT
            $requestHeaders = @{Authorization = "Bearer $($v3Token.access_token)" }
        }
        Headersv2_JSON { 
            $requestHeaders = Get-IdentityNowAuth -return V2Header
            $requestHeaders.'Content-Type' = "application/json" 
        }
        Headersv3_JSON { 
            $v3Token = Get-IdentityNowAuth  -return V3JWT
            $requestHeaders = @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json" }
        }
        Headersv3_JSON-Patch { 
            $v3Token = Get-IdentityNowAuth -return V3JWT
            $requestHeaders = @{Authorization = "Bearer $($v3Token.access_token)"; "Content-Type" = "application/json-patch+json" }
        }
        default { 
            $requestHeaders = $headers 
        } 
    }
    
    #Write-Verbose "requestHeaders = $($requestHeaders | Out-String)"
    Write-Verbose "Uri = $uri"
    $requestHeaders | Test-IdentityNowToken | Out-Null

    $argSplat = @{
        Method  = $method
        Uri     = $uri
        Headers = $requestHeaders
    }

    if ($body) {
        if ($body -isnot [string]) {
            $body = ConvertTo-Json -Depth 100 $body
        }
        $argSplat.add("Body", $body)
    }
    try {
        $result = Invoke-WebRequest @argSplat
        Write-Verbose "< Invoke-IdentityNowRequest"
        if ($json.IsPresent) {
            return $result.content | ConvertFrom-Json `
            | ? { $_ } | % { if ($TypeName) { $_.PSObject.TypeNames.Insert(0, $TypeName) }; $_ }
        }
        else {
            return $result.content
        }
    }
    catch {
        Write-Error "Request Failed. Check your request parameters. $($_)"
        throw $_
    }
}
