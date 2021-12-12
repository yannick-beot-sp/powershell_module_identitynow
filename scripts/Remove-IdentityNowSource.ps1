function Remove-IdentityNowSource {
    <#
.SYNOPSIS
Deletes an IdentityNow Source.

.DESCRIPTION
Deletes an IdentityNow Source. 
This will often fail if tasks are running or the source is in use by a transform or access profile.
The cmdlet determines to use the v1 or v3 endpoint.

.PARAMETER sourceID
(Required) The ID of the IdentityNow Source.

.EXAMPLE
Remove-IdentityNowSource -sourceid 115737

.EXAMPLE
Remove-IdentityNowSource -id 2c91808779ecf55b0179f720942f181a

.EXAMPLE
Get-IdentityNowSource | ? name -like "dropbox*" | Remove-IdentityNowSource

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

.NOTES
written by Sean McGovern 11/20/2019 (twitter @410sean)

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Id")]
        [string]$sourceID,
        [switch]$Wait
    )
    Begin {

        $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
    }
    Process {
        Write-Verbose "Deleting $sourceID..."
        try {
            if ($sourceID -match '^\d+$') {
                Write-Verbose "Use V1 endpoint"
    
    
                $privateuribase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com"
                $url = "$privateuribase/cc/api/source/delete/$sourceid"
                $response = Invoke-WebRequest -Uri $url -Method Post -UseBasicParsing -Headers $headers
                Write-Verbose "Source deleted"
            }
            else {
                Write-Verbose "Use V3 endpoint"
                $url = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/sources/$sourceID"
                $response = Invoke-RestMethod -Uri $url -Method Delete -Headers $headers

                if ($Wait.IsPresent) {
                    $taskurl = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/task-status/$($response.id)"
                    do {
                        try {
                            $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers
                            Write-Verbose "Got task status: $response"
                        }
                        catch {
                            if ($_.Exception.Response.StatusCode.value__ -eq 404) {
                                Write-Verbose "Task not found -> exiting"
                                break;
                            }
                        }
                        Write-Verbose "Waiting 5 seconds"
                        Start-Sleep -Seconds 5

                    } while ($true)
                    Write-Verbose "Source $sourceID deleted..."
                }
                else {
                    Write-Verbose "Source $sourceID deletion on-going..."
                    return $response
                }
            }
        }
        catch {
            Write-Error "deletion of Source failed. if the following error message states 'currently in use' that could be equivalent to 'tasks are running' $($_)" 
        }
    }
    
}
