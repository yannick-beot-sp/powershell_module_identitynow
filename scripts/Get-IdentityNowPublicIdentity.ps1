function Get-IdentityNowPublicIdentity {
    <#
.SYNOPSIS
Get a list of public identities

.DESCRIPTION
Get a list of public identities

.PARAMETER Filter
Filter results using the standard syntax described in V3 API Standard Collection Parameters
See for filtering : https://developer.sailpoint.com/apis/beta/#operation/listAccessProfiles


.EXAMPLE
Get-IdentityNowPublicIdentity

.EXAMPLE
Get-IdentityNowPublicIdentity id -in 2c9180837c13ab62017c178cad6a0776,2c9180877abf8fbe017ac8869f122bc8

.EXAMPLE
Get-IdentityNowPublicIdentity id -eq 2c9180837c13ab62017c178cad6a0776

.EXAMPLE
Get-IdentityNowPublicIdentity alias -sw sailpoint

#>

    [CmdletBinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(ParameterSetName = "Filter", Position = 0)]
        [Alias("Filter")]
        [string]$IdentityNowFilters,

        [Parameter(Mandatory, ParameterSetName = "Eq", Position = 0)]
        [Parameter(Mandatory, ParameterSetName = "In", Position = 0)]
        [Parameter(Mandatory, ParameterSetName = "Sw", Position = 0)]
        [ValidateSet("id", "alias", "email", "firstname", "lastname")]
        [string]$FieldName,

        [Parameter(ParameterSetName = "Eq")]
        [switch]$eq,

        [Parameter(ParameterSetName = "In")]
        [switch]$in,

        [Parameter(ParameterSetName = "Sw")]
        [switch]$sw,

        [Parameter(Mandatory, ParameterSetName = "Eq", Position = 1)]
        [Parameter(Mandatory, ParameterSetName = "Sw", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$FieldValue,
        
        [Parameter(Mandatory, ParameterSetName = "In", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string[]]$FieldValues

    )

    $uri = Get-IdentityNowOrgUrl v3 "/public-identities"
    
    if ($PSCmdlet.ParameterSetName -ne "Filter") {
        $FieldName = $FieldName.ToLower()
        if ($PSCmdlet.ParameterSetName -ne "in") {
            $operator = $PSCmdlet.ParameterSetName.ToLower()
            $IdentityNowFilters = "$FieldName $operator `"$FieldValue`""
        }
        else {
            $values = $FieldValues -join "`",`""
            $IdentityNowFilters = "$($FieldName.ToLower()) in (`"$values`")"
        }
    }

    if ($IdentityNowFilters) {
        $uri = Set-HttpQueryString -Uri $uri -Name "filters" -Value $IdentityNowFilters
    }
        
    try {
        Write-Verbose "Get public identities from $uri"
        Get-IdentityNowPaginatedCollection -uri $uri -sorters "name" | `
            ? { $_ } | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.PublicIdentity"); $_ }
    }
    catch {
        Write-Error "Could not get public identities. $($_)"
        throw $_
    } 
}
