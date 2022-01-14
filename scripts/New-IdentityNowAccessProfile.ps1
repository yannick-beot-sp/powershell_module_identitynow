function New-IdentityNowAccessProfile {
    <#
.SYNOPSIS
Create an IdentityNow Access Profile.

.DESCRIPTION
Create an IdentityNow Access Profile.

.PARAMETER profile
(required - JSON) The profile of the IdentityNow Access Profile to create.

.EXAMPLE
New-IdentityNowAccessProfile -profile "{"entitlements":  ["2c91808668dcf3970168dd722e7a020d","2c91808468dcf4610168dd78d2e8531e"],"description":  "FS-SYDNEY-AUS-ENGINEERING","requestCommentsRequired":  true,"sourceId":  "39082","approvalSchemes":  "manager","ownerId":  "1397606","name":  "Sydney Engineering","deniedCommentsRequired":  true}"

.EXAMPLE
# Get Owner for Access Profile
$owner = Search-IdentityNowUserProfile -query "darren.robinson"

# Get Source for Access Proile
$adSource = Get-IdentityNowSource -name "Active Directory"

# Entitlements
$entitlements = Search-IdentityNowEntitlements -query "FS-SYDNEY-AUS-ENGINEERING"
$entitlementIds  = $entitlements  | Select-Object -ExpandProperty id

# Access Profile Details
$accessProfile = @{}
$accessProfile.add("name", "Sydney Engineering")
$accessProfile.add("description", "FS-SYDNEY-AUS-ENGINEERING")
$accessProfile.add("sourceId", $adSource.id)
$accessProfile.add("ownerId", $owner.id)

# Access Profile Entitlements

$entitlementsToAdd = @{"entitlements" = $entitlementIds}
$accessProfile.add("entitlements", $entitlementsToAdd.entitlements)

# Access Profile Type
$accessProfile.add("approvalSchemes", "manager")
$accessProfile.add("requestCommentsRequired", $true)
$accessProfile.add("deniedCommentsRequired", $true)

New-IdentityNowAccessProfile -profile ($accessProfile | convertto-json)

.EXAMPLE
# Get Owner for Access Profile
$owner = Search-IdentityNowUserProfile -query "darren.robinson"

# Get Source for Access Proile
$adSource = Get-IdentityNowSource -name "Active Directory"

# Entitlements
$entitlements = Search-IdentityNowEntitlements -query "FS-SYDNEY-AUS-ENGINEERING"
$entitlementIds  = $entitlements  | Select-Object -ExpandProperty id


New-IdentityNowAccessProfile -name "Sydney Engineering" `
    -description  "FS-SYDNEY-AUS-ENGINEERING" `
    -sourceId $adSource.id `
    -ownerId $owner.id `
    -entitlements $entitlementIds `
    -approvalSchemes "manager" `
    -requestCommentsRequired `
    -deniedCommentsRequired 


New-IdentityNowAccessProfile -name "Custom PRISM - Modify_Reports" `
    -description  "Custom PRISM - Modify_Reports" `
    -sourceId $Source.id `
    -ownerId $owner.id `
    -entitlements $entitlementIds `
    -approvalSchemes "manager" `
    -requestCommentsRequired `
    -deniedCommentsRequired 


.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "jsonstring")]
        [Alias('profile')]
        [string]$AccessProfile,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "detailed")]
        [ValidateNotNullOrEmpty()]
        [string] $name,
        [string] $description,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "detailed")]
        [ValidateNotNullOrEmpty()]
        [string] $ownerId,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "detailed")]
        [ValidateNotNullOrEmpty()]
        [string] $sourceId,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "detailed")]
        [ValidateNotNullOrEmpty()]
        [string[]] $entitlements,
        
        [Parameter(ValueFromPipeline = $true, ParameterSetName = "detailed")]
        [string[]]$ApprovalSchemes = @(),

        [Parameter(ValueFromPipeline = $true, ParameterSetName = "detailed")]
        [string[]]$RevocationApprovalSchemes= @(),

        [Parameter(ValueFromPipeline = $true, ParameterSetName = "detailed")]
        [switch]$requestCommentsRequired,

        [Parameter(ValueFromPipeline = $true, ParameterSetName = "detailed")]
        [switch]$deniedCommentsRequired,

        [Parameter(ValueFromPipeline = $true, ParameterSetName = "detailed")]
        [switch]$NonRequestable

    )
    Begin {

        $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{
            Authorization  = "$($v3Token.token_type) $($v3Token.access_token)" 
            "Content-Type" = "application/json"
        }
        $betaturl = (Get-IdentityNowOrg).Beta + "/access-profiles"
        

    } # End Begin
    Process {
        $usingV2 = $false 
        try {
            if ($PSCmdlet.ParameterSetName -eq "jsonstring") {
                $json = $AccessProfile | ConvertFrom-Json
                   
                if ($json.ownerId) {
                    Write-Verbose "using V2 endpoint"
                    $usingV2 = $true
                    $url = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v2/access-profiles"
                }
                else {
                    Write-Verbose "using Beta endpoint"
                    $url = $betaturl
                }
            }
            else {
                Write-Verbose "Constructing Access Profile and using Beta endpoint"
                $url = $betaturl
                $entitlementsRef = @()
                foreach ($entitlement in $entitlements) {
                    $entitlementsRef += @{
                        "type" = "ENTITLEMENT"
                        "id"   = $entitlement
                    }
                }

                $accessProfileHt = @{
                    "name"                    = $name
                    "enabled"                 = $true
                    "description"             = $description
                    "owner"                   = @{
                        "id"   = $ownerId
                        "type" = "IDENTITY"
                    }
                    "source"                  = @{
                        "id"   = $sourceId
                        "type" = "SOURCE"
                    }
                    "entitlements"            = $entitlementsRef
                    "requestable"             = (!$NonRequestable.IsPresent)
                    "accessRequestConfig"     = @{
                        "commentsRequired"       = $requestCommentsRequired.IsPresent
                        "denialCommentsRequired" = $deniedCommentsRequired.IsPresent
                        "approvalSchemes"        = $ApprovalSchemes
                    }
                    "revocationRequestConfig" = @{
                        "approvalSchemes" = $RevocationApprovalSchemes
                    }
                }
                $AccessProfile = $accessProfileHt | ConvertTo-Json -Depth 100
            }
            Write-Verbose "Access Profile=$AccessProfile"
            $IDNCreateAP = Invoke-RestMethod -Method Post `
                -Uri  $url `
                -Headers $headers `
                -Body $AccessProfile
                
            if ($usingV2) {
                $IDNCreateAP.PSObject.TypeNames.Insert(0, "IdentityNow.AccessProfileV2")
            }
            else {
                $IDNCreateAP.PSObject.TypeNames.Insert(0, "IdentityNow.AccessProfile")
            }
            return $IDNCreateAP
        }
        catch {
            Write-Error "Creation of Access Profile failed. Check Access Profile configuration (JSON). $($_)"
            throw $_
        }
    } # End Process
} # End Function
    