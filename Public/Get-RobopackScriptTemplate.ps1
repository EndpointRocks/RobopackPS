function Get-RobopackScriptTemplate {
    <#
    .SYNOPSIS
    Lists available script templates.

    .DESCRIPTION
    Retrieves a list of available script templates from the Robopack API endpoint /v1/template.
    Returns both custom and standard templates that can be used for wrapping packages.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Get-RobopackScriptTemplate -ApiKey $apiKey
    Returns available script templates for the account.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$ApiKey
    )

    return Invoke-RobopackApi `
        -Method GET `
        -Endpoint "template" `
        -ApiKey $ApiKey
}
