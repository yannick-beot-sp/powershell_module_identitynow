function Get-IdentityNowIAIRoleMiningSession {
    <#
.SYNOPSIS
Get role mining sessions


.PARAMETER Id
Session Id for this role mining session


.PARAMETER filters
Filter results using the standard syntax described in https://developer.sailpoint.com/docs/standard_collection_parameters.html#filtering-results.
The following fields and operators are supported:
- saved: eq "true" or "false"
- name: eq, sw

.EXAMPLE
Retrieves all role mining sessions
Get-IdentityNowIAIRoleMiningSession

.EXAMPLE
Get a role mining session by ID
Get-IdentityNowIAIRoleMiningSession -Id 2c918084691653af01695182a78b05ec

.EXAMPLE
Retrieves all saved role mining sessions
Get-IdentityNowIAIRoleMiningSession saved -eq "true"

.EXAMPLE
Get-IdentityNowIAIRoleMiningSession -sorters "-createdDate"

#>

    [cmdletbinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName, ParameterSetName = "Id")]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [parameter(Mandatory = $false, ParameterSetName = "Filter", Position = 0)]
        [String]
        $filters,

        [Parameter(Mandatory, ParameterSetName = "Eq", Position = 0)]
        [Parameter(Mandatory, ParameterSetName = "Sw", Position = 0)]
        [ValidateSet("saved", "name")]
        [string]$FieldName,

        [Parameter(ParameterSetName = "Eq")]
        [switch]$Eq,

        [Parameter(ParameterSetName = "Sw")]
        [switch]$Sw,

        [Parameter(Mandatory, ParameterSetName = "Eq", Position = 1)]
        [Parameter(Mandatory, ParameterSetName = "Sw", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$FieldValue,
        
        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "Eq")]
        [Parameter(ParameterSetName = "Sw")]
        [ValidateSet("createdBy", "createdDate", "-createdBy", "-createdDate")]
        [String[]]
        $sorters = @("-createdDate")
    )
    Write-Verbose "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"
    $uri =  Get-IdentityNowOrgUrl Beta "/role-mining-sessions"   

    if ($PSCmdlet.ParameterSetName -eq "Id") {
        $uri += "/$Id"
        Invoke-IdentityNowRequest -Uri $uri -Method Get -Json -TypeName "IdentityNow.RoleMiningSession"
        return    
    }

    if ($PSCmdlet.ParameterSetName -ne "Filter") {
        $FieldName = $FieldName.ToLower()
        if ($PSCmdlet.ParameterSetName -ne "in") {
            $operator = $PSCmdlet.ParameterSetName.ToLower()
            $filters = "$FieldName $operator `"$FieldValue`""
        }
        else {
            $values = $FieldValues -join "`",`""
            $filters = "$($FieldName.ToLower()) in (`"$values`")"
        }
    }

    if ($filters) {
        Write-Verbose "filters=$filters"
        $uri = $uri | Set-HttpQueryString -Name "filters" -Value $filters
    }

    $sortersStr = $sorters -join ","

    try {
        Write-Verbose "Get Role Mining Session from $uri"
        Write-Verbose "sorters=$sorters"
        Get-IdentityNowPaginatedCollection -uri $uri -sorters $sortersStr -pageSize 50 | `
            ? { $_ } | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.RoleMiningSession"); $_ }
 
    }
    catch {
        Write-Error "Could not get Role Mining Session from $uri. $($_)"
        throw $_ 
    }
}
