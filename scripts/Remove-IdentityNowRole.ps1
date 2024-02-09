function Remove-IdentityNowRole {
    <#
.SYNOPSIS
Delete an IdentityNow Role.

.PARAMETER ID
(required) The ID of the IdentityNow Role to be deleted.

.EXAMPLE
Remove-IdentityNowRole -ID 2c9180886cd58059016d1a4757d709a4

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>
    [CmdletBinding(DefaultParameterSetName = "ID")]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ID")]
        [Alias("RoleID")]
        [string]$ID,
        [Parameter(Mandatory = $true, ParameterSetName = "Bulk")]
        [Alias("RoleIds")]
        [string[]]$IDs
    )

    BEGIN {
        $BaseURL = Get-IdentityNowOrgUrl v3 "/roles"
    }
    PROCESS {
        if ($PSCmdlet.ParameterSetName -eq "Bulk") {
            $uri = "$BaseURL/bulk-delete"
            #https://stackoverflow.com/a/13891437
            $MAX_BULK = 50
            try {
                for ($i = 0; $i -lt $IDs.length; $i += $MAX_BULK) { 
                    $roleIds = $IDs[$i .. ($i + $MAX_BULK - 1)]
                    Write-Verbose ($roleIds | Out-String)
                    Invoke-IdentityNowRequest -Uri $uri `
                        -Method POST `
                        -body @{ roleIds = $roleIds }
                }
            }
            catch {
                Write-Error "Deletion of Roles failed. Check Role Configuration for $IDs. $($_)"
                throw $_
            }
        }
        else {
            $uri = "$BaseURL/$ID"
            Write-Verbose "uri=$uri"

            try {
                Invoke-IdentityNowRequest -Uri $uri -Method Delete
            }
            catch {
                Write-Error "Deletion of Role failed. Check Role Configuration for $ID. $($_)"
                throw $_
            }
            Write-Host -ForegroundColor Green "Role $ID deleted"
        }
    }
}
