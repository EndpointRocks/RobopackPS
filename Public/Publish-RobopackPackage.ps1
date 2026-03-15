function Publish-RobopackPackage {
    <#
    .SYNOPSIS
    Publishes a package using create, chunk upload, and finalize lifecycle.

    .DESCRIPTION
    Validates a local package, creates a remote package record using metadata,
    uploads package content in chunks, and finalizes the upload.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .PARAMETER PackagePath
    Path to the local package folder.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey,

        [Parameter(Mandatory)]
        [string]$PackagePath
    )

    $chunkSizeBytes = 4MB
    $maxRetriesPerChunk = 2
    $packageId = $null

    if (-not (Test-Path -Path $PackagePath)) {
        throw "Package path does not exist: $PackagePath"
    }

    if (-not (Test-RobopackPackage -Path $PackagePath)) {
        throw "Package validation failed. Cannot publish."
    }

    $resolvedPackagePath = (Resolve-Path -Path $PackagePath).Path

    $metadataPath = Join-Path $resolvedPackagePath "metadata.json"
    if (-not (Test-Path -Path $metadataPath)) {
        throw "metadata.json is missing in package folder: $resolvedPackagePath"
    }

    $contentPath = Join-Path $resolvedPackagePath "Content"
    if (-not (Test-Path -Path $contentPath)) {
        throw "Content folder is missing in package folder: $resolvedPackagePath"
    }

    $filesToUpload = Get-ChildItem -Path $contentPath -File -Recurse | Sort-Object FullName
    if ($filesToUpload.Count -eq 0) {
        throw "No files found in Content folder. Add installer/content files before publish."
    }

    $rawMetadata = Get-Content -Path $metadataPath -Raw | ConvertFrom-Json -AsHashtable

    $name = if ($rawMetadata.fullProductName) { [string]$rawMetadata.fullProductName } elseif ($rawMetadata.productName) { [string]$rawMetadata.productName } else { [string]$rawMetadata.name }
    $publisher = if ($rawMetadata.manufacturer) { [string]$rawMetadata.manufacturer } elseif ($rawMetadata.publisher) { [string]$rawMetadata.publisher } else { $null }
    $version = if ($rawMetadata.productVersion) { [string]$rawMetadata.productVersion } elseif ($rawMetadata.version) { [string]$rawMetadata.version } else { $null }
    $installCommand = if ($rawMetadata.installCommand) { [string]$rawMetadata.installCommand } elseif ($rawMetadata.install) { [string]$rawMetadata.install } else { $null }
    $uninstallCommand = if ($rawMetadata.uninstallCommand) { [string]$rawMetadata.uninstallCommand } elseif ($rawMetadata.uninstall) { [string]$rawMetadata.uninstall } else { $null }

    $inferredSourceType = "zip"
    if ($filesToUpload.Count -eq 1) {
        $ext = $filesToUpload[0].Extension.ToLowerInvariant()
        if ($ext -eq ".msi") { $inferredSourceType = "msi" }
        elseif ($ext -eq ".exe") { $inferredSourceType = "exe" }
        elseif ($ext -eq ".zip") { $inferredSourceType = "zip" }
    }

    $sourceType = if ($rawMetadata.sourceType) { [string]$rawMetadata.sourceType } else { $inferredSourceType }

    $allowedSourceTypes = @("msi", "zip", "exe")
    if ($allowedSourceTypes -notcontains $sourceType.ToLowerInvariant()) {
        throw "Invalid sourceType '$sourceType'. Allowed values are: msi, zip, exe."
    }

    $createMetadata = @{
        name       = $name
        sourceType = $sourceType.ToLowerInvariant()
    }

    if (-not [string]::IsNullOrWhiteSpace($publisher)) {
        $createMetadata.publisher = $publisher
    }

    if (-not [string]::IsNullOrWhiteSpace($version)) {
        $createMetadata.version = $version
    }

    if (-not [string]::IsNullOrWhiteSpace($installCommand)) {
        $createMetadata.installCommand = $installCommand
    }

    if (-not [string]::IsNullOrWhiteSpace($uninstallCommand)) {
        $createMetadata.uninstallCommand = $uninstallCommand
    }

    if ($rawMetadata.ContainsKey("userContext")) {
        $createMetadata.userContext = [bool]$rawMetadata.userContext
    }

    if ($rawMetadata.ContainsKey("runAnalysis")) {
        $createMetadata.runAnalysis = [bool]$rawMetadata.runAnalysis
    }

    if ($rawMetadata.scriptTemplateId -and -not [string]::IsNullOrWhiteSpace([string]$rawMetadata.scriptTemplateId)) {
        $createMetadata.scriptTemplateId = [string]$rawMetadata.scriptTemplateId
    }

    if ($rawMetadata.ContainsKey("detectionRules") -and $rawMetadata.detectionRules) {
        $createMetadata.detectionRules = $rawMetadata.detectionRules
    }

    if ($rawMetadata.logoData -and -not [string]::IsNullOrWhiteSpace([string]$rawMetadata.logoData)) {
        $createMetadata.logoData = [string]$rawMetadata.logoData
    }

    if ([string]::IsNullOrWhiteSpace([string]$createMetadata.name)) {
        throw "Package metadata is missing name/fullProductName/productName."
    }

    Write-Verbose "Creating remote package..."
    $createResponse = Invoke-RobopackPackageCreate -ApiKey $ApiKey -Metadata $createMetadata
    $packageId = [guid]$createResponse.id

    $finalizeFiles = @()
    $fileCount = $filesToUpload.Count
    $currentFileNumber = 0

    foreach ($file in $filesToUpload) {
        $currentFileNumber++
        $relativePath = [System.IO.Path]::GetRelativePath($contentPath, $file.FullName) -replace '\\','/'
        if ([string]::IsNullOrWhiteSpace($relativePath)) {
            throw "Failed to resolve relative content path for file: $($file.FullName)"
        }
        $finalizeFiles += @{
            fileName = $relativePath
            fileSize = [long]$file.Length
        }

        $totalBytes = [long]$file.Length
        $totalChunks = [int][Math]::Ceiling($totalBytes / [double]$chunkSizeBytes)
        $buffer = New-Object byte[] $chunkSizeBytes

        Write-Verbose "Uploading file $currentFileNumber/${fileCount}: $relativePath ($totalChunks chunk(s))..."

        $stream = [System.IO.File]::OpenRead($file.FullName)
        try {
            $offset = 0L
            $chunkIndex = 0

            while ($offset -lt $totalBytes) {
                $remaining = $totalBytes - $offset
                $toRead = [int][Math]::Min($chunkSizeBytes, $remaining)
                $read = $stream.Read($buffer, 0, $toRead)

                if ($read -le 0) {
                    throw "Unexpected end of file while reading chunk at offset $offset for file $relativePath."
                }

                $chunkBytes = New-Object byte[] $read
                [System.Array]::Copy($buffer, 0, $chunkBytes, 0, $read)

                $percent = [int](($chunkIndex + 1) * 100 / $totalChunks)
                Write-Progress `
                    -Activity "Uploading package content ($currentFileNumber/${fileCount}): $relativePath" `
                    -Status "Chunk $($chunkIndex + 1) of $totalChunks" `
                    -PercentComplete $percent

                try {
                    Invoke-RobopackPackageContentChunkUpload `
                        -ApiKey $ApiKey `
                        -PackageId $packageId `
                        -ChunkBytes $chunkBytes `
                        -Index ($currentFileNumber - 1) `
                        -Size $read `
                        -Offset $offset `
                        -Chunk $chunkIndex `
                        -MaxRetries $maxRetriesPerChunk | Out-Null
                }
                catch {
                    throw "Upload failed for package $packageId at file '$relativePath' (index $($currentFileNumber - 1)), chunk $chunkIndex of $totalChunks. Recommended next step: rerun Publish-RobopackPackage for this package. Details: $($_.Exception.Message)"
                }

                $offset += $read
                $chunkIndex++
            }
        }
        finally {
            $stream.Dispose()
            Write-Progress -Activity "Uploading package content ($currentFileNumber/${fileCount}): $relativePath" -Completed
        }
    }

    Write-Verbose "Finalizing upload..."
    $finalizeResponse = Invoke-RobopackPackageContentFinalize `
        -ApiKey $ApiKey `
        -PackageId $packageId `
        -Files $finalizeFiles

    Write-Verbose "Package published successfully."
    return [pscustomobject]@{
        PackageId    = $packageId
        FilesUploaded = $fileCount
        Created      = $createResponse
        Finalized    = $finalizeResponse
    }
}
