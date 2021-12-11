function Set-HttpQueryString {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true)]
        [Uri]
        $Uri,

        [Parameter(Mandatory = $true, ParameterSetName = "ht")]
        [Hashtable]
        $QueryParameters,

        [Parameter(Mandatory = $true, ParameterSetName = "one")]
        [string]
        $Name,

        [Parameter(Mandatory = $true, ParameterSetName = "one")]
        [string]
        $Value
    )
    # Add System.Web
    Add-Type -AssemblyName System.Web
    
    # Create a http name value collection from an empty string
    $nvCollection = [System.Web.HttpUtility]::ParseQueryString($Uri)
    if ($PSCmdlet.ParameterSetName -eq "ht") {
        foreach ($key in $QueryParameter.Keys) {
            $nvCollection.Set($key, $QueryParameter[$key])
        }
    }
    else {
        $nvCollection.Set($Name, $Value)
    }
    # Build the uri
    $uriRequest = [System.UriBuilder]$uri
    $uriRequest.Query = $nvCollection.ToString()
    
    return $uriRequest.Uri.OriginalString
}