function Get-RobopackPackageDetails {
    <#
    .SYNOPSIS
    Gets package details.

    .DESCRIPTION
    Retrieves detailed information for a single package from the Robopack API endpoint:
    /v1/package/{id}

    .PARAMETER PackageId
    ID of target package.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Get-RobopackPackageDetails -ApiKey $apiKey -PackageId "11111111-2222-3333-4444-555555555555"
    Returns detailed information for the specified package.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [guid]$PackageId,

        [Parameter(Mandatory)]
        [string]$ApiKey
    )

    $endpoint = "package/$PackageId"

    return Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}