function Get-RobopackInstantAppsDetails {
    <#
    .SYNOPSIS
    Gets Instant app details.

    .DESCRIPTION
    Retrieves detailed information for a single Instant app from the Robopack API endpoint:
    /v1/app/{id}

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .PARAMETER AppId
    ID of the Instant app.

    .EXAMPLE
    Get-RobopackInstantAppsDetails -ApiKey $apiKey -AppId "11111111-2222-3333-4444-555555555555"
    Retrieves details for a single Instant app.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [guid]$AppId,

        [Parameter(Mandatory = $true)]
        [string]$ApiKey
    )

    $endpoint = "app/$AppId"

    return Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}
