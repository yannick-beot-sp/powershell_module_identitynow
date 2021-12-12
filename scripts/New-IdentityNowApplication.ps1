function New-IdentityNowApplication {
    <#
.SYNOPSIS
Create an IdentityNow Application.

.DESCRIPTION
Create an IdentityNow Application.

.PARAMETER Name
The name of the Application to create.

.PARAMETER Description
The description of the Application to create.

.EXAMPLE
New-IdentityNowApplication -Name "App1" -Description "Description 1"


.LINK
http://darrenjrobinson.com/sailpoint-identitynow

#>

    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,

        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateNotNullOrEmpty()]
        [string] $description


    )
    Begin {

        $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken
        $headers = @{
            Authorization  = "$($v3Token.token_type) $($v3Token.access_token)" 
            "Content-Type" = "application/json"
        }
        $url = (Get-IdentityNowOrg).'Private Base API URI' + "/app/create"
        
    } # End Begin
    Process {
        
        try {
            $app = @{
                "name"        = $Name
                "description" = $description
            }
            Write-Verbose "Application=$($app |out-string)"
            $json = $app | ConvertTo-Json -Depth 100
            $IDNCreateApp = Invoke-RestMethod -Method Post `
                -Uri  $url `
                -Headers $headers `
                -Body $json
                
            $IDNCreateApp.PSObject.TypeNames.Insert(0, "IdentityNow.ApplicationCC")
           
            return $IDNCreateApp
        }
        catch {
            Write-Error "Creation of Application failed. $($_)"
            throw $_
        }
    } # End Process
} # End Function
    