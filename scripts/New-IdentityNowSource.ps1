function New-IdentityNowSource {
<#
.SYNOPSIS
Create an IdentityNow Source.

.DESCRIPTION
Create an IdentityNow Source.

.PARAMETER name
(Required - string) The name of the new IdentityNow Source.

.PARAMETER description
(string) The description of the new IdentityNow Source. 

.PARAMETER connectorType
(Required) name of an available connector this source will use, for instance 'Active Directory - Direct'

.PARAMETER connectorname
(Required) name of an available connector this source will use, for instance 'JDBC', 'Active Directory', 'Azure Active Directory', 'Web Services', or 'ServiceNow'

.PARAMETER sourcetype
(Required) must be 'DIRECT_CONNECT' for connecting to a source or 'DELIMITED_FILE' for flat file source

.PARAMETER clusterId
Id of the VA Cluster

.PARAMETER OwnerId
Id of the owner of the source

.PARAMETER attributes
Connector attributes

.LINK
http://darrenjrobinson.com/sailpoint-identitynow

.NOTES
written by Sean McGovern 11/20/2019 (twitter @410sean)

#>
    [cmdletbinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "V1")]
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "V3")]
        [string]$name,
        
        [Parameter(ParameterSetName = "V1")]
        [Parameter(ParameterSetName = "V3")]
        [string]$description,
        
        [Parameter(Mandatory = $true, ParameterSetName = "V1")]
        [string]$connectorname,
        
        [Parameter(Mandatory = $true, ParameterSetName = "V1")]
        [validateset('DIRECT_CONNECT', 'DELIMITED_FILE')]
        [string]$sourcetype,

        
        [Parameter(Mandatory = $true, ParameterSetName = "V3")]
        [string]$connectorType, 
        
        [Parameter(Mandatory = $true, ParameterSetName = "V3")]
        [string]$clusterId,
        
        [Parameter(Mandatory = $true, ParameterSetName = "V3")]
        [string]$OwnerId,
        
        [Parameter(ParameterSetName = "V3")]
        [hashtable]$attributes
        
    )
    $v3Token = Get-IdentityNowAuth | Test-IdentityNowToken

    if ($PSCmdlet.ParameterSetName -eq "V1") {
        try {
            $privateuribase = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com"
            $url = "$privateuribase/cc/api/source/create"
            $body = "serviceDefinitionName=$connectorname&name=$name&description=$description&sourceType=$sourcetype&serviceType=app"
            $response = Invoke-WebRequest -Uri $url -Method Post -UseBasicParsing -Body $body -ContentType 'application/x-www-form-urlencoded' -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            $sourceAccountProfile = $response.Content | ConvertFrom-Json
            return $sourceAccountProfile
        }
        catch {
            Write-Error "Creation of new Source failed. Check Source Configuration. $($_)"
            throw $_
        }

    }
    else {
        # ParameterSetName -eq "V3"
        $connector = Get-IdentityNowConnectors | ? type -eq $connectorType

        $body = @{
            "description"     = $description
            "owner"           = @{
                "type" = "IDENTITY"
                "id"   = $OwnerId
            }
            "cluster"         = @{
                "type" = "CLUSTER"
                "id"   = $clusterId
            }
            "type"            = $connector.type
            "connector"       = $connector.scriptName
            "connectorClass"  = $connector.className
            "deleteThreshold" = 10
            "name"            = $name
        }
    
        if ($attributes) {
            $body.Add("connectorAttributes", $attributes)
        }
    
        try {

            $uri = "https://$($IdentityNowConfiguration.orgName).api.identitynow.com/v3/sources"
            $response = Invoke-RestMethod -Uri $uri -Method Post `
                -Body ($body | ConvertTo-Json -Depth 100) `
                -ContentType 'application/json' `
                -Headers @{Authorization = "$($v3Token.token_type) $($v3Token.access_token)" }
            $response.PSObject.TypeNames.Insert(0, "IdentityNow.Source")
            return $response
        }
        catch {
            Write-Error "Creation of new Source failed. Check Source Configuration. $($_)" 
            throw $_
        }
    }
}
    
