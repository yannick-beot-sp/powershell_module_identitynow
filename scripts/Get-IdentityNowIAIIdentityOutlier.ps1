function Get-IdentityNowIAIIdentityOutlier {
    <#
.SYNOPSIS
list of outliers, containing data such as: identityId, outlier type, detection dates, identity attributes, if identity is ignore, and certification information


.EXAMPLE
Get-IdentityNowIAIIdentityOutlier 

.EXAMPLE
Get-IdentityNowIAIIdentityOutlier ignored -eq "true"

.EXAMPLE
Get-IdentityNowIAIIdentityOutlier -Filter 'attributes.displayName sw "John" and certStatus eq "false"'

#>

    [cmdletbinding(DefaultParameterSetName = "Filter")]
    param(
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
        [ValidateScript({ $_ -and ($_.StartsWith("attributes.") -or $_ -in ("firstDetectionDate", "certStatus", "created", "ignored", "score")) })]
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
        [ValidateScript({ $_ -and ($_.StartsWith("attributes.") -or $_.StartsWith("-attributes.") -or $_ -in ("firstDetectionDate", "score", "-firstDetectionDate", "-score")) })]
        [string[]]$sorters = @("-score"),

        [ValidateSet("LOW_SIMILARITY", "STRUCTURAL")]
        [string]$Type

    )
    Write-Verbose "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"

    $uri = Get-IdentityNowOrgUrl Beta "/outliers"
    
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
        Write-Verbose "IdentityNowFilters=$IdentityNowFilters"
        $uri = $uri | Set-HttpQueryString -Name "filters" -Value $IdentityNowFilters
    }

    if ($Type) {
        Write-Verbose "Type=$Type"
        $uri = $uri | Set-HttpQueryString -Name "type" -Value $Type
    }

    $sortersStr = $sorters -join ","

    try {
        Write-Verbose "Get outliers from $uri"
        Write-Verbose "sorters=$sorters"
        Get-IdentityNowPaginatedCollection -uri $uri `
            -sorters $sortersStr `
            -TypeName "IdentityNow.Outlier"

 
    }
    catch {
        Write-Error "Could not get Outliers from $uri. $($_)"
        throw $_ 
    }
}
