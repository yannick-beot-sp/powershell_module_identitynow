@{
    RootModule           = 'SailPointIdentityNow.psm1'
    ModuleVersion        = '1.1.5'
    GUID                 = 'f82fe16a-7702-46f3-ab86-5de11b7305de'
    Author               = 'Darren J Robinson'
    Copyright            = '(c) 2021. All rights reserved.'
    Description          = "Orchestration of SailPoint IdentityNow"
    PowerShellVersion    = '5.1'
    CompatiblePSEditions = 'Core', 'Desktop'
    FormatsToProcess     = @("SailPointIdentityNow.Format.ps1xml")
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
        'Get-IdentityNowEmailTemplate',
        'Get-IdentityNowGovernanceGroup',
        'Get-IdentityNowIdentityAttribute',
        'Get-IdentityNowIdentityAttributePreview',
        'Get-IdentityNowOAuthAPIClient',
        'Get-IdentityNowOrg',
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
        'Invoke-IdentityNowAggregateSource',
        'Invoke-IdentityNowRequest',
        'Invoke-IdentityNowSourceReset',
        'Join-IdentityNowAccount',
        'New-IdentityNowAccessProfile',
        'New-IdentityNowAPIClient',
        'New-IdentityNowCertCampaign',        
        'New-IdentityNowGovernanceGroup',
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
        'Search-IdentityNowEntitlements',
        'Search-IdentityNowEvents',
        'Search-IdentityNowIdentities',
        'Search-IdentityNowUserProfile',
        'Search-IdentityNowUsers',
        'Set-IdentityNowCredential',
        'Set-IdentityNowOrg',
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
