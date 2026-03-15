function Get-RobopackRadarAppDevices {
    <#
    .SYNOPSIS
    Gets device entries for a Radar app.

    .DESCRIPTION
    Retrieves devices associated with a Radar app for a tenant from the Robopack API endpoint:
    /v1/tenant/{tenantId}/radar/{id}/devices

    .PARAMETER TenantId
    The tenant ID. If omitted, the default tenant ID is used.

    .PARAMETER AppId
    The Radar app object ID.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Get-RobopackRadarAppDevices -AppId "11111111-2222-3333-4444-555555555555" -ApiKey $apiKey
    Retrieves device entries for a Radar app in the default tenant.

    .EXAMPLE
    Get-RobopackRadarAppDevices -TenantId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" -AppId "11111111-2222-3333-4444-555555555555" -ApiKey $apiKey
    Retrieves device entries for a Radar app in a specific tenant.
    #>
    [CmdletBinding()]
    param(
        [Guid] $TenantId,

        [Parameter(Mandatory)]
        [Guid] $AppId,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    if (-not $TenantId) { $TenantId = Get-RobopackDefaultTenantId }

    # Note: the API route expects the Radar object id in the path segment.
    $endpoint = "tenant/$TenantId/radar/$AppId/devices"

    Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}