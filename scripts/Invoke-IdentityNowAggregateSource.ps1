function Invoke-IdentityNowAggregateSource {
    <#
.SYNOPSIS
    Initiate Aggregation of an IdentityNow Source.

.DESCRIPTION
    Initiate Aggregation of an IdentityNow Source.

.PARAMETER sourceID
    (required) The ID of an IdentityNow Source. eg. 45678

.PARAMETER source
    Source object (output of Get-IdentityNowSource)

.PARAMETER disableOptimization
    (optional - switch) Disable Optimization for a full source aggregation

.PARAMETER Wait
    (optional - switch) Wait for the aggregation to complete

.EXAMPLE
    Invoke-IdentityNowAggregateSource -sourceID 12345

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
        [switch]$disableOptimization,
        [switch]$Wait
    )
    
    Process {
        $argSplat = @{
            wait                = $Wait
            AggregationType     = "Accounts"
            disableOptimization = $disableOptimization
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
