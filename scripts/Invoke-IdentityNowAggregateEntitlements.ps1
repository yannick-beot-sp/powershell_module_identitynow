function Invoke-IdentityNowAggregateEntitlements {
    <#
.SYNOPSIS
    Initiate Entitlement Aggregation of an IdentityNow Source.

.DESCRIPTION
    Initiate Entitlement Aggregation of an IdentityNow Source. By default, it aggregate all entitlement types.

.PARAMETER sourceID
    (required) The ID of an IdentityNow Source. eg. 45678

.PARAMETER source
    Source object (output of Get-IdentityNowSource)

.PARAMETER Wait
    (optional - switch) Wait for the aggregation to complete

.PARAMETER types
    list of entitlement types. All entitlement types if empty

.EXAMPLE
    Invoke-IdentityNowAggregateEntitlements -sourceID 12345

.EXAMPLE
    Invoke-IdentityNowAggregateSource -sourceID 12345 -disableOptimization

.EXAMPLE
    Get-IdentityNowSource -name "Active Directory" | Invoke-IdentityNowAggregateSource -Wait

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "id")]
        [int]$sourceID,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "object")]
        $source,
        [string[]]$types,
        [switch]$Wait
    )
    
    Process {
        $argSplat = @{
            wait            = $Wait
            AggregationType = "Entitlements"
            types           = $types
        }
        if ($PSCmdlet.ParameterSetName -eq "object") {
            $argSplat.Add("source", $source)
        }
        else {
            $argSplat.Add("sourceID", $sourceID)
        }
        Invoke-IdentityNowAggregation @argSplat
    }
}
