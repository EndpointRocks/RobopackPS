function ConvertTo-RobopackAuthHeader {
    <#
    .SYNOPSIS
    Builds standard authentication headers for Robopack API requests.

    .DESCRIPTION
    Creates and returns a hashtable containing the Authorization header
    using a bearer token and the Content-Type header set to application/json.

    .PARAMETER ApiKey
    The API key or bearer token used to authenticate against the Robopack API.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey
    )

    return @{
        "Authorization" = "Bearer $ApiKey"
        "Content-Type"  = "application/json"
    }
}
