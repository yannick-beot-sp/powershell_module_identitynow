function Test-IdentityNowToken {
    <#
.SYNOPSIS
Helper function to test valid token.

.DESCRIPTION
Helper function to test valid token.

.EXAMPLE
Test-IdentityNowToken -v3Token $token

.LINK
http://darrenjrobinson.com/sailpoint-identitynow
#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNull()]
        $v3Token
    )
    Write-Verbose "> Test-IdentityNowToken"
    $invalidToken = $false
   
    if ($v3Token -is [hashtable]) {
        Write-Verbose "v3Token -is [hashtable]"
        if ((-not ($v3Token.Contains("Authorization"))) -or ("Bearer " -eq $v3Token["Authorization"])) {
            $invalidToken = $true
        }
    }
    elseif ($v3Token -is [PSCustomObject]) {
        Write-Verbose "v3Token -is [PSCustomObject]"
        if (-not ($v3Token.access_token)) {
            $invalidToken = $true
        }
    }
    else {
        throw "Invalid v3Token type: $($v3Token.PSTypeNames | out-string)"
    }
    if ($invalidToken) {
        throw "Authentication Failed. Check your AdminCredential and v3 API ClientID and ClientSecret. $($_)"
    }
    Write-Verbose "< Test-IdentityNowToken"
    return $v3Token
}