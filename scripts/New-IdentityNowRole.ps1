function New-IdentityNowRole {
    <#
.SYNOPSIS
Create an IdentityNow Role.

.PARAMETER role
(required - JSON) The configuration for the new IdentityNow Role.

.EXAMPLE
New-IdentityNowRole -role "{"description":  "Special Admins Role","name":  "Role - Special Admins","owner":  "darren.robinson","displayName":  "Special Admins","disabled":  false}"

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "jsonstring")]
        [string]$role,
        
        [ValidateNotNullOrEmpty()]
        [string] $name,

        [ValidateNotNullOrEmpty()]
        [string] $description,

        [ValidateNotNullOrEmpty()]
        [string] $ownerId,

        [ValidateNotNullOrEmpty()]
        [string] $ownerName,

        [ValidateNotNullOrEmpty()]
        [string[]] $accessProfileIds,
        
        [ValidateNotNullOrEmpty()]
        [string[]] $accessProfileNames,

        [ValidateNotNullOrEmpty()]
        [string[]] $identityIds,

        [ValidateNotNullOrEmpty()]
        [string[]] $identityNames,

        [Object[]] $ApprovalSchemes = @(),

        [string[]] $RevocationApprovalSchemes = @(),

        [switch] $requestCommentsRequired,

        [switch] $deniedCommentsRequired,

        [switch] $NonRequestable

    )

    Begin {

        $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{
            Authorization  = "$($v3Token.token_type) $($v3Token.access_token)" 
            "Content-Type" = "application/json"
        }
        $betaturl = Get-IdentityNowOrgUrl Beta "/roles"
        

    } # End Begin
    Process {

        if ($v3Token.access_token) {
            try {
                $IDNNewRoles = Invoke-RestMethod -Method Post -Uri (Get-IdentityNowOrgUrl cc "/role/create") -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "content-type" = "application/json" } -Body $role
                return $IDNNewRoles
            }
            catch {
                Write-Error "Creation of new Role failed. Check Role Configuration. $($_)" 
            }
        }
        else {
            Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
            return $v3Token
        } 
    }
}

