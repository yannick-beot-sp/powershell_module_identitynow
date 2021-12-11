function Get-IdentityNowVACluster {
    <#
.SYNOPSIS
Get IdentityNow Virtual Appliance Cluster(s).

.DESCRIPTION
Get IdentityNow Virtual Appliance Cluster(s).

.EXAMPLE
Get-IdentityNowVACluster 

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [CmdletBinding(DefaultParameterSetName = "ID")]
    param(
        [Parameter(ParameterSetName = "Name")]
        [string]$Name,

        [Parameter(ParameterSetName = "ID")]
        [string]$id
    )

    $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
    
    $uri = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/beta/managed-clusters"
    if ($id) {
        $uri += "/$id"
    }
        
    try {
        Write-Verbose "Get VA Cluster(s) from $uri"
        $IDNCluster = Invoke-RestMethod -Method Get -Uri $uri -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }

        if ($PSCmdlet.ParameterSetName -eq "Name") {
            # not possible to filter by name with current API
            $IDNCluster = $IDNCluster | ? { $_.name -eq $Name }
        }

        $IDNCluster | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.VACluster") }

        return $IDNCluster
    }
    catch {
        Write-Error "VA Cluster doesn't exist. VA Cluster ID. $($_)"
        throw $_
    } 
}
