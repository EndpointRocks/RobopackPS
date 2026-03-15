function Get-RobopackRadarEntryDevices {
    <#
    .SYNOPSIS
    Gets device entries for a Radar entry.

    .DESCRIPTION
    Retrieves devices associated with a specific Radar entry for a tenant from the Robopack API endpoint:
    /v1/tenant/{tenantId}/radar/entry/{entryId}/devices

    .PARAMETER TenantId
    The tenant ID. If omitted, the default tenant ID is used.

    .PARAMETER EntryId
    The Radar entry ID.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Get-RobopackRadarEntryDevices -EntryId "11111111-2222-3333-4444-555555555555" -ApiKey $apiKey
    Retrieves device entries for a Radar entry in the default tenant.

    .EXAMPLE
    Get-RobopackRadarEntryDevices -TenantId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee" -EntryId "11111111-2222-3333-4444-555555555555" -ApiKey $apiKey
    Retrieves device entries for a Radar entry in a specific tenant.
    #>
    [CmdletBinding()]
    param(
        [Guid] $TenantId,

        [Parameter(Mandatory)]
        [Guid] $EntryId,

        [Parameter(Mandatory)]
        [string] $ApiKey
    )

    if (-not $TenantId) { $TenantId = Get-RobopackDefaultTenantId }

    $endpoint = "tenant/$TenantId/radar/entry/$EntryId/devices"

    Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}
