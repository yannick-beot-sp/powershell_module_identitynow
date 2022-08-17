function New-IdentityNowIAIRoleMiningSession {
    <#
.SYNOPSIS
Create role mining session request to the role mining application.

.PARAMETER Criteria
The search criteria to find identities

.PARAMETER PruneThreshold
The prune threshold to be used or null to calculate prescribedPruneThreshold

.PARAMETER minNumIdentitiesInPotentialRole
Minimum number of identities in a potential role

.PARAMETER type
Role mining session type

.EXAMPLE
New-IdentityNowIAIRoleMiningSession -Criteria '@access(source.name:"Active Directory")' -MinNumIdentitiesInPotentialRole 18

.EXAMPLE
New-IdentityNowIAIRoleMiningSession -Criteria '@access(source.name:"Active Directory")' -PruneThreshold 57

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory, Position = 0)]
        [ValidateNotNullOrEmpty()]
        [string]$Criteria,

        [parameter(Mandatory = $false)]
        [ValidateRange(50, 100)]
        [AllowNull()]
        [Nullable[System.Int32]]
        $PruneThreshold,

        [parameter(Mandatory = $false)]
        [AllowNull()]
        [Nullable[System.Int32]]
        $MinNumIdentitiesInPotentialRole,

        [ValidateSet("SPECIALIZED", "COMMON")]
        [string]$type = "SPECIALIZED"
    )

    $payload = @{
        scope = @{
            criteria = $Criteria
        }
        type  = $type.ToUpperInvariant()
    }

    if ($null -ne $PruneThreshold) {
        $payload.Add("pruneThreshold", $PruneThreshold)
    }

    if ($null -ne $MinNumIdentitiesInPotentialRole) {
        $payload.Add("minNumIdentitiesInPotentialRole", $MinNumIdentitiesInPotentialRole)
    }

    try {
        Write-Verbose "Create Role Mining Session"
        Write-Verbose "payload=$($payload|out-string)"
        Invoke-IdentityNowRequest -API Beta -path "/role-mining-sessions" -method Post -Body $payload -Json -TypeName "IdentityNow.RoleMiningSession"
 
    }
    catch {
        Write-Error "Could not create Role Mining Session. $($_)"
        throw $_ 
    }
}
