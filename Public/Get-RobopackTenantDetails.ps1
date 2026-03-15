function Get-RobopackTenantDetails {
    <#
    .SYNOPSIS
    Gets detailed information for a single Intune tenant.

    .DESCRIPTION
    Retrieves detailed information for a single Intune tenant from the Robopack API endpoint:
    /v1/tenant/{id}

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .PARAMETER TenantId
    ID of target tenant.

    .EXAMPLE
    Get-RobopackTenantDetails -ApiKey $apiKey -TenantId "8876461b-3d64-48b4-88a8-e7d81cbc3d1d"
    Returns detailed information for the specified tenant.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ApiKey,

        [Parameter(Mandatory = $true)]
        [guid]$TenantId
    )

    $endpoint = "tenant/$TenantId"

    Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -ApiKey $ApiKey `
        -ErrorAction Stop
}
