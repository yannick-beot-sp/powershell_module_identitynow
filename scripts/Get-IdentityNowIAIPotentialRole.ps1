function Get-IdentityNowIAIPotentialRole {
    <#
.SYNOPSIS
Retrieves the potential role summaries for a role mining session

.PARAMETER SessionId
Session Id for this role mining session

.PARAMETER PotentialRoleId
A potential role id in a role mining session

.PARAMETER sorters
sort by identityCount, density, freshness or quality


.EXAMPLE
Retrieves all role mining sessions
Get-IdentityNowIAIPotentialRole -SessionId 8c190e67-87aa-4ed9-a90b-d9d5344523fb

.EXAMPLE
Retrieves a specific potential role for a role mining session
Get-IdentityNowIAIPotentialRole -SessionId 8c190e67-87aa-4ed9-a90b-d9d5344523fb -PotentialRoleId 8c190e67-87aa-4ed9-a90b-d9d5344523fb

.EXAMPLE
Get-IdentityNowIAIPotentialRole -sorters "-quality"

#>

    [cmdletbinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$SessionId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName, ParameterSetName = "Id")]
        [ValidateNotNullOrEmpty()]
        [string]$PotentialRoleId,
        
        [Parameter(ParameterSetName = "Filter")]
        [ValidateSet("identityCount", "density", "freshness", "quality", "-identityCount", "-density", "-freshness", "-quality")]
        [String[]]
        $sorters = @("-identityCount")
    )
    Write-Verbose "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"
    $uri = Get-IdentityNowOrgUrl Beta "/role-mining-sessions", $SessionId, "potential-role-summaries"   

    if ($PSCmdlet.ParameterSetName -eq "Id") {
        $uri += "/$PotentialRoleId"
        Invoke-IdentityNowRequest -Uri $uri -Method Get -Json -TypeName "IdentityNow.PotentialRoleSummary"
        return    
    }

    $sortersStr = $sorters -join ","

    try {
        Write-Verbose "Get Potential Role Summaries from $uri"
        Write-Verbose "sorters=$sorters"
        Get-IdentityNowPaginatedCollection -uri $uri -sorters $sortersStr -pageSize 50 | `
            ? { $_ } | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.PotentialRoleSummary"); $_ }
 
    }
    catch {
        Write-Error "Could not get Role Mining Session from $uri. $($_)"
        throw $_ 
    }
}
