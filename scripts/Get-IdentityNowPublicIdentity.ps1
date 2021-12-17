function Get-IdentityNowPublicIdentity {
    <#
.SYNOPSIS
Get a list of public identities

.DESCRIPTION
Get a list of public identities

.EXAMPLE
Get-IdentityNowPublicIdentity
#>

    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(ParameterSetName = "Filter")]
        [string]$IdentityNowFilters,

        [Parameter(ParameterSetName = "ParamEq", Position = 1)]
        [string]$FieldName,

        [Parameter(ParameterSetName = "ParamEq", Position = 2)]
        [switch]$eq,

        [Parameter(ParameterSetName = "ParamEq", Position = 3)]
        [string]$FieldValue
    )


    
    $uri = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/public-identities"
    
    if ($PSCmdlet.ParameterSetName -eq "ParamEq") {
        $IdentityNowFilters = "$($FieldName.ToLower()) eq `"$FieldValue`""
    }
    if ($IdentityNowFilters) {
        $uri = Set-HttpQueryString -Uri $uri -Name "filters" -Value $IdentityNowFilters
    }
        
    try {
        Write-Verbose "Get public identities from $uri"
        Get-IdentityNowPaginatedCollection -uri $uri -sorters "name" | `
            ? {$_} | % {  $_.PSObject.TypeNames.Insert(0, "IdentityNow.PublicIdentity"); $_ }
    }
    catch {
        Write-Error "Could not get public identities. $($_)"
        throw $_
    } 
}
