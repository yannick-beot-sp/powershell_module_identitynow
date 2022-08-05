function Join-IdentityNowAccount {
    <#
.SYNOPSIS
    Join an IdentityNow User Account to an Identity.

.DESCRIPTION
    Manually correlate an IdentityNow User Account with an identity account.

.PARAMETER source
    provide the source ID containing the accounts we wish to join
    SailPoint IdentityNow Source ID
    e.g 12345

.PARAMETER Identity
    Identity UID

.PARAMETER Account
    Account ID

.PARAMETER org
Specifies the IdentityNow Org

.PARAMETER joins
Provide a PowerShell object or array of objects with the property 'identity' and 'account'

.EXAMPLE
    Join-IdentityNowAccount -source 12345 -identity jsmith -account 012345

.EXAMPLE
    $joins=@()
    $joins+=[pscustomobject]@{
            account = $account.nativeIdentity
            displayName = $account.nativeIdentity
            userName = $identity.name
            type = $null
        }
    $joins | Join-IdentityNowAccount -org $org -source $source.id
    
.LINK
    http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding(DefaultParameterSetName = 'SingleAccount')]
    param(
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ParameterSetName = 'SingleAccount')]    
        [Parameter(Mandatory = $false, ParameterSetName = 'MultipleAccounts')]
        [string]$org,    
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'SingleAccount')]
        [Parameter(Mandatory = $true, ParameterSetName = 'MultipleAccounts')]
        [string]$source,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'SingleAccount')]
        [string]$account,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'SingleAccount')]
        [string]$Identity,
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = 'MultipleAccounts')]
        [pscustomobject[]]$joins
    )
    begin {
        $csv = @()
        $csv = $csv + 'account,displayName,userName,type'

    }
    process {
        if ($account) {
            $csv = $csv + "$account,$account,$identity,"
        }
        elseif ($_) {
            $csv = $csv + "$($_.account),$($_.displayName),$($_.userName),$($_.type)"
        }
    }
    end {        
        $v3Token = Get-IdentityNowAuth
        if ($v3Token.access_token) {
            try {
                $result = Invoke-RestMethod -Uri (Get-IdentityNowOrgUrl cc "/source/loadUncorrelatedAccounts/$source") `
                    -Method "POST" `
                    -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)"; "Accept-Encoding" = "gzip, deflate, br" } `
                    -ContentType "multipart/form-data; boundary=----WebKitFormBoundaryU1hSZTy7cff3WW27" `
                    -Body ([System.Text.Encoding]::UTF8.GetBytes("------WebKitFormBoundaryU1hSZTy7cff3WW27$([char]13)$([char]10)Content-Disposition: form-data; name=`"file`"; filename=`"temp.csv`"$([char]13)$([char]10)Content-Type: application/vnd.ms-excel$([char]13)$([char]10)$([char]13)$([char]10)$($csv | out-string)$([char]13)$([char]10)------WebKitFormBoundaryU1hSZTy7cff3WW27--$([char]13)$([char]10)")) `
                    -UseBasicParsing
                return $result           
            }
            catch {
                Write-Error "Account couldn't be joined. $($_)" 
            }
        }
        else {
            Write-Error "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
            return $v3Token
        } 
    }
}
