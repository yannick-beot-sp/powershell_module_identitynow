function New-IdentityNowSourceSchema {
    <#
.SYNOPSIS
Create a schema for a source.

.PARAMETER id
Id of the source

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$id, 
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$schema
    )
    $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
    
    try {

        $uri = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/sources/$id/schemas"
        $response = Invoke-RestMethod -Uri $uri -Method Post `
            -Body $schema `
            -ContentType 'application/json' `
            -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
        $response.PSObject.TypeNames.Insert(0, "IdentityNow.Schema")
        return $response
    }
    catch {
        Write-Error "Creation of new Source failed. Check Source Configuration. $($_)" 
    }
}
    
