function Remove-IdentityNowApplication {
    <#
.SYNOPSIS
    Delete IdentityNow Application.

.PARAMETER AppId
    The Application ID of an IdentityNow Application. It corresponds to the property "appId" of the application

.PARAMETER Id
    The Application ID of an IdentityNow Application. It corresponds to the property "id" of the application

.EXAMPLE
    Remove-IdentityNowApplication -AppId 24184

.EXAMPLE
    Get-IdentityNowApplication -org | ? name -like "Dropbox *" | Remove-IdentityNowApplication

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding(DefaultParameterSetName = "AppId")]
    param(
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "AppId")]
        [int]$AppId,
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "Id")]
        [int]$Id
    )

    Begin {
        $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
    }
    Process {
        if ($PSCmdlet.ParameterSetName -eq "Id") {
            Write-Verbose "Getting appId"
            $app = Get-IdentityNowApplication -Id $Id
            $AppId = $app.appId
        }

        try {
            Write-verbose "Deleting AppId=$AppId"
            $uri = (Get-IdentityNowOrg).'Private Base API URI' + "/app/delete/$appID"
            $response = Invoke-RestMethod -Method Post -Uri $uri `
                -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" } 
                
        }
        catch {
            Write-Error "Could not delete Application. $($_)" 
            throw $_
        }
    }
}

