function Get-IdentityNowOrgUrl {
    <#
.SYNOPSIS
    Displays the default Uri value for all or a particular Organisation based on configured OrgName.

.DESCRIPTION
    Displays the default Uri value for all or a particular Organisation based on configured OrgName.

.EXAMPLE

#>

    [CmdletBinding()]
    param (

        [Parameter(Mandatory, Position = 0)]
        [ValidateSet("v3", "v2", "v1", "cc", "beta", "base")]
        [string]
        $endpoint,
        [Parameter(Position = 1)]
        [string[]]
        $parts

    )

    function Join-Parts {
        param
        (
            [string[]]
            $Parts,
            $Separator = '/'
        )

    ($Parts | ? { $_ } | % { ([string]$_).trim($Separator) } | ? { $_ } ) -join $Separator 
    }

    if (!$IdentityNowConfiguration.orgName) {
        Write-Warning "No Organisation name held in configuration."
        exit 1
    }

    $property = switch -Regex ($endpoint) {
        "v[1-3]" { "$($_) Base API URI" }
        "cc" { "Private Base API URI" }
        "beta" { "Beta" }
        "base" { "apiUrl" }
        Default { throw "Invalid endpoint $($_)" }
    }

    $baseUrl = (Get-IdentityNowOrg)[$property]

    Join-Parts (@($baseUrl) + $parts)
}

