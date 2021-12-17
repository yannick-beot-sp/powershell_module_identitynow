function Get-IdentityNowConnectors {
    <#
.SYNOPSIS
Get a list of connectors

.DESCRIPTION
Get a list of connectors. 
It uses v1 API as it retrieves more information

.EXAMPLE
Get-IdentityNowConnectors
#>

    [CmdletBinding()]
    param()

    $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
    
    $uri = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/cc/api/connector/list"
    Write-Verbose "Get connectors from $uri"
    
        
    try {
        $response = Invoke-RestMethod -Method Get -Uri $uri `
            -ContentType "application/json" `
            -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
        $response.items | `
            ? { $_ } | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.Connector"); $_ }
    }
    catch {
        Write-Error "Could not get connectors. $($_)"
        throw $_
    } 
}
