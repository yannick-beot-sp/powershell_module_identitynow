function Import-IdentityNowCSV {
    <#
.SYNOPSIS
    Import CSV file for a delimited-file source

.PARAMETER sourceID
    The ID of the IdentityNow Source.

.PARAMETER Path
    Path to the CSV file to send

.PARAMETER Wait
    Wait for the aggregation to complete

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Id")]
        [string]$sourceID,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf }  )]
        [string]$Path,

        [switch]$Wait
        
    )
  
    Begin {
        $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
    }
    Process {
        Write-Verbose "Uploading $path to $sourceID..."
        try {
            $filename = [System.IO.Path]::GetFileName($Path)
            $fileBytes = [System.IO.File]::ReadAllBytes($Path);
            $fileEnc = [System.Text.Encoding]::GetEncoding('UTF-8').GetString($fileBytes);
            $boundary = [System.Guid]::NewGuid().ToString(); 
            $LF = "`r`n";
            $Headers.add("content-type", "multipart/form-data; boundary=`"$boundary`"")
            $bodyLines = ( 
                "--$boundary",
                "Content-Disposition: form-data; name=`"file`"; filename=`"$filename`"",
                "Content-Type: application/octet-stream$LF",
                $fileEnc,
                "--$boundary",
                "Content-Disposition: form-data; name=`"update-delete-threshold-combobox-inputEl`"",
                "Content-Type: text/plain$LF",
                "10%",
                "--$boundary--$LF"
            ) -join $LF
           
            $url = "$((Get-IdentityNowOrg).'Private Base API URI')/source/loadAccounts/$sourceId"
            $aggregate = Invoke-RestMethod -Uri $url -Method Post -headers $Headers -body $bodyLines
            Write-Verbose "Task=$($aggregate.task)"
            if (-not $Wait.IsPresent) {
                return $aggregate.task  
            }
            Wait-IdentityNowJob -sourceID $sourceID -JobType "CLOUD_ACCOUNT_AGGREGATION" -TaskId $aggregate.task.id
        }
        catch {
            Write-Error "Upload failed. $($_)" 
            throw $_
        }
    }
    
}
