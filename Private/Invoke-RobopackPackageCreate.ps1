function Invoke-RobopackPackageCreate {
    <#
    .SYNOPSIS
    Creates a remote package record before content upload.

    .DESCRIPTION
    Calls POST /v1/package/create with package metadata and returns
    the created package object.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .PARAMETER Metadata
    Hashtable containing metadata for package creation.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey,

        [Parameter(Mandatory)]
        [hashtable]$Metadata
    )

    $uri = "https://api.robopack.com/v1/package/create"
    $headers = @{ "X-API-Key" = $ApiKey }
    $body = $Metadata | ConvertTo-Json -Depth 10

    try {
        $response = Invoke-RestMethod `
            -Method POST `
            -Uri $uri `
            -Headers $headers `
            -Body $body `
            -ContentType "application/json"

        $packageId = $null
        if ($response.PSObject.Properties.Name -contains "id") {
            $packageId = [string]$response.id
        }

        if ([string]::IsNullOrWhiteSpace($packageId)) {
            throw "Create package succeeded but no package id was returned."
        }

        return $response
    }
    catch {
        throw "Failed to create package: $($_.Exception.Message)"
    }
}
