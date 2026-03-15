function Get-RobopackTenantUploadStatus {
    <#
    .SYNOPSIS
    Gets status for an Intune upload task.

    .DESCRIPTION
    Retrieves status information for a single Intune upload task from the Robopack API endpoint:
    /v1/tenant/upload/{uploadId}

    .PARAMETER UploadId
    ID of target upload task.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Get-RobopackTenantUploadStatus -ApiKey $apiKey -UploadId "11111111-2222-3333-4444-555555555555"
    Returns status for the specified Intune upload task.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [guid]$UploadId,

        [Parameter(Mandatory)]
        [string]$ApiKey
    )

    $endpoint = "tenant/upload/$UploadId"

    return Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}