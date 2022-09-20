function Get-IdentityNowRole {
    <#
.SYNOPSIS
Get IdentityNow Role(s).

.PARAMETER roleID
(optional) The ID of an IdentityNow Role.

.PARAMETER filters
Filter results using the standard syntax described in https://developer.sailpoint.com/docs/standard_collection_parameters.html#filtering-results.
The following fields and operators are supported:
- id: eq, in
- name: eq, sw 
- created, modified: gt, lt, ge, le
- owner.id: eq, in
- requestable: eq

.EXAMPLE
To get all roles
Get-IdentityNowRole 

.EXAMPLE
To get a role by ID
Get-IdentityNowRole -roleID 2c918084691653af01695182a78b05ec

.EXAMPLE
To get a role by name
Get-IdentityNowRole -Name "Americas Region Offices"

.EXAMPLE
To get roles with filters
 Get-IdentityNowRole "name sw `"Ameri`""

.EXAMPLE
Get-IdentityNowRole Name -sw Americ

.EXAMPLE
Get-IdentityNowRole -sorters created

.EXAMPLE
Get-IdentityNowRole -sorters name -filters "requestable eq `"false`""

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline, ParameterSetName = "Id")]
        [ValidateNotNullOrEmpty()]
        [Alias("Id")]
        [string]$roleID,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Name", Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,


        [parameter(Mandatory = $false, ParameterSetName = "Filter", Position = 0)]
        [String]
        $filters,

        [Parameter(Mandatory, ParameterSetName = "Eq", Position = 0)]
        [Parameter(Mandatory, ParameterSetName = "In", Position = 0)]
        [Parameter(Mandatory, ParameterSetName = "Sw", Position = 0)]
        [Parameter(Mandatory, ParameterSetName = "Gt", Position = 0)]
        [Parameter(Mandatory, ParameterSetName = "Lt", Position = 0)]
        [Parameter(Mandatory, ParameterSetName = "Ge", Position = 0)]
        [Parameter(Mandatory, ParameterSetName = "Le", Position = 0)]
        [ValidateSet("id", "name", "created", "modified", "owner.id", "requestable")]
        [string]$FieldName,

        [Parameter(ParameterSetName = "Eq")]
        [switch]$Eq,

        [Parameter(ParameterSetName = "In")]
        [switch]$In,

        [Parameter(ParameterSetName = "Sw")]
        [switch]$Sw,

        [Parameter(ParameterSetName = "Gt")]
        [switch]$Gt,

        [Parameter(ParameterSetName = "Ge")]
        [switch]$Ge,

        [Parameter(ParameterSetName = "Lt")]
        [switch]$Lt,
        
        [Parameter(ParameterSetName = "Le")]
        [switch]$Le,

        [Parameter(Mandatory, ParameterSetName = "Eq", Position = 1)]
        [Parameter(Mandatory, ParameterSetName = "Sw", Position = 1)]
        [Parameter(Mandatory, ParameterSetName = "Gt", Position = 1)]
        [Parameter(Mandatory, ParameterSetName = "Lt", Position = 1)]
        [Parameter(Mandatory, ParameterSetName = "Ge", Position = 1)]
        [Parameter(Mandatory, ParameterSetName = "Le", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$FieldValue,
        
        [Parameter(Mandatory, ParameterSetName = "In", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string[]]$FieldValues,
        
        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "Eq")]
        [Parameter(ParameterSetName = "In")]
        [Parameter(ParameterSetName = "Sw")]
        [Parameter(ParameterSetName = "Gt")]
        [Parameter(ParameterSetName = "Lt")]
        [Parameter(ParameterSetName = "Ge")]
        [Parameter(ParameterSetName = "Le")]
        [ValidateSet("name", "created", "modified", "-name", "-created", "-modified")]
        [String[]]
        $sorters = @("name")
    )
    Write-Verbose "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"
    $uri = (Get-IdentityNowOrg).Beta + "/roles"    

    if ($PSCmdlet.ParameterSetName -eq "Id") {
        $uri += "/$roleID"
        $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
        Invoke-RestMethod -Headers $headers -Uri $uri `
        | ? { $_ } | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.Role"); $_ }
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
        Write-Verbose "Get Roles from $uri"
        Write-Verbose "sorters=$sorters"

        Get-IdentityNowPaginatedCollection -uri $uri `
            -sorters $sortersStr `
            -pageSize 50 `
            -TypeName "IdentityNow.Role"
    }
    catch {
        Write-Error "Could not get Access Profile from $uri. $($_)"
        throw $_ 
    }
}
