function Import-RobopackInstantApp {
    <#
    .SYNOPSIS
    Imports an Instant app into the account as a package.

    .DESCRIPTION
    Imports a specific Instant app into the account as a new package using API endpoint:
    POST /v1/app/import/{appId}
    Returns the ID of the new package.
    If no version is specified, the latest app version is imported.
    Importing may take time, so the created package state should be checked before use.

    .PARAMETER AppId
    ID of Instant app to import.

    .PARAMETER Scope
    Scope for the app.

    .PARAMETER ScriptTemplateId
    ID of script template to use for creating the package.

    .PARAMETER Version
    String with version number of app to import.

    .PARAMETER VersionId
    ID of the specific Instant app version to import.

    .PARAMETER ApiKey
    The API key for the Robopack instance.

    .EXAMPLE
    Import-RobopackInstantApp -ApiKey $apiKey -AppId "11111111-2222-3333-4444-555555555555"
    Imports the latest version of the specified Instant app.

    .EXAMPLE
    Import-RobopackInstantApp -ApiKey $apiKey -AppId "11111111-2222-3333-4444-555555555555" -VersionId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    Imports a specific app version by version ID.

    .EXAMPLE
    Import-RobopackInstantApp -ApiKey $apiKey -AppId "11111111-2222-3333-4444-555555555555" -Scope 1 -ScriptTemplateId "aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee"
    Imports the app with an explicit scope and script template.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Guid]$AppId,

        [Parameter(Mandatory = $false)]
        [int]$Scope,

        [Parameter(Mandatory = $false)]
        [Guid]$ScriptTemplateId,

        [Parameter(Mandatory = $false)]
        [string]$Version,

        [Parameter(Mandatory = $false)]
        [Alias('TargetVersionId')]
        [Guid]$VersionId,

        [Parameter(Mandatory = $true)]
        [string]$ApiKey
    )

    if ($PSBoundParameters.ContainsKey('Version') -and $PSBoundParameters.ContainsKey('VersionId')) {
        throw "Specify either -Version or -VersionId, not both."
    }

    $endpoint = "app/import/$AppId"
    $query = @{}

    if ($PSBoundParameters.ContainsKey('Scope')) {
        $query.scope = $Scope
    }

    if ($PSBoundParameters.ContainsKey('ScriptTemplateId')) {
        $query.scriptTemplateId = $ScriptTemplateId
    }

    if ($PSBoundParameters.ContainsKey('Version')) {
        $query.version = $Version
    }

    if ($PSBoundParameters.ContainsKey('VersionId')) {
        $query.versionId = $VersionId
    }

    return Invoke-RobopackApi `
        -Method POST `
        -Endpoint $endpoint `
        -Query $query `
        -ApiKey $ApiKey
}
