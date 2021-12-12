function Update-IdentityNowSourceSchema {
    <#
.SYNOPSIS
Update a schema for a source.

.PARAMETER SourceId
Id of the source

.PARAMETER SchemaId
Id of the schema

.PARAMETER Schema
Schema as a JSON string
#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Alias('id')]
        [string]$SourceId, 
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$SchemaId, 
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string]$Schema
    )
    $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
    
    try {

        $uri = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/sources/$SourceId/schemas/$SchemaId"
        $response = Invoke-RestMethod -Uri $uri -Method Put `
            -Body $schema `
            -ContentType 'application/json' `
            -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
        $response.PSObject.TypeNames.Insert(0, "IdentityNow.Schema")
        return $response
    }
    catch {
        Write-Error "Update of schema failed. $($_)"
        throw $_
    }
}
    
