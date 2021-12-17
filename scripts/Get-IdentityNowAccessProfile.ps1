function Get-IdentityNowAccessProfile {
    <#
.SYNOPSIS
Get an IdentityNow Access Profile(s).

.DESCRIPTION
Get an IdentityNow Access Profile(s).

.PARAMETER profileID
(optional) The profile ID of an IdentityNow Access Profile.

.EXAMPLE
Get-IdentityNowAccessProfile 

.EXAMPLE
Get-IdentityNowAccessProfile -profileID 2c91808466a64e330112a96902ff1f69

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Id")]
        [ValidateNotNullOrEmpty()]
        [Alias("Id")]
        [string]$profileID,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Name", Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(ParameterSetName = "Filter", Position = 0)]
        [Alias("Filter")]
        [string]$IdentityNowFilters,

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
        [ValidateSet("name", "-name", "created", "modified", "-created", "-modified" )]
        [string[]]$sorters = @("name")

    )
    Write-Verbose "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"

    $uri = (Get-IdentityNowOrg).Beta + "/access-profiles"
    
    if ($PSCmdlet.ParameterSetName -eq "Id") {
        $uri += "/$profileID"
        $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
        Invoke-RestMethod -Headers $headers -Uri $uri `
            ? { $_ } | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.AccessProfile"); $_ }
        return    
    }


    if ($PSCmdlet.ParameterSetName -eq "Name") {
        $IdentityNowFilters = "name eq `"$Name`""
    }
    elseif ($PSCmdlet.ParameterSetName -ne "Filter") {
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
        Write-Verbose "IdentityNowFilters=$IdentityNowFilters"
        $uri = $uri | Set-HttpQueryString -Name "filters" -Value $IdentityNowFilters
    }

    $sortersStr = $sorters -join ","

    try {
        Write-Verbose "Get access profiles from $uri"
        Write-Verbose "sorters=$sorters"
        Get-IdentityNowPaginatedCollection -uri $uri -sorters $sortersStr -pageSize 50 | `
            ? { $_ } | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.AccessProfile"); $_ }
 
    }
    catch {
        Write-Error "Could not get Access Profile from $uri. $($_)"
        throw $_ 
    }
}
