function Save-RobopackPackageFile {
    <#
    .SYNOPSIS
    Downloads a package file in a specified format.

    .DESCRIPTION
    Downloads a package from the Robopack API endpoint:
    /v1/package/{id}/download
    Supports selecting package format, script wrapping behavior, and optional template.
    The downloaded file is saved to the specified output path.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .PARAMETER PackageId
    ID of the package to download.

    .PARAMETER Format
    The format to download the package as.
    Default: 4.
    Not all packages support all formats.

    .PARAMETER NoScriptWrap
    If set to $true, the package is not wrapped in an installation script.
    Default: $false.

    .PARAMETER TemplateId
    ID of script template to use for wrapping the package.
    If not specified, the package default template is used.

    .PARAMETER OutputPath
    Directory path where the downloaded package file is saved.

    .EXAMPLE
    Save-RobopackPackageFile -ApiKey $apiKey -PackageId "11111111-2222-3333-4444-555555555555" -OutputPath ".\\Downloads"
    Downloads the package with default format (4) and default script wrapping.

    .EXAMPLE
    Save-RobopackPackageFile -ApiKey $apiKey -PackageId "11111111-2222-3333-4444-555555555555" -Format 2 -NoScriptWrap $true -OutputPath ".\\Downloads"
    Downloads the package in format 2 without script wrapping.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$ApiKey,

        [Parameter(Mandatory)]
        [guid]$PackageId,

        [Parameter()]
        [int]$Format = 4,

        [Parameter()]
        [bool]$NoScriptWrap = $false,

        [Parameter()]
        [Nullable[guid]]$TemplateId = $null,

        [Parameter(Mandatory)]
        [string]$OutputPath
    )

    $OutputPath = Resolve-RobopackPath -Path $OutputPath

    $File = Join-Path $OutputPath "$PackageId-format-$Format.zip"

    Write-Verbose "Downloading package file..."
    Invoke-RobopackApi `
        -Method GET `
        -Endpoint "package/$PackageId/download" `
        -Query @{
            format       = $Format
            noScriptWrap = $NoScriptWrap
            templateId   = $TemplateId
        } `
        -OutFile $File `
        -ApiKey $ApiKey | Out-Null
    Write-Verbose "Download completed: $File"

    return $File
}
