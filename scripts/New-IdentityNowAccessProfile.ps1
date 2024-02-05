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
$accessProfile.add("approvalSchemes",  @(@{approverType="MANAGER"}) )
$accessProfile.add("requestCommentsRequired", $true)
$accessProfile.add("deniedCommentsRequired", $true)

New-IdentityNowAccessProfile -profile (convertto-json $accessProfile)

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
    -approvalSchemes @{approverType="MANAGER"} `
    -requestCommentsRequired `
    -deniedCommentsRequired 

.EXAMPLE
Filter entitlement based on value
New-IdentityNowAccessProfile -name Test3 -ownerName "darren.robinson" -sourceName "Active Directory" -entitlementNames "value:CN=AccountingGeneral,OU=Groups,OU=Demo,DC=seri,DC=sailpointdemo,DC=com"

.EXAMPLE
Filter entitlement based on name
New-IdentityNowAccessProfile -name Test3 -ownerName "darren.robinson" -sourceName "Active Directory" -entitlementNames "name:AccountingGeneral"

.EXAMPLE
Filter entitlement based on name
New-IdentityNowAccessProfile -name Test3 -ownerName "darren.robinson" -sourceName "Active Directory" -entitlementNames "AccountingGeneral"

.EXAMPLE
Filter entitlement based on attribute (memberOf)
New-IdentityNowAccessProfile -name Test3 -ownerName "darren.robinson" -sourceName "Active Directory" -entitlementNames "memberOf:CN=AccountingGeneral,OU=Groups,OU=Demo,DC=seri,DC=sailpointdemo,DC=com"
.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "jsonstring")]
        [Alias('profile')]
        [string]$AccessProfile,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEN")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEN")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEN")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEN")]
        [ValidateNotNullOrEmpty()]
        [string] $name,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEN")]
        [ValidateNotNullOrEmpty()]
        [string] $description,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEN")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEN")]
        [ValidateNotNullOrEmpty()]
        [string] $ownerId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEN")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEN")]
        [ValidateNotNullOrEmpty()]
        [string] $ownerName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEN")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEN")]
        [ValidateNotNullOrEmpty()]
        [string] $sourceId,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEN")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEN")]
        [ValidateNotNullOrEmpty()]
        [string] $sourceName,

        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEI")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEI")]
        [ValidateNotNullOrEmpty()]
        [string[]] $entitlementIds,
        
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEN")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEN")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEN")]
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEN")]
        [ValidateNotNullOrEmpty()]
        [string[]] $entitlementNames,
        
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEN")]
        [Object[]]$ApprovalSchemes = @(),

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEN")]
        [string[]]$RevocationApprovalSchemes = @(),

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEN")]
        [switch]$requestCommentsRequired,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEN")]
        [switch]$deniedCommentsRequired,

        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISIEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "OISNEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSIEN")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEI")]
        [Parameter(Mandatory = $false, ValueFromPipelineByPropertyName = $true, ParameterSetName = "ONSNEN")]
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
                    $url = Get-IdentityNowOrgUrl v2 "/access-profiles"
                }
                else {
                    Write-Verbose "using Beta endpoint"
                    $url = $betaturl
                }
            }
            else {
                Write-Verbose "Constructing Access Profile and using Beta endpoint"
                $url = $betaturl
                # Get source id if provided by name
                if ($sourceName) {
                    $source = Get-IdentityNowSource -Name $sourceName
                    $sourceId = $source.id
                }
                
                Write-Verbose "sourceId=$sourceId"
                
                # Get owner id if provided by name
                if ($ownerName) {
                    $owner = Get-IdentityNowPublicIdentity alias -eq $ownerName
                    $ownerId = $owner.id
                }

                Write-Verbose "ownerId=$ownerId"

                #get entitlement ids if provided by name
                if ($entitlementNames) {
                    $filterTemplate = "source.id eq `"$sourceId`" and "
                    foreach ($entitlementName in $entitlementNames) {
                        $filter = $filterTemplate
                        if ($entitlementName -match "^(?<attribute>[a-zA-Z]+?):(?<value>.*)") {
                            # Note ConvertTo-Json includes the double-quotes in its output
                            if ($Matches.attribute -eq "name" -or $Matches.attribute -eq "value") {
                                $filter += "$($Matches.attribute) eq $($Matches.value | ConvertTo-Json)"
                            }
                            else {
                                $filter += "value eq $($Matches.value | ConvertTo-Json) and attribute eq $($Matches.attribute | ConvertTo-Json)"
                            }

                        }
                        else {
                            $filter += 'name eq "' + $entitlementName + '"'
                        }
                        $entitlement = Get-IdentityNowEntitlement -filters $filter
                        if (-not $entitlement) {
                            throw "Could not find entitlement $entitlementName"
                        }
                        
                        if (($entitlement | Measure-Object).Count -ne 1) {
                            throw "Ambiguous entitlement $entitlementName. Found $(($entitlement | Measure-Object).Count) entitlement"
                        }
                        $entitlementIds += $entitlement.id
                    }
                }

                # building entitlements refs
                $entitlementsRef = @()
                foreach ($entitlement in $entitlementIds) {
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
                $AccessProfile = ConvertTo-Json  $accessProfileHt -Depth 100
            }
            Write-Verbose "Access Profile=$AccessProfile"
            Write-Verbose "Url=$url"
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
    