function Invoke-RobopackPackageContentFinalize {
    <#
    .SYNOPSIS
    Finalizes a package content upload.

    .DESCRIPTION
    Calls POST /v1/package/content/{id}/finalize with file metadata.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .PARAMETER PackageId
    ID of the package upload to finalize.

    .PARAMETER Files
    Ordered list of uploaded files. Each entry must include:
    - fileName (relative path from content root)
    - fileSize (bytes)
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey,

        [Parameter(Mandatory)]
        [guid]$PackageId,

        [Parameter(Mandatory)]
        [array]$Files
    )

    $uri = "https://api.robopack.com/v1/package/content/$PackageId/finalize"
    $headers = @{ "X-API-Key" = $ApiKey }
    if ($Files.Count -eq 0) {
        throw "At least one file entry is required to finalize upload."
    }

    $body = @{
        files = $Files
    } | ConvertTo-Json -Depth 6

    try {
        return Invoke-RestMethod `
            -Method POST `
            -Uri $uri `
            -Headers $headers `
            -Body $body `
            -ContentType "application/json"
    }
    catch {
        throw "Failed to finalize upload for package ${PackageId}: $($_.Exception.Message)"
    }
}
