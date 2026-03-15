function Get-RobopackScriptTemplateDetails {
    <#
    .SYNOPSIS
    Gets script template details.

    .DESCRIPTION
    Gets detailed information for a single script template from the Robopack API endpoint:
    /v1/template/{id}

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .PARAMETER TemplateId
    ID of target script template.

    .EXAMPLE
    Get-RobopackScriptTemplateDetails -ApiKey $apiKey -TemplateId "11111111-2222-3333-4444-555555555555"
    Gets details for a single script template.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [guid]$TemplateId,

        [Parameter(Mandatory = $true)]
        [string]$ApiKey
    )

    $endpoint = "template/$TemplateId"

    return Invoke-RobopackApi `
        -Method GET `
        -Endpoint $endpoint `
        -ApiKey $ApiKey
}
