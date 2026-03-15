function Invoke-RobopackPackageContentChunkUpload {
    <#
    .SYNOPSIS
    Uploads one binary content chunk for a package.

    .DESCRIPTION
    Calls POST /v1/package/content/{id} with chunk bytes and query parameters.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .PARAMETER PackageId
    ID of the package being uploaded.

    .PARAMETER ChunkBytes
    Raw bytes for this chunk.

    .PARAMETER Index
    Index of the file being uploaded.

    .PARAMETER Size
    Size in bytes of this chunk.

    .PARAMETER Offset
    Offset in bytes from the start of the file.

    .PARAMETER Chunk
    Sequential chunk index.

    .PARAMETER MaxRetries
    Maximum retries after the first attempt.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey,

        [Parameter(Mandatory)]
        [guid]$PackageId,

        [Parameter(Mandatory)]
        [byte[]]$ChunkBytes,

        [Parameter(Mandatory)]
        [int]$Index,

        [Parameter(Mandatory)]
        [int]$Size,

        [Parameter()]
        [long]$Offset = 0,

        [Parameter()]
        [int]$Chunk = 0,

        [Parameter()]
        [ValidateRange(0, 10)]
        [int]$MaxRetries = 2
    )

    $baseUri = "https://api.robopack.com/v1/package/content/$PackageId"
    $query = "index=$Index&size=$Size&offset=$Offset&chunk=$Chunk"
    $uri = "$baseUri`?$query"
    $headers = @{ "X-API-Key" = $ApiKey }

    $attempt = 0
    while ($attempt -le $MaxRetries) {
        try {
            $response = Invoke-WebRequest `
                -Method POST `
                -Uri $uri `
                -Headers $headers `
                -Body $ChunkBytes `
                -ContentType "application/octet-stream"

            return [pscustomobject]@{
                Success      = $true
                PackageId    = $PackageId
                ChunkIndex   = $Chunk
                Offset       = $Offset
                ChunkSize    = $Size
                AttemptsUsed = ($attempt + 1)
                StatusCode   = [int]$response.StatusCode
            }
        }
        catch {
            if ($attempt -ge $MaxRetries) {
                throw "Chunk upload failed for package $PackageId at chunk $Chunk (offset $Offset, size $Size) after $($attempt + 1) attempts. Error: $($_.Exception.Message)"
            }

            $attempt++
            Start-Sleep -Seconds $attempt
        }
    }
}
