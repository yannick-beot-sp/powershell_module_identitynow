function Get-IdentityNowIAIRecommendation {
    <#
.SYNOPSIS
Returns a Recommendation Based on Object

.PARAMETER ExcludeInterpretations
Exclude interpretations in the response if "true". Return interpretations in the response if this attribute is not specified.


.PARAMETER IncludeTranslationMessages
When set to true, the calling system uses the translated messages for the specified language

.PARAMETER IncludeDebugInformation
Returns the recommender calculations if set to true

.PARAMETER PrescribeMode
When set to true, uses prescribedRulesRecommenderConfig to get identity attributes and peer group threshold instead of standard config.


.EXAMPLE
XXX

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Id")]
        [ValidateNotNullOrEmpty()]
        [string]$IdentityID,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Id")]
        [ValidateNotNullOrEmpty()]
        [string]$AccessID,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "Id")]
        [ValidateSet("ENTITLEMENT", "ACCESS_PROFILE", "ROLE")]
        [string]$AccessType,

        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = "items")]
        [Array]$Items,
        
        [switch] $ExcludeInterpretations,
        [switch] $IncludeTranslationMessages,
        [switch] $IncludeDebugInformation,
        [switch] $PrescribeMode

    )
    Write-Verbose "PSCmdlet.ParameterSetName=$($PSCmdlet.ParameterSetName)"

    if ($PSCmdlet.ParameterSetName -eq "Id") {
        $Items = @(
            @{
                identityId = $IdentityID
                item       = @{
                    id   = $AccessID
                    type = $AccessType
                }
            }
        )
    }

    $uri = (Get-IdentityNowOrg).Beta + "/recommendations/request"
    
    $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
    $headers = @{
        'Content-Type' = "application/json" 
        Authorization  = "$($v3Token.token_type) $($v3Token.access_token)" 
    }

    $payload = @{
        requests                   = $Items
        excludeInterpretations     = $ExcludeInterpretations.IsPresent
        includeTranslationMessages = $IncludeTranslationMessages.IsPresent
        includeDebugInformation    = $IncludeDebugInformation.IsPresent
        prescribeMode              = $PrescribeMode.IsPresent
    }
    Invoke-RestMethod -Headers $headers -Uri $uri -Method POST -Body ($payload | ConvertTo-Json -Depth 100) | `
        ? { $_ } | % { $_.responses } | % { $_.PSObject.TypeNames.Insert(0, "IdentityNow.Recommendations"); $_ }
}
