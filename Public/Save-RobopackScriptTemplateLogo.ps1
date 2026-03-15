function Save-RobopackScriptTemplateLogo {
    <#
    .SYNOPSIS
    Downloads a script template logo image.

    .DESCRIPTION
    Downloads the logo image for a single script template from the Robopack API endpoint:
    /v1/template/{id}/logo
    The file is saved to the specified output directory.

    .PARAMETER TemplateId
    ID of target script template.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .PARAMETER OutputPath
    Directory path where the downloaded logo image is saved.

    .EXAMPLE
    Save-RobopackScriptTemplateLogo -ApiKey $apiKey -TemplateId "11111111-2222-3333-4444-555555555555" -OutputPath ".\Downloads"
    Saves the logo image as a PNG file in the output directory.
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
    $File = Join-Path $OutputPath "$TemplateId-logo.png"

    $endpoint = "template/$TemplateId/logo"

    Write-Verbose "Downloading script template logo..."
    Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -ApiKey $ApiKey `
        -OutFile $File | Out-Null
    Write-Verbose "Download completed: $File"

    return $File
}