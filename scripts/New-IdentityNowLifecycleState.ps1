function New-IdentityNowLifecycleState {
    <#
.SYNOPSIS
Create an IdentityNow Lifecyle State of an Identity Profile.

.DESCRIPTION
Create an IdentityNow Lifecyle State of an Identity Profile.

.PARAMETER identityProfileID
The Identity Profile ID.

.PARAMETER json
The Lifecyle State as JSON

.PARAMETER name
The Name of the Lifecyle State

.PARAMETER technicalName
The technical of the Lifecyle State. If not provided, it is equal to the name in lowercase without space.

.PARAMETER enabled
Whether the lifecycle state is enabled or disabled.

.PARAMETER notifyManagers
If true, then the manager is notified of the lifecycle state change.
.PARAMETER notifyAllAdmins
If true, then all the admins are notified of the lifecycle state change.

.PARAMETER notifySpecificUsers
List of user email addresses to be notified of lifecycle state change.
Will automatically enable notification to these users.

.PARAMETER enableSourceIds
List of unique source IDs to enable during lifecycle state change.

.PARAMETER disableSourceIds
List of unique source IDs to disable during lifecycle state change.

.PARAMETER accessProfileIds
List of unique access profile IDs that are associated with the lifecycle state.

.PARAMETER enableSourceNames
List of unique source names to enable during lifecycle state change.

.PARAMETER disableSourceNames
List of unique source names to disable during lifecycle state change.

.PARAMETER accessProfileNames
List of unique access profile names that are associated with the lifecycle state.

.EXAMPLE
New-IdentityNowLifecycleState -identityProfileID 2c9180837c99cf5c017ca7c811760905 -name "PreHire" -enableSourceNames "Active Directory" -Verbose -accessProfileNames "Base Profile"

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding(DefaultParameterSetName = "expandedIds")]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'json')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'expandedIds')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'expandedNames')]
        [ValidateNotNullOrEmpty()]
        [string]$identityProfileID,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'json')]
        [ValidateNotNullOrEmpty()]
        [string]$json,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'expandedIds')]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'expandedNames')]
        [ValidateNotNullOrEmpty()]
        [string]$name,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedIds')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedNames')]
        [ValidateNotNullOrEmpty()]
        [string]$technicalName,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedIds')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedNames')]
        [bool]$enabled = $true,

        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedIds')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedNames')]
        [switch]$notifyManagers,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedIds')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedNames')]
        [switch]$notifyAllAdmins,
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedIds')]
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedNames')]
        [string[]]$notifySpecificUsers = @(),

        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedIds')]
        [string[]]$enableSourceIds = @(),
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedIds')]
        [string[]]$disableSourceIds = @(),
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedIds')]
        [string[]]$accessProfileIds = @(),
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedNames')]
        [string[]]$enableSourceNames = @(),
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedNames')]
        [string[]]$disableSourceNames = @(),
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'expandedNames')]
        [string[]]$accessProfileNames = @()
    )

    $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
    $headers = @{
        Authorization  = "$($v3Token.token_type) $($v3Token.access_token)" 
        "content-type" = "application/json"
    }
    $uri = "$((Get-IdentityNowOrg).'v3 Base API URI')/identity-profiles/$identityProfileID/lifecycle-states"

    if ($PSCmdlet.ParameterSetName -eq 'json') {
        $body = $json
    }
    else {
        if (-not $technicalName) {
            $technicalName = $name.ToLower() -replace " ", ""
        }
        $createLifecycleStateData = @{
            name                    = $name
            technicalName           = $technicalName
            enabled                 = $enabled
            emailNotificationOption = @{
                notifyManagers      = $notifyManagers.IsPresent
                notifyAllAdmins     = $notifyAllAdmins.IsPresent
                notifySpecificUsers	= ($notifySpecificUsers -and $notifySpecificUsers.Count -gt 0)
                emailAddressList    = $notifySpecificUsers
            }
        }
        if ($PSCmdlet.ParameterSetName -eq 'expandedIds') {
            $accountActions = @()
            if ($enableSourceIds -and $enableSourceIds.Count -gt 0) {
                $accountActions += @{
                    action    = "ENABLE"
                    sourceIds = @($enableSourceIds)
                }
            }
            if ($disableSourceIds -and $disableSourceIds.Count -gt 0) {
                $accountActions += @{
                    action    = "DISABLE"
                    sourceIds = @($disableSourceIds)
                }
            }
            $createLifecycleStateData.Add("accountActions", $accountActions)
            $createLifecycleStateData.Add("accessProfileIds", $accessProfileIds)
        }
        else {
            # $PSCmdlet.ParameterSetName -eq 'expandedNames'
            Write-Verbose '$PSCmdlet.ParameterSetName -eq ''expandedNames'''
            $accountActions = @()
            $sources = Get-IdentityNowSource
            if ($enableSourceNames -and $enableSourceNames.Count -gt 0) {
                Write-Verbose "enableSourceNames"
                $sourceIds = $sources | Where-Object { $_.name -in $enableSourceNames } | Select-Object -ExpandProperty externalId
                Write-Verbose "sourceIds=$sourceIds"
                $accountActions += @{
                    action    = "ENABLE"
                    sourceIds = @($sourceIds)
                }
            }
            if ($disableSourceNames -and $disableSourceNames.Count -gt 0) {
                $sourceIds = $sources | Where-Object { $_.name -in $disableSourceNames } | Select-Object -ExpandProperty externalId
                $accountActions += @{
                    action    = "DISABLE"
                    sourceIds = @($sourceIds)
                }
            }
            $createLifecycleStateData.Add("accountActions", $accountActions)
            $accessProfileIds = @()
            if ($accessProfileNames -and $accessProfileNames.Count -gt 0) {
                $accessProfiles = Get-IdentityNowAccessProfile
                $accessProfileIds = $accessProfiles | Where-Object { $_.name -in $accessProfileNames } | Select-Object -ExpandProperty id
            }
            $createLifecycleStateData.Add("accessProfileIds", $accessProfileIds)

        }  #end if $PSCmdlet.ParameterSetName -eq 'expandedIds'
        $body = ConvertTo-Json -Depth 100 -InputObject $createLifecycleStateData
    } #end if $PSCmdlet.ParameterSetName -eq 'json'
    Write-Verbose "Body=[$body]"

    try {
        $lifecycleState = Invoke-RestMethod -Method Post `
            -Uri $uri `
            -Headers $headers `
            -Body $body
        return $lifecycleState | Add-Member -TypeName 'IdentityNowLifecyleState' -PassThru
    }
    catch {
        Write-Error "Identity Profile or lifecyle state  does not exist. Check App ID. $($_)" 
    }
    
}