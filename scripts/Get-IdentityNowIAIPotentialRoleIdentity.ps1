function Get-IdentityNowIAIPotentialRoleIdentity {
    <#
.SYNOPSIS
Retrieves Identities for a potential role in a role mining session

.PARAMETER SessionId
Session Id for this role mining session

.PARAMETER PotentialRoleId
A potential role id in a role mining session

.PARAMETER sorters
sort by popularity, default order descending

.PARAMETER Filter
Filter parameter by "starts with" for the name.

.EXAMPLE 
Get-IdentityNowIAIPotentialRoleIdentity -SessionId "a7b5c6f3-025b-4c99-a55b-42736b441499" -PotentialRoleId "a7e5c6f3-025b-4c99-a55b-42736b441479" name -sw "Yan"

.EXAMPLE 
Get-IdentityNowIAIPotentialRoleIdentity -SessionId "a7b5c6f3-025b-4c99-a55b-42736b441499" -PotentialRoleId "a7e5c6f3-025b-4c99-a55b-42736b441479"
#>

    [cmdletbinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$SessionId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$PotentialRoleId,
        
        [Parameter(ParameterSetName = "Filter", Position = 0)]
        [string]$Filters,

        [Parameter(Mandatory, ParameterSetName = "Sw", Position = 0)]
        [ValidateSet("name")]
        [string]$FieldName,

        [Parameter(ParameterSetName = "Sw")]
        [switch]$Sw,

        [Parameter(Mandatory, ParameterSetName = "Sw", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$FieldValue,

        [Parameter(ParameterSetName = "Sw")]
        [Parameter(ParameterSetName = "Filter")]
        [ValidateSet("name", "-name")]
        [String[]]
        $sorters = @("-name")
    )
    Write-Verbose "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"
    $uri = Get-IdentityNowOrgUrl Beta "/role-mining-sessions", $SessionId, "potential-roles", $PotentialRoleId, 'identities'  
    if ($PSCmdlet.ParameterSetName -ne "Filter") {
        $FieldName = $FieldName.ToLower()
        $operator = $PSCmdlet.ParameterSetName.ToLower()
        $Filters = "$FieldName $operator `"$FieldValue`""
    }
    $sortersStr = $sorters -join ","
    Write-Verbose "sorters=$sorters"

    try {
        Write-Verbose "Get Potential Role Identities from $uri"
        Get-IdentityNowPaginatedCollection -uri $uri `
            -filters $Filters `
            -sorters $sortersStr `
            -TypeName "IdentityNow.PotentialRoleIdentity" 
            # `
            # -CustomHeaders @{Accept = "application/json" }

    }
    catch {
        Write-Error "Could not get Potential Role Identities $uri. $($_)"
        throw $_ 
    }
}
