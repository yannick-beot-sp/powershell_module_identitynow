function Set-HttpQueryString {
    [CmdletBinding()]
    param 
    (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
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
    $nvCollection = [System.Web.HttpUtility]::ParseQueryString($Uri.Query)
    if ($PSCmdlet.ParameterSetName -eq "ht") {
        foreach ($key in $QueryParameters.Keys) {
            $nvCollection.Set($key, $QueryParameters[$key])
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