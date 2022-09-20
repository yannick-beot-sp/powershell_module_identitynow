function Get-IdentityNowServiceDeskIntegration {
    <#
.SYNOPSIS
Get IdentityNow Service Desk Integration(s).

.DESCRIPTION
Get all IdentityNow Service Desk Integration(s), by Id, by Name or by Filter

.PARAMETER Id
The id of an Service Desk Integration.

.PARAMETER Name
Name of an Service Desk Integration.

.EXAMPLE
Get-IdentityNowServiceDeskIntegration 

.EXAMPLE
Get-IdentityNowServiceDeskIntegration -id 2c91808466a64e330112a96902ff1f69

.EXAMPLE
Get-IdentityNowServiceDeskIntegration type -eq "Atlassian Cloud Jira SDIM"

#>

    [cmdletbinding(DefaultParameterSetName = "Filter")]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Id")]
        [ValidateNotNullOrEmpty()]
        [string]$Id,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Name", Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(ParameterSetName = "Filter", Position = 0)]
        [Alias("Filter")]
        [string]$IdentityNowFilters,

        [Parameter(Mandatory, ParameterSetName = "Eq", Position = 0)]
        [Parameter(Mandatory, ParameterSetName = "In", Position = 0)]
        [ValidateSet("id", "name", "type", "cluster")]
        [string]$FieldName,

        [Parameter(ParameterSetName = "Eq")]
        [switch]$Eq,

        [Parameter(ParameterSetName = "In")]
        [switch]$In,

        [Parameter(Mandatory, ParameterSetName = "Eq", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string]$FieldValue,
        
        [Parameter(Mandatory, ParameterSetName = "In", Position = 1)]
        [ValidateNotNullOrEmpty()]
        [string[]]$FieldValues,
        
        [Parameter(ParameterSetName = "Filter")]
        [Parameter(ParameterSetName = "Eq")]
        [Parameter(ParameterSetName = "In")]
        [ValidateSet("name", "-name")]
        [string[]]$sorters = @("name")

    )
    Begin {
        Write-Verbose "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"
        $baseuri = (Get-IdentityNowOrg).'v3 Base API URI' + "/service-desk-integrations"
        if ($PSCmdlet.ParameterSetName -eq "Id") {
            $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
            $headers = @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
        }
    }
    Process {
        if ($PSCmdlet.ParameterSetName -eq "Id") {
            $uri = $baseuri + "/$Id"
            Write-Verbose "Getting ServiceDeskIntegration from $uri"
            Invoke-RestMethod -Headers $headers -Uri $uri `
            | ? { $_ } | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.ServiceDeskIntegration"); $_ }
        }
        else {
            $uri = $baseuri
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
                Write-Verbose "Get Service Desk Integration from $uri"
                Write-Verbose "sorters=$sorters"

                Get-IdentityNowPaginatedCollection -uri $uri `
                    -sorters $sortersStr `
                    -pageSize 50 `
                    -TypeName "IdentityNow.ServiceDeskIntegration"
            }
            catch {
                Write-Error "Could not get Service Desk Integration from $uri. $($_)"
                throw $_ 
            }
        }
    }
}
