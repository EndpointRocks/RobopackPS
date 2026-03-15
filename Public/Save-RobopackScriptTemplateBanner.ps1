function Save-RobopackScriptTemplateBanner {
    <#
    .SYNOPSIS
    Downloads a script template banner image.

    .DESCRIPTION
    Downloads the banner image for a single script template from the Robopack API endpoint:
    /v1/template/{id}/banner
    The file is saved to the specified output directory.

    .PARAMETER TemplateId
    ID of target script template.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .PARAMETER OutputPath
    Directory path where the downloaded banner image is saved.

    .EXAMPLE
    Save-RobopackScriptTemplateBanner -ApiKey $apiKey -TemplateId "11111111-2222-3333-4444-555555555555" -OutputPath ".\Downloads"
    Saves the banner image as a PNG file in the output directory.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [guid]$TemplateId,

        [Parameter(Mandatory = $true)]
        [string]$ApiKey,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath
    )

    $OutputPath = Resolve-RobopackPath -Path $OutputPath
    $File = Join-Path $OutputPath "$TemplateId-banner.png"

    $endpoint = "template/$TemplateId/banner"

    Write-Verbose "Downloading script template banner..."
    Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -ApiKey $ApiKey `
        -OutFile $File | Out-Null
    Write-Verbose "Download completed: $File"

    return $File
}
