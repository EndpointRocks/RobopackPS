function Get-RobopackTenants {
    <#
    .SYNOPSIS
    Lists tenants in the current Robopack account.

    .DESCRIPTION
    Retrieves a list of Intune tenants from the Robopack API endpoint:
    /v1/tenant

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Get-RobopackTenants -ApiKey $apiKey
    Returns all tenants available in the account.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey
    )

    $endpoint = "tenant"

    return Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}
