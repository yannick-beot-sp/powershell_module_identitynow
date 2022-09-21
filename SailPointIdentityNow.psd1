@{
    RootModule           = 'SailPointIdentityNow.psm1'
    ModuleVersion        = '1.1.5'
    GUID                 = 'f82fe16a-7702-46f3-ab86-5de11b7305de'
    Author               = 'Darren J Robinson'
    Copyright            = '(c) 2021. All rights reserved.'
    Description          = "Orchestration of SailPoint IdentityNow"
    PowerShellVersion    = '5.1'
    CompatiblePSEditions = 'Core', 'Desktop'
    FormatsToProcess     = @('SailPointIdentityNow.Format.ps1xml')
    FunctionsToExport    = @('Complete-IdentityNowTask',
        'Convert-UnixTime',
        'Export-IdentityNowConfig',
        'Get-HashString',
        'Get-IdentityNowAccessProfile',
        'Get-IdentityNowAccountActivities',
        'Get-IdentityNowAccountActivity',
        'Get-IdentityNowActiveJobs',
        'Get-IdentityNowAPIClient',
        'Get-IdentityNowApplication',
        'Get-IdentityNowApplicationAccessProfile',
        'Get-IdentityNowAuth',
        'Get-IdentityNowCertCampaign',
        'Get-IdentityNowCertCampaignReport',
        'Get-IdentityNowConnectors',
        'Get-IdentityNowEntitlement',
        'Get-IdentityNowEmailTemplate',
        'Get-IdentityNowGovernanceGroup',
        'Get-IdentityNowIAIIdentityOutlier',
        'Get-IdentityNowIAIPotentialRole',
        'Get-IdentityNowIAIPotentialRoleApplication',
        'Get-IdentityNowIAIPotentialRoleEntitlement',
        'Get-IdentityNowIAIPotentialRoleIdentity',
        'Get-IdentityNowIAIRecommendation',
        'Get-IdentityNowIAIRoleMiningSession',
        'Get-IdentityNowIdentityAttribute',
        'Get-IdentityNowIdentityAttributePreview',
        'Get-IdentityNowOAuthAPIClient',
        'Get-IdentityNowOrg',
        'Get-IdentityNowOrgUrl',
        'Get-IdentityNowOrgConfig',
        'Get-IdentityNowOrgStatus',
        'Get-IdentityNowPersonalAccessToken',
        'Get-IdentityNowProfile',
        'Get-IdentityNowProfileOrder',
        'Get-IdentityNowPublicIdentity',
        'Get-IdentityNowQueue',
        'Get-IdentityNowRole',
        'Get-IdentityNowRule',
        'Get-IdentityNowSource',
        'Get-IdentityNowSourceAccounts',
        'Get-IdentityNowSourceSchema',
        'Get-IdentityNowTask',
        'Get-IdentityNowTimeZone',
        'Get-IdentityNowTransform',
        'Get-IdentityNowVACluster',
        'Import-IdentityNowCSV',
        'Invoke-IdentityNowAggregateSource',
        'Invoke-IdentityNowAggregateEntitlements',
        'Invoke-IdentityNowRequest',
        'Invoke-IdentityNowSourceReset',
        'Join-IdentityNowAccount',
        'New-IdentityNowAccessProfile',
        'New-IdentityNowApplication',
        'New-IdentityNowAPIClient',
        'New-IdentityNowCertCampaign',        
        'New-IdentityNowGovernanceGroup',
        'New-IdentityNowIAIRoleMiningSession',
        'New-IdentityNowIdentityProfilesReport',
        'New-IdentityNowOAuthAPIClient',
        'New-IdentityNowPersonalAccessToken',
        'New-IdentityNowProfile',
        'New-IdentityNowRole',
        'New-IdentityNowSource',
        'New-IdentityNowSourceAccountSchemaAttribute',
        'New-IdentityNowSourceConfigReport',
        'New-IdentityNowUserSourceAccount',
        'New-IdentityNowSourceEntitlements',
        'New-IdentityNowTransform',
        'Remove-IdentityNowAccessProfile',
        'Remove-IdentityNowApplication',
        'Remove-IdentityNowAPIClient',
        'Remove-IdentityNowGovernanceGroup',
        'Remove-IdentityNowOAuthAPIClient',
        'Remove-IdentityNowPersonalAccessToken',
        'Remove-IdentityNowProfile',
        'Remove-IdentityNowRole',
        'Remove-IdentityNowSource'
        'Remove-IdentityNowTransform',
        'Remove-IdentityNowUserSourceAccount',
        'Save-IdentityNowConfiguration',
        'Search-IdentityNow',
        'Search-IdentityNowAccessProfiles',
        'Search-IdentityNowEntitlements',
        'Search-IdentityNowEvents',
        'Search-IdentityNowIdentities',
        'Search-IdentityNowUserProfile',
        'Search-IdentityNowUsers',
        'Send-IdentityNowSourceFile',
        'Set-IdentityNowCredential',
        'Set-IdentityNowIAIIdentityOutlier',
        'Set-IdentityNowOrg',
        'Set-IdentityNowOrgUrl',
        'Set-IdentityNowTimeZone',
        'Set-IdentityNowTransformLookup',
        'Start-IdentityNowCertCampaign',
        'Start-IdentityNowProfileUserRefresh',
        'Test-IdentityNowCredentials',
        'Test-IdentityNowToken',
        'Test-IdentityNowTransforms',
        'Test-IdentityNowSourceConnection',
        'Test-IdentityNowTransforms',
        'Update-IdentityNowAccessProfile',
        'Update-IdentityNowApplication',
        'Update-IdentityNowEmailTemplate',
        'Update-IdentityNowGovernanceGroup',
        'Update-IdentityNowIdentityAttribute',
        'Update-IdentityNowOrgConfig',
        'Update-IdentityNowProfileMapping',
        'Update-IdentityNowProfileOrder',
        'Update-IdentityNowRole',
        'Update-IdentityNowSourceSchema',
        'Update-IdentityNowSource',
        'Update-IdentityNowUserSourceAccount',
        'Update-IdentityNowTransform'
    )
    PrivateData          = @{
        PSData = @{
            ProjectUri = 'https://github.com/darrenjrobinson/powershell_module_identitynow'
        } 
    } 
}
