function Save-RobopackPackageDocumentationPdf {
    <#
    .SYNOPSIS
    Downloads package PDF documentation.

    .DESCRIPTION
    Downloads a PDF file containing App Documentation for a package from the
    Robopack API endpoint:
    /v1/package/{id}/documentation/pdf
    The file is saved to the specified output directory.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .PARAMETER PackageId
    ID of the package to download documentation for.

    .PARAMETER OutputPath
    Directory path where the downloaded PDF file is saved.

    .EXAMPLE
    Save-RobopackPackageDocumentationPdf -ApiKey $apiKey -PackageId "11111111-2222-3333-4444-555555555555" -OutputPath ".\Downloads"
    Downloads the package documentation PDF to the specified output directory.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey,

        [Parameter(Mandatory)]
        [guid]$PackageId,

        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    $OutputPath = Resolve-RobopackPath -Path $OutputPath
    $File = Join-Path $OutputPath "$PackageId-documentation.pdf"
    $endpoint = "package/$PackageId/documentation/pdf"

    Write-Verbose "Downloading package PDF documentation..."
    Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -OutFile $File `
        -ApiKey $ApiKey | Out-Null
    Write-Verbose "Download completed: $File"

    return $File
}
