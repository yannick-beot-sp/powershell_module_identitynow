function Invoke-IdentityNowAggregateSource {
    <#
.SYNOPSIS
    Initiate Aggregation of an IdentityNow Source.

.DESCRIPTION
    Initiate Aggregation of an IdentityNow Source.

.PARAMETER sourceID
    (required) The ID of an IdentityNow Source. eg. 45678

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
    }
    Process {
        if ($PSCmdlet.ParameterSetName -eq "object") {
            if ($source.id -match '^\d+$') {
                $sourceID = $source.id
            }
            else {
                $sourceID = $source.connectorAttributes.cloudExternalId
            }
        }

        $argsSplat.uri = "https://$($IdentityNowConfiguration.orgName).identitynow.com/api/source/loadAccounts/$sourceID"
        
        try {
            $aggregate = Invoke-RestMethod @argsSplat
            Write-Verbose "Task=$($aggregate.task)"
            if (-not $Wait.IsPresent) {
                return $aggregate.task  
            }
            do {
                Write-Verbose "Waiting..."
                Start-Sleep -Seconds 5

                $utime = [int][double]::Parse((Get-Date -UFormat %s))
                $uri = $((Get-IdentityNowOrg).'Private Base API URI') + "/event/list"
                $uri = $uri | Set-HttpQueryString -Name "_dc" -Value $utime | `
                    Set-HttpQueryString -Name "page" -Value 1 | `
                    Set-HttpQueryString -Name "start" -Value 0 | `
                    Set-HttpQueryString -Name "limit" -Value 3 | `
                    Set-HttpQueryString -Name "sort" -Value '[{"property":"timestamp","direction":"DESC"}]' | `
                    Set-HttpQueryString -Name "filter" -Value "[{`"property`":`"type`",`"value`":`"CLOUD_ACCOUNT_AGGREGATION`"},{`"property`":`"objectType`",`"value`":`"source`"},{`"property`":`"objectId`",`"value`":`"$sourceID`"}]"
                $tasks = (Invoke-WebRequest -Headers $headers -Uri $uri).Content | ConvertFrom-Json
                $task = $tasks.items | Where-Object { $_.details.id -eq $aggregate.task.id }
                if (-not $task) {
                    throw "Task not found"
                }
                if ($task.status -ne "PENDING") {
                    return $task
                }

            } while ($true)
            
        }
        catch {
            Write-Error "Source doesn't exist? Check SourceID. $($_)"
            throw $_
        }
    
    }
}
