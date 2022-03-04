function Invoke-IdentityNowAggregation {
    <#
.SYNOPSIS
    Initiate Aggregation of an IdentityNow Source.

.DESCRIPTION
    Initiate Aggregation of an IdentityNow Source.

.PARAMETER SourceID
    (required) The ID of an IdentityNow Source. eg. 45678

.PARAMETER source
    Source object (output of Get-IdentityNowSource)
    
.PARAMETER disableOptimization
    (optional - switch) Disable Optimization for a full source aggregation

.PARAMETER types
    list of entitlement types. All entitlement types if empty

.PARAMETER Wait
    (optional - switch) Wait for the aggregation to complete

.EXAMPLE
    Invoke-IdentityNowAggregateSource -SourceID 12345

.EXAMPLE
    Invoke-IdentityNowAggregateSource -SourceID 12345 -disableOptimization

.EXAMPLE
    Get-IdentityNowSource -name "Active Directory" | Invoke-IdentityNowAggregateSource -Wait

.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "id")]
        [int]$SourceID,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "object")]
        $source,
        [ValidateSet("Accounts", "Entitlements" )]
        [string]$AggregationType,
        [string[]]$types,
        [switch]$disableOptimization,
        [switch]$Wait
    )
    Begin {

        $token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{"Authorization" = "Bearer $($token.access_token)" } 
        $argsSplat = @{
            Method  = "POST"
            Headers = $headers
        }

        if ($disableOptimization.IsPresent) {   
            Write-Verbose "Disabling optimization"
            $argsSplat.Add("Body", "disableOptimization=true")
        }

        if ($AggregationType -eq "Accounts") {
            $baseUri = (Get-IdentityNowOrg).'v1 Base API URI' + "/source/loadAccounts/"
            $jobType = "CLOUD_ACCOUNT_AGGREGATION"
        }
        else {
            $baseUri = (Get-IdentityNowOrg).'v1 Base API URI' + "/source/loadEntitlements/"
            $jobType = "ENTITLEMENT_AGGREGATION"
            
            if ($types) {
                $objectType = $types -join ","
            }
        }
    }
    Process {
        if ($PSCmdlet.ParameterSetName -eq "object") {
            if ($source.id -match '^\d+$') {
                $SourceID = $source.id
            }
            else {
                $SourceID = $source.connectorAttributes.cloudExternalId
            }
        }

        $argsSplat.uri = $baseUri + "$SourceID"
        if ($objectType) {
            $argsSplat.uri = $argsSplat.uri | Set-HttpQueryString -Name "objectType" -Value $objectType
        }
        
        try {
            $aggregate = Invoke-RestMethod @argsSplat
            Write-Verbose "Task=$($aggregate.task)"
            if (-not $Wait.IsPresent) {
                return $aggregate.task  
            }
            Wait-IdentityNowJob -SourceID $SourceID -JobType $jobType -TaskId $aggregate.task.id
        }
        catch {
            Write-Error "Source doesn't exist? Check SourceID. $($_)"
            throw $_
        }
    
    }
}
