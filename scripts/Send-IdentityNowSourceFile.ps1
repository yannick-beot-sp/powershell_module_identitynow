function Send-IdentityNowSourceFile {
    <#
.SYNOPSIS
This uploads a supplemental source connector file (like jdbc driver jars). 

.DESCRIPTION
This uploads a supplemental source connector file (like jdbc driver jars) to a source's S3 bucket. 
This also sends out an update message to Cegs as well as firing ETS and Audit events.

.PARAMETER sourceID
(Required) The ID of the IdentityNow Source.

.PARAMETER path
Path to the file to send


#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [Alias("Id")]
        [string]$sourceID,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateScript({ Test-Path -Path $_ -PathType Leaf }  )]
        [string]$Path
        
    )
  
    Begin {
        $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
    }
    Process {
        Write-Verbose "Uploading $path to $sourceID..."
        try {
            if ($sourceID -match '^\d+$') {
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
                    "--$boundary--$LF" 
                ) -join $LF
           
                $url = "$((Get-IdentityNowOrg).'Private Base API URI')/source/uploadConnectorFile/$sourceId"
                Invoke-RestMethod -Uri $url -Method Post -headers $Headers -body $bodyLines 
            }
            else {

                $url = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/sources/$sourceID/upload-connector-file"
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
                    "--$boundary--$LF" 
                ) -join $LF
           
                $response = Invoke-RestMethod -Uri $url -Method Post -headers $Headers -body $bodyLines 
                $response | ? {$_} | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.Source"); $_ }
            }

        }
        catch {
            Write-Error "Upload failed. $($_)" 
            throw $_
        }
    }
    
}
