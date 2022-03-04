function Wait-IdentityNowJob {
    <#
.SYNOPSIS
    Wait for a job to finish.
.PARAMETER SourceID
ID of source (legacy)

.PARAMETER JobType
Type of the job

.PARAMETER TaskId
Id of the task

.EXAMPLE
Wait-IdentityNowJob -sourceID 123456 -JobType "CLOUD_ACCOUNT_AGGREGATION" -TaskId "2c9180867f4cc538017f56ba9be32c6c"

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [int]$SourceID,

        [Parameter(Mandatory = $true)]
        [string]$JobType,
    
        [Parameter(Mandatory = $true)]
        [string]$TaskId

    )
    Begin {

        $token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{"Authorization" = "Bearer $($token.access_token)" } 
    }
    Process {
        do {
            Write-Verbose "Waiting 5s..."
            Start-Sleep -Seconds 5

            $utime = [int][double]::Parse((Get-Date -UFormat %s))
            $uri = $((Get-IdentityNowOrg).'Private Base API URI') + "/event/list"
            $uri = $uri | Set-HttpQueryString -Name "_dc" -Value $utime | `
                Set-HttpQueryString -Name "page" -Value 1 | `
                Set-HttpQueryString -Name "start" -Value 0 | `
                Set-HttpQueryString -Name "limit" -Value 3 | `
                Set-HttpQueryString -Name "sort" -Value '[{"property":"timestamp","direction":"DESC"}]' | `
                Set-HttpQueryString -Name "filter" -Value "[{`"property`":`"type`",`"value`":`"$JobType`"},{`"property`":`"objectType`",`"value`":`"source`"},{`"property`":`"objectId`",`"value`":`"$sourceID`"}]"
            $tasks = (Invoke-WebRequest -Headers $headers -Uri $uri).Content | ConvertFrom-Json
            Write-Verbose "Tasks=$($tasks |Out-String)"
            $task = $tasks.items | Where-Object { $_.details.id -eq $TaskId }
            if (-not $task) {
                throw "Task not found"
            }
            if ($task.status -ne "PENDING") {
                return $task
            }

        } while ($true)
    }
}