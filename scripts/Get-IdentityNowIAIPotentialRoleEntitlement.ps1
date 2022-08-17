function Get-IdentityNowIAIPotentialRoleEntitlement {
    <#
.SYNOPSIS
Retrieves entitlements for a potential role in a role mining session

.PARAMETER SessionId
Session Id for this role mining session

.PARAMETER PotentialRoleId
A potential role id in a role mining session

.PARAMETER sorters
sort by popularity, default order descending

.PARAMETER Filter
Filter parameter by "starts with" for the applicationName and entitlementRef.name.

.PARAMETER IncludeCommonAccess
Whether common access entitlements will be included or not

.EXAMPLE 
Get-IdentityNowIAIPotentialRoleEntitlement -SessionId "a7b5c6f3-025b-4c99-a55b-42736b441499" -PotentialRoleId "a7e5c6f3-025b-4c99-a55b-42736b441479" applicationName -sw "Acti"

.EXAMPLE 
Get-IdentityNowIAIPotentialRoleEntitlement -SessionId "a7b5c6f3-025b-4c99-a55b-42736b441499" -PotentialRoleId "a7e5c6f3-025b-4c99-a55b-42736b441479"

.EXAMPLE 
Get-IdentityNowIAIPotentialRoleEntitlement -SessionId "a7b5c6f3-025b-4c99-a55b-42736b441499" -PotentialRoleId "a7e5c6f3-025b-4c99-a55b-42736b441479" -MinimumPopularity 70
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
        [ValidateSet("applicationName", "entitlementRef.name", IgnoreCase = $false)]
        [string]$FieldName,

        [Parameter(ParameterSetName = "Sw")]
        [switch]$Sw,

        [Parameter(Mandatory, ParameterSetName = "Sw", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$FieldValue,

        [Parameter(ParameterSetName = "Sw")]
        [Parameter(ParameterSetName = "Filter")]
        [ValidateSet("popularity", "-popularity")]
        [String[]]
        $sorters = @("-popularity"),

        [switch]$IncludeCommonAccess,
        [int] $MinimumPopularity = -1
    )
    Write-Verbose "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"
    $uri = Get-IdentityNowOrgUrl Beta "/role-mining-sessions", $SessionId, "potential-roles", $PotentialRoleId, 'entitlement-popularities'  
    if ($PSCmdlet.ParameterSetName -ne "Filter") {
        # $FieldName = $FieldName.ToLower()
        $operator = $PSCmdlet.ParameterSetName.ToLower()
        $Filters = "$FieldName $operator `"$FieldValue`""
    }
    $sortersStr = $sorters -join ","
    Write-Verbose "sorters=$sorters"

    if ($IncludeCommonAccess.IsPresent) {
        $uri = $uri | Set-HttpQueryString -Name "includeCommonAccess" -Value "true"
    }
    else {
        $uri = $uri | Set-HttpQueryString -Name "includeCommonAccess" -Value "false"
    }
    
    if ($MinimumPopularity -gt 0 ) {
        $uri = $uri | Set-HttpQueryString -Name "min" -Value $MinimumPopularity
    }

    try {
        Write-Verbose "Get Potential Role Entitlements from $uri"
        Get-IdentityNowPaginatedCollection -uri $uri `
            -filters $Filters `
            -sorters $sortersStr `
            -TypeName "IdentityNow.PotentialRoleEntitlement" `
            -CustomHeaders @{Accept = "application/json" }

    }
    catch {
        Write-Error "Could not get Potential Role Entitlements $uri. $($_)"
        throw $_ 
    }
}
