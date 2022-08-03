function Get-IdentityNowEntitlement {
    <#
.SYNOPSIS
Get IdentityNow Entitlement(s).

.PARAMETER EntitlementID
(optional) The ID of an IdentityNow Entitlement.

.PARAMETER filters
Filter results using the standard syntax described in https://developer.sailpoint.com/docs/standard_collection_parameters.html#filtering-results.
The following fields and operators are supported:
- id: eq, in
- name: eq, in, sw
- type: eq, in
- attribute: eq, in
- value: eq, in, sw
- source.id: eq, in
- requestable: eq

.EXAMPLE
To get all Entitlements
Get-IdentityNowEntitlement 

.EXAMPLE
To get a Entitlement by ID
Get-IdentityNowEntitlement -EntitlementID 2c918084691653af01695182a78b05ec

.EXAMPLE
To get a Entitlement by name
Get-IdentityNowEntitlement -Name "AssetMgmt-Mergers"

.EXAMPLE
To get Entitlements with filters
 Get-IdentityNowEntitlement "name sw `"AssetMgmt`""

.EXAMPLE
Get-IdentityNowEntitlement Name -sw AssetMgmt

.EXAMPLE
Get-IdentityNowEntitlement -sorters "-modified"

.EXAMPLE
Get-IdentityNowEntitlement -sorters name -filters "requestable eq `"false`""

#>

    [cmdletbinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline, ParameterSetName = "Id")]
        [ValidateNotNullOrEmpty()]
        [Alias("Id")]
        [string]$EntitlementID,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Name", Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [parameter(Mandatory = $false, ParameterSetName = "Filter", Position = 0)]
        [String]
        $filters,

        [Parameter(Mandatory, ParameterSetName = "Eq", Position = 0)]
        [Parameter(Mandatory, ParameterSetName = "In", Position = 0)]
        [Parameter(Mandatory, ParameterSetName = "Sw", Position = 0)]
        [ValidateSet("id", "name", "type", "attribute", "value", "source.id", "requestable")]
        [string]$FieldName,

        [Parameter(ParameterSetName = "Eq")]
        [switch]$Eq,

        [Parameter(ParameterSetName = "In")]
        [switch]$In,

        [Parameter(ParameterSetName = "Sw")]
        [switch]$Sw,

        [Parameter(Mandatory, ParameterSetName = "Eq", Position = 1)]
        [Parameter(Mandatory, ParameterSetName = "Sw", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$FieldValue,
        
        [Parameter(Mandatory, ParameterSetName = "In", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string[]]$FieldValues,
        
        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "Eq")]
        [Parameter(ParameterSetName = "In")]
        [Parameter(ParameterSetName = "Sw")]
        [ValidateSet("id", "name", "created", "modified", "type", "attribute", "value", "source.id", "-id", "-name", "-created", "-modified", "-type", "-attribute", "-value", "-source.id")]
        [String[]]
        $sorters = @("name")
    )
    Write-Verbose "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"
    $uri = (Get-IdentityNowOrg).Beta + "/entitlements"    

    if ($PSCmdlet.ParameterSetName -eq "Id") {
        $uri += "/$EntitlementID"
        $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
        Invoke-RestMethod -Headers $headers -Uri $uri `
        | ? { $_ } | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.Entitlement"); $_ }
        return    
    }

    if ($PSCmdlet.ParameterSetName -eq "Name") {
        $filters = "name eq `"$Name`""
    }
    elseif ($PSCmdlet.ParameterSetName -ne "Filter") {
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
        Write-Verbose "Get Entitlements from $uri"
        Write-Verbose "sorters=$sorters"
        Get-IdentityNowPaginatedCollection -uri $uri -sorters $sortersStr -pageSize 50 | `
            ? { $_ } | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.Entitlement"); $_ }
 
    }
    catch {
        Write-Error "Could not get Access Profile from $uri. $($_)"
        throw $_ 
    }
}
